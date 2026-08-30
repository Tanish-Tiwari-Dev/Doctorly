-- Migration: 20260830_backend_hardening.sql
-- Phase A — Backend Hardening

-- 1) Unique constraint: a doctor cannot have two appointments at the same time
alter table public.appointments
  drop constraint if exists appointments_doctor_scheduled_for_unique,
  add constraint appointments_doctor_scheduled_for_unique
  unique (doctor_id, scheduled_for);

-- 2) Check constraint: appointments must be scheduled in the future
alter table public.appointments
  drop constraint if exists appointments_scheduled_for_future,
  add constraint appointments_scheduled_for_future
  check (scheduled_for > now());

-- 3) Update nearby_doctors RPC to include the address column
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

grant execute on function public.nearby_doctors(double precision, double precision, double precision) to anon, authenticated;
