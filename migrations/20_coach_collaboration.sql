-- 20: coaches working together — colleague connections, co-coached clients,
-- and shared groups, with a full/read-only access level on each.
--
-- Design notes:
--   * coach_clients was already UNIQUE(coach_id, client_id), so a client could
--     always have several coach rows. Adding a co-coach therefore reuses that
--     table, which means EVERY existing "is an active coach of this client"
--     read policy (body_metrics, weekly_checkins, fixtures, form_checks,
--     workouts, …) starts working for the second coach with no policy rewrite.
--   * What does need rewriting is the WRITE side, so that access='read' is a
--     real restriction rather than a label.
--   * is_group_coach() is the single gate every group policy already goes
--     through, so widening that one function shares a group with its staff.

-- ─────────────────────── 1. colleague connections ───────────────────────
-- A coach invites a colleague; the colleague accepts. This one DOES need
-- consent, because it is a person being added to someone's staff list.
create table if not exists coach_peers (
  id            uuid primary key default gen_random_uuid(),
  requester_id  uuid not null references profiles(id) on delete cascade,
  peer_id       uuid not null references profiles(id) on delete cascade,
  status        text not null default 'pending' check (status in ('pending','active','declined')),
  created_at    timestamptz default now(),
  unique (requester_id, peer_id),
  constraint coach_peers_not_self check (requester_id <> peer_id)
);
create index if not exists coach_peers_peer_idx on coach_peers (peer_id, status);

alter table coach_peers enable row level security;

drop policy if exists peers_read_own on coach_peers;
create policy peers_read_own on coach_peers
  for select using (requester_id = auth.uid() or peer_id = auth.uid());

drop policy if exists peers_invite on coach_peers;
create policy peers_invite on coach_peers
  for insert with check (requester_id = auth.uid() and public.is_approved_coach());

-- Only the invited colleague answers the invitation.
drop policy if exists peers_respond on coach_peers;
create policy peers_respond on coach_peers
  for update using (peer_id = auth.uid()) with check (peer_id = auth.uid());

drop policy if exists peers_remove on coach_peers;
create policy peers_remove on coach_peers
  for delete using (requester_id = auth.uid() or peer_id = auth.uid());

-- Neither side may rewrite who the connection is between.
create or replace function coach_peers_guard() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.requester_id is distinct from old.requester_id
     or new.peer_id is distinct from old.peer_id then
    raise exception 'the parties to a connection are immutable';
  end if;
  return new;
end $$;
drop trigger if exists coach_peers_guard_trg on coach_peers;
create trigger coach_peers_guard_trg before update on coach_peers
  for each row execute function coach_peers_guard();
revoke execute on function public.coach_peers_guard() from public, anon, authenticated;

-- Connected in either direction.
create or replace function are_peers(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from coach_peers
    where status = 'active'
      and ((requester_id = a and peer_id = b) or (requester_id = b and peer_id = a))
  );
$$;

-- ─────────────────── 2. access level on a coach-client link ───────────────────
alter table coach_clients add column if not exists access text not null default 'full';
do $$ begin
  alter table coach_clients add constraint coach_clients_access_chk
    check (access in ('full','read'));
exception when duplicate_object then null; end $$;
-- Who brought this coach in (null = they connected with the client directly).
alter table coach_clients add column if not exists added_by uuid references profiles(id) on delete set null;

-- Read gate (any access level) and write gate (full only). Both are referenced
-- from RLS policies, so they MUST keep EXECUTE for anon and authenticated —
-- policies are evaluated as the querying role, and revoking it here would break
-- every coach read in the app.
create or replace function coach_of_client(c uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from coach_clients
                 where coach_id = auth.uid() and client_id = c and status = 'active');
$$;
create or replace function coach_can_edit(c uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from coach_clients
                 where coach_id = auth.uid() and client_id = c
                   and status = 'active' and access = 'full');
$$;
grant execute on function public.coach_of_client(uuid) to anon, authenticated;
grant execute on function public.coach_can_edit(uuid) to anon, authenticated;

-- ────────── 3. make access='read' actually read-only on the write paths ──────────
-- A read-only coach keeps every read, and may still message the athlete
-- (a physio or head coach who cannot reply is useless), but cannot change the
-- training plan or the athlete's records.

-- fixtures
drop policy if exists coach_insert_client_fixtures on fixtures;
create policy coach_insert_client_fixtures on fixtures
  for insert with check (created_by = auth.uid() and public.coach_can_edit(client_id));
