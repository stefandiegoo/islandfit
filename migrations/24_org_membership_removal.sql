-- 24: removing coaches and clients from an organisation.
--
-- Migration 23 shipped an incomplete removal. Ending a coach's membership only
-- set org_members.status='left'; every client the gym had shared with them
-- stayed in their list, so a coach could leave and keep coaching the gym's
-- roster. And clients had no relationship to an organisation at all, so there
-- was nothing to remove them from.
--
-- The rule both halves now follow: DELEGATED ACCESS ENDS WHEN THE BASIS FOR THE
-- DELEGATION ENDS. A coach_clients row with source='cocoach' exists because
-- someone in the organisation handed it over; when the coach leaves, or the
-- client is taken off the gym's roster, that row goes. A link the coach won
-- themselves — an invite code they issued, a client they added by email — is
-- theirs and is never touched, because the athlete agreed to that one directly.

-- The gym's own client roster.
create table if not exists org_clients (
  org_id     uuid not null references organisations(id) on delete cascade,
  client_id  uuid not null references profiles(id) on delete cascade,
  added_by   uuid references profiles(id) on delete set null,
  added_at   timestamptz default now(),
  primary key (org_id, client_id)
);
create index if not exists org_clients_client_idx on org_clients (client_id);

alter table org_clients enable row level security;

drop policy if exists org_clients_read on org_clients;
create policy org_clients_read on org_clients
  for select using (public.is_org_member(org_id));
drop policy if exists org_clients_admin on org_clients;
create policy org_clients_admin on org_clients
  for all using (public.is_org_admin(org_id)) with check (public.is_org_admin(org_id));

-- Put one of your clients on the gym's roster. You must actually coach them
-- with full access — you cannot enrol someone else's client.
create or replace function org_add_client(p_org uuid, p_client uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_org_member(p_org) then raise exception 'You are not in that organisation'; end if;
  if not public.coach_can_edit(p_client) then
    raise exception 'You need full access to this client to add them';
  end if;
  insert into org_clients (org_id, client_id, added_by)
    values (p_org, p_client, auth.uid())
  on conflict (org_id, client_id) do nothing;
end $$;

-- Take a client off the roster. Every delegated link held by a coach of THIS
-- organisation is withdrawn; the coach who brought them in keeps them, because
-- that relationship is between the athlete and that coach, not the gym.
create or replace function org_remove_client(p_org uuid, p_client uuid)
returns integer language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  if not public.is_org_admin(p_org) then raise exception 'Organisation admins only'; end if;
  with gone as (
    delete from coach_clients cc
     where cc.client_id = p_client
       and cc.source = 'cocoach'
       and cc.coach_id in (select user_id from org_members
                           where org_id = p_org and status = 'active')
    returning 1)
  select count(*) into v_n from gone;
  delete from org_clients where org_id = p_org and client_id = p_client;
  return v_n;
end $$;

-- Remove a coach. Their membership ends and every delegated link they hold to
-- one of THIS organisation's clients goes with it. Delegated links to clients
-- outside the gym's roster — a private one-to-one share — are left alone.
create or replace function org_remove_member(p_org uuid, p_user uuid)
returns integer language plpgsql security definer set search_path = public as $$
declare v_n integer; v_role text;
begin
  if not public.is_org_admin(p_org) then raise exception 'Organisation admins only'; end if;
  select role into v_role from org_members where org_id = p_org and user_id = p_user;
  if v_role is null then raise exception 'That coach is not in this organisation'; end if;
  if v_role = 'owner' and (select count(*) from org_members
                           where org_id = p_org and role='owner' and status='active') <= 1 then
    raise exception 'an organisation must keep at least one owner';
  end if;
  with gone as (
    delete from coach_clients cc
     where cc.coach_id = p_user
       and cc.source = 'cocoach'
       and cc.client_id in (select client_id from org_clients where org_id = p_org)
    returning 1)
  select count(*) into v_n from gone;
  update org_members set status = 'left' where org_id = p_org and user_id = p_user;
  return v_n;
end $$;

-- Leaving of your own accord clears the same delegated access, so a coach who
-- walks out cannot keep the gym's clients simply by not being removed.
create or replace function org_leave(p_org uuid)
returns integer language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  if not public.is_org_member(p_org) then raise exception 'You are not in that organisation'; end if;
  if (select role from org_members where org_id=p_org and user_id=auth.uid()) = 'owner'
     and (select count(*) from org_members where org_id=p_org and role='owner' and status='active') <= 1 then
    raise exception 'hand ownership to someone else before leaving';
  end if;
  with gone as (
    delete from coach_clients cc
     where cc.coach_id = auth.uid()
       and cc.source = 'cocoach'
       and cc.client_id in (select client_id from org_clients where org_id = p_org)
    returning 1)
  select count(*) into v_n from gone;
  update org_members set status='left' where org_id = p_org and user_id = auth.uid();
  return v_n;
end $$;

-- Sharing a client with a team makes them a client of the gym, so record that.
-- Without it the roster would miss them and org_remove_member would have nothing
-- to revoke, which is exactly the hole this migration closes.
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
  insert into org_clients (org_id, client_id, added_by)
    values (v_org, p_client, auth.uid())
  on conflict (org_id, client_id) do nothing;
  for r in select tm.user_id from org_team_members tm where tm.team_id = p_team and tm.user_id <> auth.uid()
  loop
    insert into coach_clients (coach_id, client_id, status, source, access, added_by)
      values (r.user_id, p_client, 'active', 'cocoach', p_access, auth.uid())
    on conflict (coach_id, client_id) do update set status='active', access=p_access, added_by=auth.uid();
    v_n := v_n + 1;
  end loop;
  return v_n;
end $$;

-- The gym's client roster, with how many of its coaches currently hold each one.
create or replace function org_client_list(p_org uuid)
returns table (client_id uuid, name text, sport text, coaches bigint, added_at timestamptz)
language sql stable security definer set search_path = public as $$
  select oc.client_id, p.name, p.sport,
         (select count(*) from coach_clients cc
           where cc.client_id = oc.client_id and cc.status='active'
             and cc.coach_id in (select user_id from org_members
                                 where org_id = p_org and status='active')),
         oc.added_at
  from org_clients oc join profiles p on p.id = oc.client_id
  where oc.org_id = p_org and public.is_org_member(p_org)
  order by p.name;
$$;

grant execute on function public.org_add_client(uuid,uuid) to authenticated;
grant execute on function public.org_remove_client(uuid,uuid) to authenticated;
grant execute on function public.org_remove_member(uuid,uuid) to authenticated;
grant execute on function public.org_leave(uuid) to authenticated;
grant execute on function public.org_client_list(uuid) to authenticated;
revoke execute on function public.org_add_client(uuid,uuid) from public, anon;
revoke execute on function public.org_remove_client(uuid,uuid) from public, anon;
revoke execute on function public.org_remove_member(uuid,uuid) from public, anon;
revoke execute on function public.org_leave(uuid) from public, anon;
revoke execute on function public.org_client_list(uuid) from public, anon;
grant select, insert, update, delete on org_clients to authenticated;
