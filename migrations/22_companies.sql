-- 22: corporate accounts — a company with a broad group of employees.
--
-- THE DESIGN CONSTRAINT THAT SHAPES EVERYTHING HERE:
-- Training data is a special category under GDPR art. 9 and lög nr. 90/2018.
-- In an employment relationship consent is legally weak, because an employee
-- cannot freely refuse their employer. So the employer's view is built to be
-- incapable of showing individual health data, rather than merely configured
-- not to:
--
--   * HR sees the ROSTER — who is a member, which department, when they joined.
--     That is employment administration; the employer already knows who works
--     for them, and they need it to manage seats.
--   * HR sees AGGREGATES — participation rate, total sessions, average activity.
--   * HR never sees a named employee's workouts, weights, injuries, or even
--     "last active". No RPC here returns it and no policy exposes it.
--   * Aggregates are SUPPRESSED below MIN_REPORT (5) participants, because a
--     three-person department's "average" is one person's data with a hat on.
--   * Leaderboards are opt-in per employee, since a ranked list of names is
--     itself identifying.
--
-- Coaching runs through the existing coach collaboration: a company attaches a
-- coach to a group, the coach sees individuals with the athlete's own consent,
-- and HR still sees only aggregates. Responsibility stays separated.

create table if not exists companies (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  kennitala      text,
  contact_email  text,
  seats          integer,
  created_by     uuid references profiles(id) on delete set null,
  created_at     timestamptz default now()
);

