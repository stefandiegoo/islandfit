-- 33: a coach who leaves an organisation must leave its teams too.
--
-- Two faults found by walking a club and a franchise through two weeks.
--
-- FAULT 1 — the roster lies.
-- org_leave() and org_remove_member() set org_members.status='left' and strip
-- the coach's delegated clients, but neither touches org_team_members. The
-- departed coach stays on every team he was on. team_coaches() still lists him,
-- so the group panel shows him as staff, while every call he makes is refused
-- with "You are not in that organisation". The name is there and the person
-- cannot act.
--
-- FAULT 2 — anyone can be put on a team.
-- The write policy on org_team_members is
--
--     is_org_admin(team_org(team_id))
--
-- which checks that the person DOING the adding is an admin, and never that the
-- person BEING ADDED belongs to the organisation. An admin can therefore place
-- a stranger, or a coach who already left, onto a team roster.
--
-- Both have the same shape: team membership was never tied to organisation
-- membership. This ties them together at both ends — the policy stops the bad
-- insert, and the two removal paths clean up after themselves.

-- Membership test for a NAMED user, not the caller. The existing is_org_member()
-- reads auth.uid() and so cannot answer "is this other person a member?".
-- SECURITY DEFINER because it is used inside a policy on a table whose own
-- policies would otherwise have to be consulted to answer it.
create or replace function is_org_member_of(o uuid, u uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from org_members
                  where org_id = o and user_id = u and status = 'active');
$$;

-- Policies are evaluated as the querying role, so this must stay executable by
-- both roles (see the is_admin() incident in section 10).
grant execute on function public.is_org_member_of(uuid,uuid) to anon, authenticated;

drop policy if exists org_team_members_write on org_team_members;
create policy org_team_members_write on org_team_members
  for all
  using (public.is_org_admin(public.team_org(team_id)))
  with check (
    public.is_org_admin(public.team_org(team_id))
    and public.is_org_member_of(public.team_org(team_id), user_id)
  );

-- Leaving clears team seats as well as delegated clients.
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
  delete from org_team_members
   where user_id = auth.uid()
     and team_id in (select id from org_teams where org_id = p_org);
  update org_members set status='left' where org_id = p_org and user_id = auth.uid();
  return v_n;
end $$;

-- Being removed clears them too.
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
  delete from org_team_members
   where user_id = p_user
     and team_id in (select id from org_teams where org_id = p_org);
  update org_members set status = 'left' where org_id = p_org and user_id = p_user;
  return v_n;
end $$;

-- Clear the rows the old behaviour already left behind: anyone sitting on a
-- team of an organisation they are not an active member of.
delete from org_team_members tm
 where not public.is_org_member_of(public.team_org(tm.team_id), tm.user_id);

grant execute on function public.org_leave(uuid) to authenticated;
grant execute on function public.org_remove_member(uuid,uuid) to authenticated;
revoke execute on function public.org_leave(uuid) from public, anon;
revoke execute on function public.org_remove_member(uuid,uuid) from public, anon;