drop policy if exists coach_update_client_fixtures on fixtures;
create policy coach_update_client_fixtures on fixtures
  for update using (public.coach_can_edit(client_id))
  with check (public.coach_can_edit(client_id));
drop policy if exists coach_delete_client_fixtures on fixtures;
create policy coach_delete_client_fixtures on fixtures
  for delete using (public.coach_can_edit(client_id));

-- form check feedback
drop policy if exists "form_checks coach insert" on form_checks;
create policy "form_checks coach insert" on form_checks
  for insert with check (auth.uid() = coach_id and public.coach_can_edit(client_id));
drop policy if exists "form_checks coach update" on form_checks;
create policy "form_checks coach update" on form_checks
  for update using (auth.uid() = coach_id and public.coach_can_edit(client_id))
  with check (auth.uid() = coach_id and public.coach_can_edit(client_id));

-- nutrition targets
drop policy if exists coach_insert_client_targets on nutrition_targets;
create policy coach_insert_client_targets on nutrition_targets
  for insert with check (set_by = auth.uid() and public.coach_can_edit(client_id));

-- ─────────────────────── 4. shared groups ───────────────────────
create table if not exists coach_group_staff (
  group_id  uuid not null references coach_groups(id) on delete cascade,
  coach_id  uuid not null references profiles(id) on delete cascade,
  access    text not null default 'full' check (access in ('full','read')),
  added_by  uuid references profiles(id) on delete set null,
  added_at  timestamptz default now(),
  primary key (group_id, coach_id)
);
alter table coach_group_staff enable row level security;

-- Owner manages staff; staff can see who else is on the group.
-- Both sides of the coach_groups <-> coach_group_staff pair must go through a
-- SECURITY DEFINER helper. Writing either policy as a plain EXISTS subquery on
-- the other table makes the two policies call each other and Postgres raises
-- "infinite recursion detected in policy" on every group read.
create or replace function is_group_owner(g uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from coach_groups where id = g and coach_id = auth.uid());
$$;
grant execute on function public.is_group_owner(uuid) to anon, authenticated;

drop policy if exists group_owner_manages_staff on coach_group_staff;
create policy group_owner_manages_staff on coach_group_staff
  for all using (public.is_group_owner(group_id))
  with check (public.is_group_owner(group_id));
drop policy if exists group_staff_read_staff on coach_group_staff;
create policy group_staff_read_staff on coach_group_staff
  for select using (coach_id = auth.uid());

-- Widening this one function shares group_members and group_messages with staff,
-- because those policies already route through it.
create or replace function is_group_coach(g uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from coach_groups where id = g and coach_id = auth.uid())
      or exists (select 1 from coach_group_staff where group_id = g and coach_id = auth.uid());
$$;
-- Write gate for groups: the owner, or staff with full access.
create or replace function is_group_editor(g uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from coach_groups where id = g and coach_id = auth.uid())
      or exists (select 1 from coach_group_staff
                 where group_id = g and coach_id = auth.uid() and access = 'full');
$$;
grant execute on function public.is_group_coach(uuid) to anon, authenticated;
grant execute on function public.is_group_editor(uuid) to anon, authenticated;

-- Adding/removing members is an edit; reading the roster is not. These are split
-- per command on purpose: a FOR ALL policy checks only USING on DELETE, so a
-- single policy with using(is_group_coach) would let a read-only coach remove
-- members even though WITH CHECK named the editor gate.
drop policy if exists coach_manage_members on group_members;
drop policy if exists staff_read_members on group_members;
create policy staff_read_members on group_members
  for select using (public.is_group_coach(group_id));
drop policy if exists editor_add_members on group_members;
create policy editor_add_members on group_members
  for insert with check (public.is_group_editor(group_id));
drop policy if exists editor_update_members on group_members;
create policy editor_update_members on group_members
  for update using (public.is_group_editor(group_id))
  with check (public.is_group_editor(group_id));
drop policy if exists editor_delete_members on group_members;
create policy editor_delete_members on group_members
  for delete using (public.is_group_editor(group_id));

-- Staff need to see the group row itself — again via the definer helper, not a
-- direct subquery on coach_group_staff (see the recursion note above).
drop policy if exists staff_read_groups on coach_groups;
create policy staff_read_groups on coach_groups
  for select using (public.is_group_coach(id));