create table if not exists company_admins (
  company_id  uuid not null references companies(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  added_by    uuid references profiles(id) on delete set null,
  added_at    timestamptz default now(),
  primary key (company_id, user_id)
);

create table if not exists company_members (
  company_id  uuid not null references companies(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  department  text,
  status      text not null default 'active' check (status in ('active','left')),
  -- Opt-in, and only ever consulted for the leaderboard. Default false: a
  -- ranked list of names is identifying, so it cannot be the quiet default.
  show_on_leaderboard boolean not null default false,
  joined_at   timestamptz default now(),
  primary key (company_id, user_id)
);
create index if not exists company_members_user_idx on company_members (user_id, status);
create index if not exists company_members_dept_idx on company_members (company_id, department);

create table if not exists company_invites (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references companies(id) on delete cascade,
  code        text not null unique,
  department  text,
  expires_at  timestamptz,
  max_uses    integer not null default 500,
  used_count  integer not null default 0,
  active      boolean not null default true,
  created_at  timestamptz default now()
);

-- ─────────────────── access helpers (SECURITY DEFINER, no recursion) ───────────────────
create or replace function is_company_admin(c uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from company_admins where company_id = c and user_id = auth.uid());
$$;
create or replace function is_company_member(c uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from company_members
                 where company_id = c and user_id = auth.uid() and status = 'active');
$$;
grant execute on function public.is_company_admin(uuid) to anon, authenticated;
grant execute on function public.is_company_member(uuid) to anon, authenticated;

alter table companies        enable row level security;
alter table company_admins   enable row level security;
alter table company_members  enable row level security;
alter table company_invites  enable row level security;

-- Companies: admins manage, members may read the row they belong to (for the name).
drop policy if exists company_admin_rw on companies;
create policy company_admin_rw on companies
  for all using (public.is_company_admin(id)) with check (public.is_company_admin(id));
drop policy if exists company_member_read on companies;
create policy company_member_read on companies
  for select using (public.is_company_member(id));
-- Anyone signed in may create a company; they become its first admin via the RPC.
drop policy if exists company_create on companies;
create policy company_create on companies
  for insert with check (created_by = auth.uid());

drop policy if exists company_admins_manage on company_admins;
create policy company_admins_manage on company_admins
  for all using (public.is_company_admin(company_id)) with check (public.is_company_admin(company_id));
drop policy if exists company_admins_read_self on company_admins;
create policy company_admins_read_self on company_admins
  for select using (user_id = auth.uid());

-- Members: an employee owns their own row (and can leave); admins manage the roster.
drop policy if exists company_member_own on company_members;
create policy company_member_own on company_members
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists company_member_admin_read on company_members;
create policy company_member_admin_read on company_members
  for select using (public.is_company_admin(company_id));
drop policy if exists company_member_admin_update on company_members;
create policy company_member_admin_update on company_members
  for update using (public.is_company_admin(company_id))
  with check (public.is_company_admin(company_id));
drop policy if exists company_member_admin_delete on company_members;
create policy company_member_admin_delete on company_members
  for delete using (public.is_company_admin(company_id));

drop policy if exists company_invites_admin on company_invites;
create policy company_invites_admin on company_invites
  for all using (public.is_company_admin(company_id)) with check (public.is_company_admin(company_id));

-- An employee must not be able to move their membership to another company or
-- silently promote their own department.
create or replace function company_members_guard() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.company_id is distinct from old.company_id or new.user_id is distinct from old.user_id then
    raise exception 'company_id and user_id are immutable';
  end if;
  if not public.is_company_admin(new.company_id) and new.department is distinct from old.department then
    raise exception 'only a company admin can change a department';
  end if;
  return new;
end $$;
drop trigger if exists company_members_guard_trg on company_members;
create trigger company_members_guard_trg before update on company_members
  for each row execute function company_members_guard();
revoke execute on function public.company_members_guard() from public, anon, authenticated;

-- ─────────────────── operations ───────────────────
create or replace function company_create(p_name text, p_kennitala text default null,
                                          p_contact text default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'Not signed in'; end if;
  if coalesce(trim(p_name),'') = '' then raise exception 'A company needs a name'; end if;
  insert into companies (name, kennitala, contact_email, created_by)
    values (trim(p_name), nullif(trim(p_kennitala),''), nullif(trim(p_contact),''), auth.uid())
    returning id into v_id;
  insert into company_admins (company_id, user_id, added_by) values (v_id, auth.uid(), auth.uid());
  return v_id;
end $$;

create or replace function company_create_invite(p_company uuid, p_department text default null)
returns text language plpgsql security definer set search_path = public as $$
declare v_code text; v_try int := 0;
begin
  if not public.is_company_admin(p_company) then raise exception 'Company admins only'; end if;
  loop
    v_try := v_try + 1;
    v_code := 'FYRIR-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,5));
    begin
      insert into company_invites (company_id, code, department, expires_at)
        values (p_company, v_code, nullif(trim(p_department),''), now() + interval '90 days');
      return v_code;
    exception when unique_violation then
      if v_try >= 6 then raise; end if;
    end;
  end loop;
end $$;

create or replace function redeem_company_invite(p_code text)
returns text language plpgsql security definer set search_path = public as $$
declare v_inv company_invites; v_name text;
begin
  if auth.uid() is null then raise exception 'Not signed in'; end if;
  select * into v_inv from company_invites where code = upper(trim(p_code)) and active = true;
  if v_inv.id is null then raise exception 'Invalid or inactive code'; end if;
  if v_inv.expires_at is not null and v_inv.expires_at < now() then raise exception 'This code has expired'; end if;
  if v_inv.used_count >= v_inv.max_uses then raise exception 'This code has reached its limit'; end if;
  insert into company_members (company_id, user_id, department)
    values (v_inv.company_id, auth.uid(), v_inv.department)
  on conflict (company_id, user_id) do update set status = 'active';
  update company_invites set used_count = used_count + 1 where id = v_inv.id;
  select name into v_name from companies where id = v_inv.company_id;
  return coalesce(v_name, 'your company');
end $$;

-- ─────────────────── what the employer may read ───────────────────
-- Roster: employment administration only. Deliberately carries NO activity
-- column — not even "last active", which is a health signal about a named person.
create or replace function company_roster(p_company uuid)
returns table (user_id uuid, name text, department text, joined_at timestamptz)
language sql stable security definer set search_path = public as $$
  select m.user_id, p.name, m.department, m.joined_at
  from company_members m join profiles p on p.id = m.user_id
  where m.company_id = p_company and m.status = 'active'
    and public.is_company_admin(p_company)
  order by p.name;
$$;

-- Aggregates, suppressed below 5 participants. Returns the suppression flag so
-- the UI can say why a number is missing instead of showing a misleading zero.
create or replace function company_stats(p_company uuid, p_days integer default 30)
returns table (members bigint, active_members bigint, total_workouts bigint,
               avg_workouts_per_active numeric, participation_pct numeric, suppressed boolean)
language plpgsql stable security definer set search_path = public as $$
declare MIN_REPORT constant int := 5; v_members bigint;
begin
  if not public.is_company_admin(p_company) then raise exception 'Company admins only'; end if;
  select count(*) into v_members from company_members where company_id = p_company and status='active';
  if v_members < MIN_REPORT then
    return query select v_members, null::bigint, null::bigint, null::numeric, null::numeric, true;
    return;
  end if;
  return query
  with mem as (select user_id from company_members where company_id=p_company and status='active'),
       wk as (select w.user_id, count(*) n from workouts w join mem on mem.user_id=w.user_id
              where w.completed_at >= now() - make_interval(days=>p_days) group by w.user_id)
  -- Casts matter: sum() over a bigint yields numeric, and without ::bigint the
  -- function raises "structure of query does not match function result type"
  -- at call time and quietly returns no rows.
  select v_members,
         (select count(*) from wk)::bigint,
         coalesce((select sum(n) from wk),0)::bigint,
         round(coalesce((select avg(n) from wk),0),1)::numeric,
         round(100.0*(select count(*) from wk)/nullif(v_members,0),0)::numeric,
         false;
end $$;

-- Per department, each suppressed on its own count. A department of three is
-- reported as suppressed rather than rolled into a number one person defines.
create or replace function company_department_stats(p_company uuid, p_days integer default 30)
returns table (department text, members bigint, active_members bigint,
               avg_workouts numeric, suppressed boolean)
language plpgsql stable security definer set search_path = public as $$
declare MIN_REPORT constant int := 5;
begin
  if not public.is_company_admin(p_company) then raise exception 'Company admins only'; end if;
  return query
  with mem as (select coalesce(m.department,'—') dept, m.user_id
               from company_members m where m.company_id=p_company and m.status='active'),
       wk as (select mem.dept, mem.user_id, count(w.id) n
              from mem left join workouts w on w.user_id=mem.user_id
                   and w.completed_at >= now() - make_interval(days=>p_days)
              group by mem.dept, mem.user_id),
       agg as (select dept, count(*) members, count(*) filter (where n>0) active_members,
                      round(avg(n),1) avg_workouts
               from wk group by dept)
  select a.dept, a.members,
         case when a.members < MIN_REPORT then null else a.active_members end,
         case when a.members < MIN_REPORT then null else a.avg_workouts end,
         (a.members < MIN_REPORT)
  from agg a order by a.members desc, a.dept;
end $$;

-- Opt-in leaderboard. Only employees who switched it on appear, and it is
-- readable by fellow members — not by HR, who get aggregates.
create or replace function company_leaderboard(p_company uuid, p_days integer default 7)
returns table (user_id uuid, name text, workouts bigint)
language sql stable security definer set search_path = public as $$
  select m.user_id, p.name, count(w.id)
  from company_members m
  join profiles p on p.id = m.user_id
  left join workouts w on w.user_id = m.user_id
       and w.completed_at >= now() - make_interval(days => p_days)
  where m.company_id = p_company and m.status='active' and m.show_on_leaderboard
    and public.is_company_member(p_company)
  group by m.user_id, p.name
  order by count(w.id) desc, p.name;
$$;

-- The employee's own view: which company, and exactly what it can see.
create or replace function my_companies()
returns table (company_id uuid, name text, department text, is_admin boolean,
               on_leaderboard boolean, joined_at timestamptz)
language sql stable security definer set search_path = public as $$
  select c.id, c.name, m.department, public.is_company_admin(c.id),
         m.show_on_leaderboard, m.joined_at
  from company_members m join companies c on c.id = m.company_id
  where m.user_id = auth.uid() and m.status = 'active';
$$;

grant execute on function public.company_create(text,text,text) to authenticated;
grant execute on function public.company_create_invite(uuid,text) to authenticated;
grant execute on function public.redeem_company_invite(text) to authenticated;
grant execute on function public.company_roster(uuid) to authenticated;
grant execute on function public.company_stats(uuid,integer) to authenticated;
grant execute on function public.company_department_stats(uuid,integer) to authenticated;
grant execute on function public.company_leaderboard(uuid,integer) to authenticated;
grant execute on function public.my_companies() to authenticated;
revoke execute on function public.company_create(text,text,text) from public, anon;
revoke execute on function public.company_create_invite(uuid,text) from public, anon;
revoke execute on function public.redeem_company_invite(text) from public, anon;
revoke execute on function public.company_roster(uuid) from public, anon;
revoke execute on function public.company_stats(uuid,integer) from public, anon;
revoke execute on function public.company_department_stats(uuid,integer) from public, anon;
revoke execute on function public.company_leaderboard(uuid,integer) from public, anon;
revoke execute on function public.my_companies() from public, anon;

grant select, insert, update, delete on companies to authenticated;
grant select, insert, update, delete on company_admins to authenticated;
grant select, insert, update, delete on company_members to authenticated;
grant select, insert, update, delete on company_invites to authenticated;
