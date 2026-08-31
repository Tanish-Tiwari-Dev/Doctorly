-- Migration: Delete User Account RPC Function

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

  -- Delete user data in public schema
  delete from public.appointments where user_id = v_user_id;
  delete from public.favorites where user_id = v_user_id;
  delete from public.profiles where user_id = v_user_id;

  -- Delete user from auth.users
  delete from auth.users where id = v_user_id;
end;
$$;

grant execute on function public.delete_user_account() to authenticated;
