-- Migration: 20231025000000_profiles_and_merge.sql
-- Creates the profiles table, merge function, and auth trigger.

-- 1) Profiles table
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  is_anonymous boolean not null default false,
  anonymous_token text unique,
  created_at timestamptz not null default now()
);

-- 2) RLS for profiles
alter table public.profiles enable row level security;

drop policy if exists "profiles read own" on public.profiles;
create policy "profiles read own" on public.profiles
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "profiles insert anon" on public.profiles;
create policy "profiles insert anon" on public.profiles
  for insert to anon with check (is_anonymous = true);

-- 3) Merge function
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
  -- Transfer favorites, avoiding duplicate key conflicts
  insert into public.favorites (user_id, doctor_id, created_at)
  select p_new_user_id, doctor_id, created_at
  from public.favorites
  where user_id = p_old_anon_id
  on conflict (user_id, doctor_id) do nothing;
  get diagnostics v_favs = row_count;

  delete from public.favorites
  where user_id = p_old_anon_id;

  -- Transfer appointments
  update public.appointments
  set user_id = p_new_user_id
  where user_id = p_old_anon_id;
  get diagnostics v_appts = row_count;

  -- Mark the anonymous profile as merged
  update public.profiles
  set is_anonymous = false
  where user_id = p_old_anon_id;

  return query select v_favs, v_appts, v_errors;
end;
$$;

grant execute on function public.merge_anonymous_data(uuid, uuid) to authenticated;

-- 4) Trigger to auto-create profiles row on user creation
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
