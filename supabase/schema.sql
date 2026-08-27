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
  created_at timestamptz not null default now()
);

create index if not exists doctors_location_gix on public.doctors using gist (location);
create index if not exists doctors_specialty_idx on public.doctors (specialty);

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

create or replace function public.nearby_doctors(
  lat double precision,
  lng double precision,
  radius_km double precision default 5
)
returns table (
  id uuid,
  name text,
  specialty text,
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
