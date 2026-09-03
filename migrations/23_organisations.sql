-- 23: coaching organisations — a gym, club or coaching business buys access and
-- its COACHES work together in teams under it.
--
-- Replaces migration 22, which was built on a misreading: that modelled corporate
-- wellness, where a company's employees are the athletes and HR reads aggregate
-- participation. What is actually wanted is the opposite shape — the members of
-- an organisation are the coaches themselves, and the point is collaboration
-- between them rather than reporting about them. Migration 22 never held a row,
-- so its objects are dropped rather than migrated.
--
-- The important consequence: two coaches in the same organisation are
-- automatically peers. All the co-coaching and group-sharing built in migration
-- 20 therefore works inside an organisation with no one-to-one invitations —
-- a coach joins the gym and can immediately be put on a client or a team.

drop function if exists company_stats(uuid,integer);
drop function if exists company_department_stats(uuid,integer);
drop function if exists company_leaderboard(uuid,integer);
drop function if exists company_roster(uuid);
drop function if exists my_companies();
drop function if exists company_create(text,text,text);
drop function if exists company_create_invite(uuid,text);
drop function if exists redeem_company_invite(text);
drop function if exists is_company_admin(uuid);
drop function if exists is_company_member(uuid);
drop trigger if exists company_members_guard_trg on company_members;
drop function if exists company_members_guard();
drop table if exists company_invites;
drop table if exists company_members;
drop table if exists company_admins;
drop table if exists companies;

-- ─────────────────────────── the organisation ───────────────────────────
create table if not exists organisations (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  kennitala    text,
  contact_email text,
  -- Licensed coach seats. NULL means unmetered; otherwise joining is refused
  -- once the seats are full, which is what "buys access" actually means here.
  seats        integer,
  plan         text not null default 'team' check (plan in ('team','club','enterprise')),
  created_by   uuid references profiles(id) on delete set null,
  created_at   timestamptz default now()
);

