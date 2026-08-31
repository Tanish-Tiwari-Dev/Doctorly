-- Migration: 20260902000000_phase_b_neuro_schema.sql
-- Phase B — Neurosurgeons dataset schema expansion & availability slots

-- 1) Add new columns to doctors table
alter table public.doctors
  add column if not exists qualification text,
  add column if not exists sub_specialty text,
  add column if not exists designation text,
  add column if not exists hospital_name text,
  add column if not exists practice_type text,
  add column if not exists city text,
  add column if not exists phone text,
  add column if not exists email text,
  add column if not exists website_url text,
  add column if not exists teleconsultation boolean default false,
  add column if not exists languages text,
  add column if not exists expertise jsonb;

-- 2) Create availability_slots table
create table if not exists public.availability_slots (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  start_time timestamptz not null,
  is_booked boolean default false,
  created_at timestamptz not null default now(),
  constraint availability_slots_doctor_start_time_unique unique (doctor_id, start_time)
);

create index if not exists availability_slots_doctor_time_idx on public.availability_slots (doctor_id, start_time);

-- 3) Enable RLS for availability_slots
alter table public.availability_slots enable row level security;

drop policy if exists "availability_slots read" on public.availability_slots;
create policy "availability_slots read" on public.availability_slots
  for select to anon, authenticated using (true);
