-- 29: athletes in a group, and assigning one program to all of them.
--
-- org_teams has meant a team of COACHES since migration 23. A club also wants
-- the other kind of group — "U18", "Meet prep" — a squad of athletes who train
-- the same plan. Rather than a second kind of group with its own name, the same
-- org_teams row can now hold athletes as well as coaches: the coaches who run
-- it, and the athletes they run it for.
--
-- Membership here grants NOTHING on its own. It is a roster, not an access
-- rule. share_client_with_team() remains the only thing that hands a coach
-- access to an athlete, so adding someone to a squad cannot quietly widen who
-- can read their data.

create table if not exists org_team_athletes (
  team_id    uuid not null references org_teams(id) on delete cascade,
  client_id  uuid not null references profiles(id) on delete cascade,
  added_by   uuid references profiles(id) on delete set null,
  added_at   timestamptz default now(),
  primary key (team_id, client_id)
);
create index if not exists org_team_athletes_client_idx on org_team_athletes (client_id);

alter table org_team_athletes enable row level security;

drop policy if exists org_team_athletes_read on org_team_athletes;
create policy org_team_athletes_read on org_team_athletes
  for select using (public.is_org_member(public.team_org(team_id)));
drop policy if exists org_team_athletes_write on org_team_athletes;
create policy org_team_athletes_write on org_team_athletes
  for all using (public.is_org_admin(public.team_org(team_id)))
  with check (public.is_org_admin(public.team_org(team_id)));

grant select, insert, update, delete on org_team_athletes to authenticated;

-- Put an athlete in a squad. They must already be on the club's roster, which
-- is what org_add_client / share_client_with_team establish — so a squad can
-- never reach someone the club has no relationship with.
create or replace function org_team_add_athlete(p_team uuid, p_client uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_org uuid;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such group'; end if;
  if not public.is_org_admin(v_org) then raise exception 'Organisation admins only'; end if;
  if not exists (select 1 from org_clients where org_id = v_org and client_id = p_client) then
    raise exception 'That athlete is not on the club roster';
  end if;
  insert into org_team_athletes (team_id, client_id, added_by)
    values (p_team, p_client, auth.uid())
  on conflict (team_id, client_id) do nothing;
end $$;

create or replace function org_team_remove_athlete(p_team uuid, p_client uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_org uuid;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such group'; end if;
  if not public.is_org_admin(v_org) then raise exception 'Organisation admins only'; end if;
  delete from org_team_athletes where team_id = p_team and client_id = p_client;
end $$;

-- The squad, with each athlete's current program, so the coach can see who is
-- about to be overwritten BEFORE assigning rather than after.
create or replace function org_team_athlete_list(p_team uuid)
returns table (client_id uuid, name text, sport text, program_id uuid,
               program_name text, can_edit boolean)
language sql stable security definer set search_path = public as $$
  select ta.client_id, p.name, p.sport, p.program_id, pr.name,
         public.coach_can_edit(ta.client_id)
  from org_team_athletes ta
  join profiles p on p.id = ta.client_id
  left join programs pr on pr.id = p.program_id
  where ta.team_id = p_team
    and public.is_org_member(public.team_org(p_team))
  order by p.name;
$$;

-- Assign one program to a whole squad.
--
-- Each athlete goes through coach_assign_program, the same call the per-client
-- Assign button makes, so peak dates, day resets and its own permission check
-- behave identically. An athlete the caller cannot edit is SKIPPED rather than
-- failing the batch — a partial success with an honest count is more useful to
-- a coach than an all-or-nothing error on a squad of twenty.
create or replace function team_assign_program(
  p_team uuid, p_program uuid, p_peak date default null, p_only uuid[] default null)
returns table (assigned integer, skipped integer)
language plpgsql security definer set search_path = public as $$
declare v_org uuid; v_ok integer := 0; v_skip integer := 0; r record;
begin
  v_org := public.team_org(p_team);
  if v_org is null then raise exception 'No such group'; end if;
  if not public.is_org_member(v_org) then raise exception 'You are not in that organisation'; end if;
  if not exists (select 1 from programs where id = p_program) then
    raise exception 'No such program';
  end if;
  for r in select ta.client_id from org_team_athletes ta
            where ta.team_id = p_team
              and (p_only is null or ta.client_id = any(p_only))
  loop
    begin
      if public.coach_can_edit(r.client_id) then
        perform public.coach_assign_program(r.client_id, p_program, p_peak);
        v_ok := v_ok + 1;
      else
        v_skip := v_skip + 1;
      end if;
    exception when others then
      v_skip := v_skip + 1;
    end;
  end loop;
  assigned := v_ok; skipped := v_skip; return next;
end $$;

-- Group list gains its athlete count.
drop function if exists org_team_list(uuid);
create or replace function org_team_list(p_org uuid)
returns table (team_id uuid, name text, focus text, coaches bigint,
               lead_name text, athletes bigint)
language sql stable security definer set search_path = public as $$
  select t.id, t.name, t.focus,
         (select count(*) from org_team_members tm where tm.team_id = t.id),
         (select p.name from org_team_members tm join profiles p on p.id = tm.user_id
           where tm.team_id = t.id and tm.role = 'lead' limit 1),
         (select count(*) from org_team_athletes ta where ta.team_id = t.id)
  from org_teams t where t.org_id = p_org and public.is_org_member(p_org)
  order by t.name;
$$;

grant execute on function public.org_team_add_athlete(uuid,uuid) to authenticated;
grant execute on function public.org_team_remove_athlete(uuid,uuid) to authenticated;
grant execute on function public.org_team_athlete_list(uuid) to authenticated;
grant execute on function public.team_assign_program(uuid,uuid,date,uuid[]) to authenticated;
grant execute on function public.org_team_list(uuid) to authenticated;
revoke execute on function public.org_team_add_athlete(uuid,uuid) from public, anon;
revoke execute on function public.org_team_remove_athlete(uuid,uuid) from public, anon;
revoke execute on function public.org_team_athlete_list(uuid) from public, anon;
revoke execute on function public.team_assign_program(uuid,uuid,date,uuid[]) from public, anon;
revoke execute on function public.org_team_list(uuid) from public, anon;
