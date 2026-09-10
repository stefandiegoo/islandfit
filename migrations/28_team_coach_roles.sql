-- 28: a main coach and assistant coaches within a group.
--
-- org_team_members recorded only that a coach belongs to a group. A club needs
-- to say WHO RUNS it: one coach owns the group's programming and the rest
-- assist. This is a property of the membership, not of the coach — the same
-- person can lead one group and assist in another — so the role lives on the
-- join row.
--
-- Deliberately NOT an access grant. share_client_with_team() gives every coach
-- in the group the same access to a shared athlete; who leads is about
-- responsibility and display order, and changing that here would silently
-- alter who can edit an athlete's program.

alter table org_team_members add column if not exists role text
  not null default 'assistant' check (role in ('lead','assistant'));

-- A group has at most one main coach. A partial unique index states that as a
-- fact rather than leaving it to the application to remember.
create unique index if not exists org_team_members_one_lead
  on org_team_members (team_id) where role = 'lead';

-- Set the main coach: demote the incumbent and promote the named coach in one
-- statement, so the unique index above is never transiently violated.
create or replace function org_team_set_lead(p_team uuid, p_user uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_org uuid;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such group'; end if;
  if not public.is_org_admin(v_org) then raise exception 'Organisation admins only'; end if;
  if not exists (select 1 from org_team_members where team_id = p_team and user_id = p_user) then
    raise exception 'That coach is not in this group';
  end if;
  update org_team_members
     set role = case when user_id = p_user then 'lead' else 'assistant' end
   where team_id = p_team and (user_id = p_user or role = 'lead');
end $$;

-- Step down the main coach without removing them from the group.
create or replace function org_team_clear_lead(p_team uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_org uuid;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such group'; end if;
  if not public.is_org_admin(v_org) then raise exception 'Organisation admins only'; end if;
  update org_team_members set role = 'assistant' where team_id = p_team and role = 'lead';
end $$;

-- team_coaches() gains the group role and orders the main coach first. The
-- existing "role" column is the ORG role (owner/admin/coach) and is kept under
-- that name so current callers are unaffected.
--
-- Both of these gain a column, and `create or replace` cannot change a
-- function's return type — it errors out. They have to be dropped and rebuilt,
-- which also drops their grants, so those are reissued at the bottom.
drop function if exists public.team_coaches(uuid);
create or replace function team_coaches(p_team uuid)
returns table (user_id uuid, name text, role text, team_role text)
language sql stable security definer set search_path = public as $$
  select tm.user_id, p.name, m.role, tm.role
  from org_team_members tm
  join profiles p on p.id = tm.user_id
  left join org_members m on m.user_id = tm.user_id and m.org_id = public.team_org(p_team)
  where tm.team_id = p_team and public.is_org_member(public.team_org(p_team))
  order by case tm.role when 'lead' then 0 else 1 end, p.name;
$$;

-- Surface the main coach in the group list so the club overview can show it.
drop function if exists public.org_team_list(uuid);
create or replace function org_team_list(p_org uuid)
returns table (team_id uuid, name text, focus text, coaches bigint, lead_name text)
language sql stable security definer set search_path = public as $$
  select t.id, t.name, t.focus,
         (select count(*) from org_team_members tm where tm.team_id = t.id),
         (select p.name from org_team_members tm join profiles p on p.id = tm.user_id
           where tm.team_id = t.id and tm.role = 'lead' limit 1)
  from org_teams t where t.org_id = p_org and public.is_org_member(p_org)
  order by t.name;
$$;

grant execute on function public.org_team_set_lead(uuid,uuid) to authenticated;
grant execute on function public.org_team_clear_lead(uuid) to authenticated;
revoke execute on function public.org_team_set_lead(uuid,uuid) from public, anon;
revoke execute on function public.org_team_clear_lead(uuid) from public, anon;
-- Reissued because the two drops above took the old grants with them.
grant execute on function public.team_coaches(uuid) to authenticated;
grant execute on function public.org_team_list(uuid) to authenticated;
revoke execute on function public.team_coaches(uuid) from public, anon;
revoke execute on function public.org_team_list(uuid) from public, anon;