create table if not exists org_members (
  org_id     uuid not null references organisations(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  role       text not null default 'coach' check (role in ('owner','admin','coach')),
  status     text not null default 'active' check (status in ('active','left')),
  joined_at  timestamptz default now(),
  primary key (org_id, user_id)
);
create index if not exists org_members_user_idx on org_members (user_id, status);

create table if not exists org_teams (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organisations(id) on delete cascade,
  name       text not null,
  focus      text,
  created_by uuid references profiles(id) on delete set null,
  created_at timestamptz default now()
);

create table if not exists org_team_members (
  team_id   uuid not null references org_teams(id) on delete cascade,
  user_id   uuid not null references profiles(id) on delete cascade,
  added_at  timestamptz default now(),
  primary key (team_id, user_id)
);

create table if not exists org_invites (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organisations(id) on delete cascade,
  code       text not null unique,
  role       text not null default 'coach' check (role in ('admin','coach')),
  expires_at timestamptz,
  max_uses   integer not null default 50,
  used_count integer not null default 0,
  active     boolean not null default true,
  created_at timestamptz default now()
);

-- ─────────── helpers (SECURITY DEFINER so policies cannot recurse) ───────────
create or replace function is_org_member(o uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from org_members
                 where org_id = o and user_id = auth.uid() and status = 'active');
$$;
create or replace function is_org_admin(o uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from org_members
                 where org_id = o and user_id = auth.uid() and status='active'
                   and role in ('owner','admin'));
$$;
create or replace function team_org(t uuid) returns uuid
language sql stable security definer set search_path = public as $$
  select org_id from org_teams where id = t;
$$;
-- Do two coaches share an organisation? This is what makes colleagues implicit.
create or replace function same_org(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from org_members m1 join org_members m2 on m1.org_id = m2.org_id
    where m1.user_id = a and m2.user_id = b
      and m1.status='active' and m2.status='active' and a <> b);
$$;
grant execute on function public.is_org_member(uuid) to anon, authenticated;
grant execute on function public.is_org_admin(uuid) to anon, authenticated;
grant execute on function public.team_org(uuid) to anon, authenticated;
grant execute on function public.same_org(uuid,uuid) to authenticated;

-- Colleagues are now either an accepted 1:1 connection OR shared membership of
-- an organisation. Every co-coach and group-sharing check already routes through
-- are_peers(), so widening it here is what lets an org's coaches collaborate.
create or replace function are_peers(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from coach_peers
    where status = 'active'
      and ((requester_id = a and peer_id = b) or (requester_id = b and peer_id = a))
  ) or public.same_org(a, b);
$$;

alter table organisations   enable row level security;
alter table org_members     enable row level security;
alter table org_teams       enable row level security;
alter table org_team_members enable row level security;
alter table org_invites     enable row level security;

drop policy if exists org_member_read on organisations;
create policy org_member_read on organisations for select using (public.is_org_member(id));
drop policy if exists org_admin_write on organisations;
create policy org_admin_write on organisations for update
  using (public.is_org_admin(id)) with check (public.is_org_admin(id));
drop policy if exists org_admin_delete on organisations;
create policy org_admin_delete on organisations for delete using (public.is_org_admin(id));
drop policy if exists org_create on organisations;
create policy org_create on organisations for insert with check (created_by = auth.uid());

drop policy if exists org_members_read on org_members;
create policy org_members_read on org_members
  for select using (user_id = auth.uid() or public.is_org_member(org_id));
drop policy if exists org_members_admin on org_members;
create policy org_members_admin on org_members
  for all using (public.is_org_admin(org_id)) with check (public.is_org_admin(org_id));
-- A coach may always walk away from an organisation.
drop policy if exists org_members_leave on org_members;
create policy org_members_leave on org_members
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists org_teams_read on org_teams;
create policy org_teams_read on org_teams for select using (public.is_org_member(org_id));
drop policy if exists org_teams_write on org_teams;
create policy org_teams_write on org_teams
  for all using (public.is_org_admin(org_id)) with check (public.is_org_admin(org_id));

drop policy if exists org_team_members_read on org_team_members;
create policy org_team_members_read on org_team_members
  for select using (public.is_org_member(public.team_org(team_id)));
drop policy if exists org_team_members_write on org_team_members;
create policy org_team_members_write on org_team_members
  for all using (public.is_org_admin(public.team_org(team_id)))
  with check (public.is_org_admin(public.team_org(team_id)));

drop policy if exists org_invites_admin on org_invites;
create policy org_invites_admin on org_invites
  for all using (public.is_org_admin(org_id)) with check (public.is_org_admin(org_id));

-- Membership cannot be reassigned, and a coach cannot promote themselves.
create or replace function org_members_guard() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.org_id is distinct from old.org_id or new.user_id is distinct from old.user_id then
    raise exception 'org_id and user_id are immutable';
  end if;
  if new.role is distinct from old.role and not public.is_org_admin(new.org_id) then
    raise exception 'only an organisation admin can change a role';
  end if;
  -- The last owner must not be able to demote or remove themselves and strand
  -- the organisation with nobody able to administer it.
  if old.role = 'owner' and new.role <> 'owner'
     and (select count(*) from org_members
          where org_id = new.org_id and role='owner' and status='active') <= 1 then
    raise exception 'an organisation must keep at least one owner';
  end if;
  return new;
end $$;
drop trigger if exists org_members_guard_trg on org_members;
create trigger org_members_guard_trg before update on org_members
  for each row execute function org_members_guard();
revoke execute on function public.org_members_guard() from public, anon, authenticated;

-- ─────────────────────────── operations ───────────────────────────
create or replace function org_create(p_name text, p_kennitala text default null,
                                      p_contact text default null, p_seats integer default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if not public.is_approved_coach() then raise exception 'Approved coaches only'; end if;
  if coalesce(trim(p_name),'') = '' then raise exception 'An organisation needs a name'; end if;
  insert into organisations (name, kennitala, contact_email, seats, created_by)
    values (trim(p_name), nullif(trim(p_kennitala),''), nullif(trim(p_contact),''), p_seats, auth.uid())
    returning id into v_id;
  insert into org_members (org_id, user_id, role) values (v_id, auth.uid(), 'owner');
  return v_id;
end $$;

create or replace function org_create_invite(p_org uuid, p_role text default 'coach')
returns text language plpgsql security definer set search_path = public as $$
declare v_code text; v_try int := 0;
begin
  if not public.is_org_admin(p_org) then raise exception 'Organisation admins only'; end if;
  if p_role not in ('admin','coach') then raise exception 'Invalid role'; end if;
  loop
    v_try := v_try + 1;
    v_code := 'TEAM-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,5));
    begin
      insert into org_invites (org_id, code, role, expires_at)
        values (p_org, v_code, p_role, now() + interval '30 days');
      return v_code;
    exception when unique_violation then
      if v_try >= 6 then raise; end if;
    end;
  end loop;
end $$;

create or replace function redeem_org_invite(p_code text)
returns text language plpgsql security definer set search_path = public as $$
declare v_inv org_invites; v_name text; v_seats integer; v_used integer;
begin
  if not public.is_approved_coach() then raise exception 'Approved coaches only'; end if;
  select * into v_inv from org_invites where code = upper(trim(p_code)) and active = true;
  if v_inv.id is null then raise exception 'Invalid or inactive code'; end if;
  if v_inv.expires_at is not null and v_inv.expires_at < now() then raise exception 'This code has expired'; end if;
  if v_inv.used_count >= v_inv.max_uses then raise exception 'This code has reached its limit'; end if;
  -- Seat check: this is what a bought licence actually enforces.
  select seats into v_seats from organisations where id = v_inv.org_id;
  select count(*) into v_used from org_members where org_id = v_inv.org_id and status='active';
  if v_seats is not null and v_used >= v_seats
     and not exists (select 1 from org_members where org_id=v_inv.org_id and user_id=auth.uid() and status='active') then
    raise exception 'This organisation has used all % of its coach seats', v_seats;
  end if;
  insert into org_members (org_id, user_id, role)
    values (v_inv.org_id, auth.uid(), v_inv.role)
  on conflict (org_id, user_id) do update set status='active';
  update org_invites set used_count = used_count + 1 where id = v_inv.id;
  select name into v_name from organisations where id = v_inv.org_id;
  return coalesce(v_name, 'the organisation');
end $$;

-- Share one client with an entire team in a single action. Each coach is added
-- through the same path as a manual co-coach, so the access rules are identical.
create or replace function share_client_with_team(p_client uuid, p_team uuid, p_access text default 'full')
returns integer language plpgsql security definer set search_path = public as $$
declare v_org uuid; v_n integer := 0; r record;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such team'; end if;
  if not public.is_org_member(v_org) then raise exception 'You are not in that organisation'; end if;
  if not public.coach_can_edit(p_client) then
    raise exception 'You need full access to this client to share them';
  end if;
  if p_access not in ('full','read') then raise exception 'Invalid access level'; end if;
  for r in select tm.user_id from org_team_members tm where tm.team_id = p_team and tm.user_id <> auth.uid()
  loop
    insert into coach_clients (coach_id, client_id, status, source, access, added_by)
      values (r.user_id, p_client, 'active', 'cocoach', p_access, auth.uid())
    on conflict (coach_id, client_id) do update set status='active', access=p_access, added_by=auth.uid();
    v_n := v_n + 1;
  end loop;
  return v_n;
end $$;

-- ─────────────────────────── read helpers ───────────────────────────
create or replace function my_orgs()
returns table (org_id uuid, name text, role text, seats integer, seats_used bigint, plan text)
language sql stable security definer set search_path = public as $$
  select o.id, o.name, m.role, o.seats,
         (select count(*) from org_members x where x.org_id=o.id and x.status='active'),
         o.plan
  from org_members m join organisations o on o.id = m.org_id
  where m.user_id = auth.uid() and m.status='active';
$$;

create or replace function org_roster(p_org uuid)
returns table (user_id uuid, name text, role text, joined_at timestamptz, clients bigint)
language sql stable security definer set search_path = public as $$
  select m.user_id, p.name, m.role, m.joined_at,
         (select count(*) from coach_clients cc where cc.coach_id=m.user_id and cc.status='active')
  from org_members m join profiles p on p.id = m.user_id
  where m.org_id = p_org and m.status='active' and public.is_org_member(p_org)
  order by case m.role when 'owner' then 0 when 'admin' then 1 else 2 end, p.name;
$$;

create or replace function org_team_list(p_org uuid)
returns table (team_id uuid, name text, focus text, coaches bigint)
language sql stable security definer set search_path = public as $$
  select t.id, t.name, t.focus, (select count(*) from org_team_members tm where tm.team_id=t.id)
  from org_teams t where t.org_id = p_org and public.is_org_member(p_org)
  order by t.name;
$$;

create or replace function team_coaches(p_team uuid)
returns table (user_id uuid, name text, role text)
language sql stable security definer set search_path = public as $$
  select tm.user_id, p.name, m.role
  from org_team_members tm
  join profiles p on p.id = tm.user_id
  left join org_members m on m.user_id = tm.user_id and m.org_id = public.team_org(p_team)
  where tm.team_id = p_team and public.is_org_member(public.team_org(p_team))
  order by p.name;
$$;

grant execute on function public.org_create(text,text,text,integer) to authenticated;
grant execute on function public.org_create_invite(uuid,text) to authenticated;
grant execute on function public.redeem_org_invite(text) to authenticated;
grant execute on function public.share_client_with_team(uuid,uuid,text) to authenticated;
grant execute on function public.my_orgs() to authenticated;
grant execute on function public.org_roster(uuid) to authenticated;
grant execute on function public.org_team_list(uuid) to authenticated;
grant execute on function public.team_coaches(uuid) to authenticated;
revoke execute on function public.org_create(text,text,text,integer) from public, anon;
revoke execute on function public.org_create_invite(uuid,text) from public, anon;
revoke execute on function public.redeem_org_invite(text) from public, anon;
revoke execute on function public.share_client_with_team(uuid,uuid,text) from public, anon;
revoke execute on function public.my_orgs() from public, anon;
revoke execute on function public.org_roster(uuid) from public, anon;
revoke execute on function public.org_team_list(uuid) from public, anon;
revoke execute on function public.team_coaches(uuid) from public, anon;

grant select, insert, update, delete on organisations to authenticated;
grant select, insert, update, delete on org_members to authenticated;
grant select, insert, update, delete on org_teams to authenticated;
grant select, insert, update, delete on org_team_members to authenticated;
grant select, insert, update, delete on org_invites to authenticated;
