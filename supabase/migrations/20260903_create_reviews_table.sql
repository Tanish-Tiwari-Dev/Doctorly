-- Migration: 20260903_create_reviews_table.sql
-- Create doctor_reviews table, RLS policies, and rating recalculation trigger.

-- 1) Create doctor_reviews table
create table if not exists public.doctor_reviews (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating int2 not null check (rating >= 1 and rating <= 5),
  comment text,
  created_at timestamptz not null default now()
);

-- Ensure doctors table has review_count column
alter table public.doctors add column if not exists review_count int4 default 0;

-- 2) Enable RLS
alter table public.doctor_reviews enable row level security;

drop policy if exists "Users can insert own doctor reviews" on public.doctor_reviews;
create policy "Users can insert own doctor reviews" on public.doctor_reviews
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Anyone can read doctor reviews" on public.doctor_reviews;
create policy "Anyone can read doctor reviews" on public.doctor_reviews
  for select to authenticated, anon
  using (true);

-- 3) Postgres function + trigger to update doctor rating & review_count
create or replace function public.update_doctor_rating_on_review()
returns trigger
language plpgsql
security definer
as $$
declare
  v_doctor_id uuid;
  v_avg_rating numeric;
  v_count int;
begin
  if (TG_OP = 'DELETE') then
    v_doctor_id := old.doctor_id;
  else
    v_doctor_id := new.doctor_id;
  end if;

  select coalesce(avg(rating), 0.0), count(*)
  into v_avg_rating, v_count
  from public.doctor_reviews
  where doctor_id = v_doctor_id;

  update public.doctors
  set rating = round(v_avg_rating, 1),
      review_count = v_count
  where id = v_doctor_id;

  return null;
end;
$$;

drop trigger if exists trg_update_doctor_rating on public.doctor_reviews;
create trigger trg_update_doctor_rating
  after insert or update or delete on public.doctor_reviews
  for each row execute procedure public.update_doctor_rating_on_review();
