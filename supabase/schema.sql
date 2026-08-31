-- Doctorly Phase 5 schema
-- Run in Supabase Dashboard → SQL Editor (in order).

-- 1) Extensions
create extension if not exists "uuid-ossp";
create extension if not exists postgis;

-- 2) Tables

create table if not exists public.doctors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  specialty text not null,
  location geography(Point, 4326) not null,
  address text,
  rating numeric(2,1),
  image_url text,
  availability text,
  qualification text,
  sub_specialty text,
  designation text,
  hospital_name text,
  practice_type text,
  city text,
  phone text,
  email text,
  website_url text,
  teleconsultation boolean default false,
  languages text,
  expertise jsonb,
  created_at timestamptz not null default now()
);

create index if not exists doctors_location_gix on public.doctors using gist (location);
create index if not exists doctors_specialty_idx on public.doctors (specialty);

create table if not exists public.availability_slots (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  start_time timestamptz not null,
  is_booked boolean default false,
  created_at timestamptz not null default now(),
  constraint availability_slots_doctor_start_time_unique unique (doctor_id, start_time)
);

create index if not exists availability_slots_doctor_time_idx on public.availability_slots (doctor_id, start_time);


create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, doctor_id)
);

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  scheduled_for timestamptz not null,
  status text not null default 'pending' check (status in ('pending','confirmed','cancelled')),
  created_at timestamptz not null default now()
);

create index if not exists appointments_user_idx on public.appointments (user_id, scheduled_for);

alter table public.appointments
  drop constraint if exists appointments_doctor_scheduled_for_unique,
  add constraint appointments_doctor_scheduled_for_unique
  unique (doctor_id, scheduled_for);

alter table public.appointments
  drop constraint if exists appointments_scheduled_for_future,
  add constraint appointments_scheduled_for_future
  check (scheduled_for > now());

-- 3) Row Level Security

alter table public.doctors enable row level security;
alter table public.favorites enable row level security;
alter table public.appointments enable row level security;

-- doctors: anyone can read (anon + authenticated)
drop policy if exists "doctors read" on public.doctors;
create policy "doctors read" on public.doctors
  for select to anon, authenticated using (true);

-- favorites: users manage their own
drop policy if exists "favorites read own" on public.favorites;
create policy "favorites read own" on public.favorites
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "favorites insert own" on public.favorites;
create policy "favorites insert own" on public.favorites
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "favorites delete own" on public.favorites;
create policy "favorites delete own" on public.favorites
  for delete to authenticated using (auth.uid() = user_id);

-- appointments: users manage their own
drop policy if exists "appointments read own" on public.appointments;
create policy "appointments read own" on public.appointments
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "appointments insert own" on public.appointments;
create policy "appointments insert own" on public.appointments
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "appointments update own" on public.appointments;
create policy "appointments update own" on public.appointments
  for update to authenticated using (auth.uid() = user_id);

drop policy if exists "appointments delete own" on public.appointments;
create policy "appointments delete own" on public.appointments
  for delete to authenticated using (auth.uid() = user_id);

-- 4) RPC: nearby_doctors
-- Returns doctors within radius_km of (lat, lng), sorted by distance.

drop function if exists public.nearby_doctors(double precision, double precision, double precision);

create or replace function public.nearby_doctors(
  lat double precision,
  lng double precision,
  radius_km double precision default 5
)
returns table (
  id uuid,
  name text,
  specialty text,
  address text,
  rating numeric,
  image_url text,
  availability text,
  distance_m double precision
)
language sql
stable
as $$
  select
    d.id,
    d.name,
    d.specialty,
    d.address,
    d.rating,
    d.image_url,
    d.availability,
    ST_Distance(
      d.location,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
    ) as distance_m
  from public.doctors d
  where ST_DWithin(
    d.location,
    ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
    radius_km * 1000
  )
  order by distance_m asc;
$$;

-- Grant execute to anon + authenticated so the Flutter client can call it.
grant execute on function public.nearby_doctors(double precision, double precision, double precision) to anon, authenticated;

-- 5) Profiles table
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  is_anonymous boolean not null default false,
  anonymous_token text unique,
  created_at timestamptz not null default now()
);

-- 6) Row Level Security for profiles

alter table public.profiles enable row level security;

drop policy if exists "profiles read own" on public.profiles;
create policy "profiles read own" on public.profiles
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "profiles insert anon" on public.profiles;
create policy "profiles insert anon" on public.profiles
  for insert to anon with check (is_anonymous = true);

-- 7) RPC: merge_anonymous_data
-- Transfers favorites and appointments from an anonymous account to a real account.

create or replace function public.merge_anonymous_data(
  p_old_anon_id uuid,
  p_new_user_id uuid
)
returns table (
  transferred_favorites bigint,
  transferred_appointments bigint,
  errors text[]
)
language plpgsql
security definer
as $$
declare
  v_favs bigint;
  v_appts bigint;
  v_errors text[] := '{}';
begin
  insert into public.favorites (user_id, doctor_id, created_at)
  select p_new_user_id, doctor_id, created_at
  from public.favorites
  where user_id = p_old_anon_id
  on conflict (user_id, doctor_id) do nothing;
  get diagnostics v_favs = row_count;

  delete from public.favorites
  where user_id = p_old_anon_id;

  update public.appointments
  set user_id = p_new_user_id
  where user_id = p_old_anon_id;
  get diagnostics v_appts = row_count;

  update public.profiles
  set is_anonymous = false
  where user_id = p_old_anon_id;

  return query select v_favs, v_appts, v_errors;
end;
$$;

grant execute on function public.merge_anonymous_data(uuid, uuid) to authenticated;

-- 8) Trigger: auto-create profiles row when a user is created in auth.users

create or replace function public.handle_new_user()
returns trigger as $$
begin
  begin
    insert into public.profiles (user_id, is_anonymous)
    values (new.id, new.email is null)
    on conflict (user_id) do nothing;
  exception when others then
    null;
  end;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 9) RPC: delete_user_account
-- Deletes the calling user's appointments, favorites, profile, and auth record.

create or replace function public.delete_user_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user_id uuid;
begin
  v_user_id := auth.uid();

  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  delete from public.appointments where user_id = v_user_id;
  delete from public.favorites where user_id = v_user_id;
  delete from public.profiles where user_id = v_user_id;

  delete from auth.users where id = v_user_id;
end;
$$;

grant execute on function public.delete_user_account() to authenticated;