-- ─────────────────────── 5. the operations ───────────────────────
-- Inserting a coach_clients row for ANOTHER coach cannot be expressed as an RLS
-- policy (the row's coach_id is not auth.uid()), so these are checked RPCs.

create or replace function coach_add_cocoach(p_client uuid, p_peer uuid, p_access text default 'full')
returns text language plpgsql security definer set search_path = public as $$
declare v_name text;
begin
  if not public.coach_can_edit(p_client) then
    raise exception 'You need full access to this client to add a colleague';
  end if;
  if not public.are_peers(auth.uid(), p_peer) then
    raise exception 'You are not connected with that coach';
  end if;
  if p_access not in ('full','read') then raise exception 'Invalid access level'; end if;
  if p_peer = p_client then raise exception 'A client cannot be their own coach'; end if;
  insert into coach_clients (coach_id, client_id, status, source, access, added_by)
    values (p_peer, p_client, 'active', 'cocoach', p_access, auth.uid())
  on conflict (coach_id, client_id)
    do update set status = 'active', access = p_access, added_by = auth.uid();
  select name into v_name from profiles where id = p_peer;
  return coalesce(v_name, 'coach');
end $$;

create or replace function coach_remove_cocoach(p_client uuid, p_peer uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.coach_can_edit(p_client) then
    raise exception 'You need full access to this client';
  end if;
  if p_peer = auth.uid() then
    raise exception 'Use the normal disconnect to remove yourself';
  end if;
  -- Only a link that was delegated may be withdrawn this way; a coach the
  -- athlete connected with themselves is not yours to remove.
  delete from coach_clients
   where client_id = p_client and coach_id = p_peer and source = 'cocoach';
end $$;

create or replace function group_add_staff(p_group uuid, p_peer uuid, p_access text default 'full')
returns text language plpgsql security definer set search_path = public as $$
declare v_owner uuid; v_name text;
begin
  select coach_id into v_owner from coach_groups where id = p_group;
  if v_owner is null then raise exception 'No such group'; end if;
  if v_owner <> auth.uid() then raise exception 'Only the group owner can add coaches'; end if;
  if not public.are_peers(auth.uid(), p_peer) then
    raise exception 'You are not connected with that coach';
  end if;
  if p_access not in ('full','read') then raise exception 'Invalid access level'; end if;
  if p_peer = v_owner then raise exception 'You already own this group'; end if;
  insert into coach_group_staff (group_id, coach_id, access, added_by)
    values (p_group, p_peer, p_access, auth.uid())
  on conflict (group_id, coach_id) do update set access = p_access;
  select name into v_name from profiles where id = p_peer;
  return coalesce(v_name, 'coach');
end $$;

create or replace function group_remove_staff(p_group uuid, p_peer uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_owner uuid;
begin
  select coach_id into v_owner from coach_groups where id = p_group;
  if v_owner <> auth.uid() then raise exception 'Only the group owner can remove coaches'; end if;
  delete from coach_group_staff where group_id = p_group and coach_id = p_peer;
end $$;

-- ─────────────────────── 6. minimal name lookups ───────────────────────
-- profiles carries the athlete's own health data (injuries, bodyweight), so
-- rather than widening its RLS these return only the columns actually needed.

-- A coach's colleague list.
create or replace function my_peers()
returns table (peer_id uuid, name text, status text, i_invited boolean)
language sql stable security definer set search_path = public as $$
  select case when p.requester_id = auth.uid() then p.peer_id else p.requester_id end,
         pr.name, p.status, (p.requester_id = auth.uid())
  from coach_peers p
  join profiles pr on pr.id = case when p.requester_id = auth.uid() then p.peer_id else p.requester_id end
  where p.requester_id = auth.uid() or p.peer_id = auth.uid();
$$;

-- Everyone coaching one client — for the coach's client view.
create or replace function client_coaches(p_client uuid)
returns table (coach_id uuid, name text, access text, source text)
language sql stable security definer set search_path = public as $$
  select cc.coach_id, pr.name, cc.access, cc.source
  from coach_clients cc join profiles pr on pr.id = cc.coach_id
  where cc.client_id = p_client and cc.status = 'active'
    and public.coach_of_client(p_client);
$$;

-- The athlete's own "who can see my data" list. The user chose not to require
-- client consent for a co-coach, so the athlete gets visibility instead.
create or replace function my_coaches()
returns table (coach_id uuid, name text, access text, since timestamptz)
language sql stable security definer set search_path = public as $$
  select cc.coach_id, pr.name, cc.access, cc.created_at
  from coach_clients cc join profiles pr on pr.id = cc.coach_id
  where cc.client_id = auth.uid() and cc.status = 'active';
$$;

-- Staff on a group, for the group modal.
create or replace function group_staff(p_group uuid)
returns table (coach_id uuid, name text, access text, is_owner boolean)
language sql stable security definer set search_path = public as $$
  select g.coach_id, pr.name, 'full'::text, true
    from coach_groups g join profiles pr on pr.id = g.coach_id
   where g.id = p_group and public.is_group_coach(p_group)
  union all
  select s.coach_id, pr.name, s.access, false
    from coach_group_staff s join profiles pr on pr.id = s.coach_id
   where s.group_id = p_group and public.is_group_coach(p_group);
$$;

grant execute on function public.coach_add_cocoach(uuid,uuid,text) to authenticated;
grant execute on function public.coach_remove_cocoach(uuid,uuid) to authenticated;
grant execute on function public.group_add_staff(uuid,uuid,text) to authenticated;
grant execute on function public.group_remove_staff(uuid,uuid) to authenticated;
grant execute on function public.my_peers() to authenticated;
grant execute on function public.client_coaches(uuid) to authenticated;
grant execute on function public.my_coaches() to authenticated;
grant execute on function public.group_staff(uuid) to authenticated;
grant execute on function public.are_peers(uuid,uuid) to authenticated;
grant select, insert, update, delete on coach_peers to authenticated;
grant select, insert, update, delete on coach_group_staff to authenticated;

-- ─────────────────── 7. colleague lookup by email ───────────────────
-- Returns ONLY the uuid, never a name or profile data, and only to a caller who
-- is themselves an approved coach — so it cannot be used to enumerate athletes.
create or replace function coach_lookup_by_email(p_email text)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_uid uuid;
begin
  if not public.is_approved_coach() then raise exception 'Approved coaches only'; end if;
  select id into v_uid from auth.users where lower(email) = lower(trim(p_email));
  if v_uid is null then return null; end if;
  if v_uid = auth.uid() then raise exception 'That is your own account'; end if;
  if not exists (select 1 from profiles where id = v_uid and coach_status = 'approved') then
    raise exception 'That user is not an approved coach';
  end if;
  return v_uid;
end $$;
revoke execute on function public.coach_lookup_by_email(text) from public, anon;
grant execute on function public.coach_lookup_by_email(text) to authenticated;

-- ─────────────────── 8. tighten the REST surface ───────────────────
-- These are all signed-in operations and every one already fails for anon
-- (auth.uid() is null), but there is no reason to expose them publicly.
--
-- DELIBERATELY NOT REVOKED: coach_can_edit, is_group_coach, is_group_editor and
-- is_group_owner are referenced from inside RLS policies. Policies are evaluated
-- as the querying role, so revoking anon's EXECUTE on those makes every
-- anonymous read raise "permission denied for function" — the regression that
-- took the app down when is_admin() was tightened this way.
revoke execute on function public.are_peers(uuid,uuid) from public, anon;
revoke execute on function public.coach_of_client(uuid) from public, anon;
revoke execute on function public.coach_add_cocoach(uuid,uuid,text) from public, anon;
revoke execute on function public.coach_remove_cocoach(uuid,uuid) from public, anon;
revoke execute on function public.group_add_staff(uuid,uuid,text) from public, anon;
revoke execute on function public.group_remove_staff(uuid,uuid) from public, anon;
revoke execute on function public.my_peers() from public, anon;
revoke execute on function public.my_coaches() from public, anon;
revoke execute on function public.client_coaches(uuid) from public, anon;
revoke execute on function public.group_staff(uuid) from public, anon;

-- ─────────────────── 9. names inside a shared group ───────────────────
-- The dashboard used to resolve member and chat-sender names from the VIEWING
-- coach's own client list, so a coach who had a group shared with them saw an
-- anonymous roster and messages signed "Member". Gated on is_group_coach, and
-- returns only display fields — never the athlete's health data.
create or replace function group_people(p_group uuid)
returns table (user_id uuid, name text, sport text, is_coach boolean)
language sql stable security definer set search_path = public as $$
  select m.client_id, pr.name, pr.sport, false
    from group_members m join profiles pr on pr.id = m.client_id
   where m.group_id = p_group and public.is_group_coach(p_group)
  union
  select g.coach_id, pr.name, null::text, true
    from coach_groups g join profiles pr on pr.id = g.coach_id
   where g.id = p_group and public.is_group_coach(p_group)
  union
  select s.coach_id, pr.name, null::text, true
    from coach_group_staff s join profiles pr on pr.id = s.coach_id
   where s.group_id = p_group and public.is_group_coach(p_group);
$$;
revoke execute on function public.group_people(uuid) from public, anon;
grant execute on function public.group_people(uuid) to authenticated;
