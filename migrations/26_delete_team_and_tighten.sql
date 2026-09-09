-- 26: deleting a team, and one grant that should never have been there.
--
-- 1) Teams could be created and filled but not deleted, so a staff group that
--    was reorganised away sat in the panel forever.
-- 2) same_org(a,b) takes two user ids as parameters instead of reading
--    auth.uid(), and it was left executable by anon through the default PUBLIC
--    grant. That let an anonymous caller probe whether two user ids work at the
--    same gym. It is referenced by no RLS policy — only team_org is, by
--    org_team_members_read/_write — so taking the grant away breaks nothing.
--    (Checked first: revoking anon from a function a policy *does* use is what
--    broke every anonymous read once before, with is_admin().)

-- Delete a team. Memberships go with it via the on delete cascade on
-- org_team_members. Deliberately does NOT touch coach_clients: a client shared
-- through a team was shared with those coaches, not with the team object, and a
-- coach may hold the same client through another team or their own invite.
-- Ending client access is org_remove_client / org_remove_member's job.
create or replace function org_delete_team(p_team uuid)
returns integer language plpgsql security definer set search_path = public as $$
declare v_org uuid; v_n integer;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such team'; end if;
  if not public.is_org_admin(v_org) then raise exception 'Organisation admins only'; end if;
  select count(*) into v_n from org_team_members where team_id = p_team;
  delete from org_teams where id = p_team;
  return v_n;
end $$;

-- Renaming beats deleting and recreating when a team is only relabelled.
create or replace function org_rename_team(p_team uuid, p_name text)
returns void language plpgsql security definer set search_path = public as $$
declare v_org uuid;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such team'; end if;
  if not public.is_org_admin(v_org) then raise exception 'Organisation admins only'; end if;
  if coalesce(trim(p_name),'') = '' then raise exception 'A team needs a name'; end if;
  update org_teams set name = trim(p_name) where id = p_team;
end $$;

grant execute on function public.org_delete_team(uuid) to authenticated;
grant execute on function public.org_rename_team(uuid,text) to authenticated;
revoke execute on function public.org_delete_team(uuid) from public, anon;
revoke execute on function public.org_rename_team(uuid,text) from public, anon;

revoke execute on function public.same_org(uuid,uuid) from public, anon;
