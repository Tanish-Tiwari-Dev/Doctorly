-- Doctorly Supabase schema
-- Run in Supabase Dashboard → SQL Editor (in order).

-- 1) Extensions
create extension if not exists pgcrypto;
create extension if not exists postgis;

-- 2) Tables

-- 2.1 doctors
create table if not exists public.doctors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  specialty text not null,
  rating numeric(2,1),
  image_url text,
  location geography(Point, 4326) not null
);

create index if not exists doctors_location_gix on public.doctors using gist (location);
create index if not exists doctors_specialty_idx on public.doctors (specialty);

-- 2.2 favorites
create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, doctor_id)
);

-- 2.3 appointments
create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  appointment_date date not null,
  time_slot text not null,
  created_at timestamptz not null default now()
);

create index if not exists appointments_user_idx on public.appointments (user_id, appointment_date);

-- 3) Row Level Security

alter table public.doctors enable row level security;
alter table public.favorites enable row level security;
alter table public.appointments enable row level security;

-- doctors: anyone can select
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

drop policy if exists "appointments delete own" on public.appointments;
create policy "appointments delete own" on public.appointments
  for delete to authenticated using (auth.uid() = user_id);

-- 4) Mock doctors (5 entries around Bangalore)
insert into public.doctors (name, specialty, rating, image_url, location) values
  ('Dr. Priya Sharma', 'Cardiologist', 4.8,
    'https://i.pravatar.cc/150?img=11',
    ST_SetSRID(ST_MakePoint(77.5946, 12.9716), 4326)),

  ('Dr. Arjun Mehta', 'Dermatologist', 4.6,
    'https://i.pravatar.cc/150?img=12',
    ST_SetSRID(ST_MakePoint(77.6068, 12.9854), 4326)),

  ('Dr. Sneha Reddy', 'Pediatrician', 4.9,
    'https://i.pravatar.cc/150?img=13',
    ST_SetSRID(ST_MakePoint(77.6209, 12.9352), 4326)),

  ('Dr. Rajesh Kumar', 'Orthopedic Surgeon', 4.7,
    'https://i.pravatar.cc/150?img=14',
    ST_SetSRID(ST_MakePoint(77.5772, 12.9279), 4326)),

  ('Dr. Ananya Desai', 'General Physician', 4.5,
    'https://i.pravatar.cc/150?img=15',
    ST_SetSRID(ST_MakePoint(77.6099, 12.9698), 4326))
on conflict do nothing;
