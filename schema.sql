-- HelpMeet waitlist. Run once in the Supabase SQL editor (or via migration).
-- Visitors can only call join_waitlist(); they can never read the list.

create table if not exists public.waitlist (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  first_name   text not null check (char_length(first_name) between 1 and 60),
  email        text not null unique check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  city         text not null check (char_length(city) <= 60),
  role         text not null check (role in ('single', 'friend')),
  tradition    text check (char_length(tradition) <= 60),
  ref_code     text not null unique default substr(md5(gen_random_uuid()::text), 1, 8),
  referred_by  text references public.waitlist (ref_code),
  source       text check (char_length(source) <= 80),
  church       text check (char_length(church) <= 80)  -- optional, private
);

alter table public.waitlist enable row level security;
-- No policies on purpose: the public key cannot select, insert, update or delete rows directly.

create or replace function public.join_waitlist(
  p_first_name text, p_email text, p_city text, p_role text,
  p_tradition text default null, p_ref text default null, p_source text default null,
  p_church text default null
) returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := lower(trim(p_email));
  v_ref   text;
  v_code  text;
begin
  select ref_code into v_ref from waitlist where ref_code = nullif(trim(p_ref), '');

  insert into waitlist (first_name, email, city, role, tradition, referred_by, source, church)
  values (trim(p_first_name), v_email, p_city, p_role, nullif(trim(p_tradition), ''), v_ref,
          nullif(left(p_source, 80), ''), nullif(left(trim(p_church), 80), ''))
  on conflict (email) do nothing;

  select ref_code into v_code from waitlist where email = v_email;

  return json_build_object(
    'ref_code', v_code,
    'referrals', (select count(*) from waitlist where referred_by = v_code)
  );
end;
$$;

revoke all on function public.join_waitlist(text, text, text, text, text, text, text, text) from public;
grant execute on function public.join_waitlist(text, text, text, text, text, text, text, text) to anon;

-- Sign-ups by church:
-- select coalesce(church, '(not given)') as church, count(*) from waitlist group by 1 order by 2 desc;
--
-- Traction report (run as admin in the SQL editor):
-- select city, role, count(*) as signups,
--        round(100.0 * count(*) filter (where referred_by is not null) / count(*), 1) as pct_referred
-- from waitlist group by city, role order by signups desc;
--
-- Share of sign-ups who brought at least one friend:
-- select round(100.0 * count(distinct r.referred_by) / (select count(*) from waitlist), 1) as pct_who_invited
-- from waitlist r where r.referred_by is not null;
