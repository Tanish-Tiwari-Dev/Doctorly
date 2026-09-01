-- Migration: Create Reports Table and RLS Policies

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete cascade,
  reported_doctor_id uuid references public.doctors(id) on delete cascade,
  reason text not null,
  details text,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.reports enable row level security;

-- RLS Policy: Users can insert their own reports
drop policy if exists "reports insert own" on public.reports;
create policy "reports insert own" on public.reports
  for insert to authenticated, anon
  with check (auth.uid() = reporter_id);

-- RLS Policy: Users can read their own reports
drop policy if exists "reports select own" on public.reports;
create policy "reports select own" on public.reports
  for select to authenticated, anon
  using (auth.uid() = reporter_id);
