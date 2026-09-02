-- 19: in-season fixture list, so training load can be planned around matches.
--
-- Both sides write here: an athlete knows their own games, a coach manages the
-- team's calendar. Coach access is gated on an ACTIVE coach_clients row, so a
-- disconnected coach immediately loses the athlete's schedule (same rule the
-- other client tables use).

create table if not exists fixtures (
  id            uuid primary key default gen_random_uuid(),
  client_id     uuid not null references auth.users(id) on delete cascade,
  fixture_date  date not null,
  kickoff       time,
  opponent      text,
  competition   text,
  home_away     text check (home_away in ('home','away','neutral')),
  importance    text not null default 'normal' check (importance in ('key','normal','minor')),
  notes         text,
  created_by    uuid references auth.users(id) on delete set null,
  created_at    timestamptz default now()
);

-- The athlete's calendar is always read date-ordered, and never for two clients at once.
create index if not exists fixtures_client_date_idx on fixtures (client_id, fixture_date);

-- One entry per client per day: a second match on the same date is a different
-- competition, not a duplicate row, and this stops double-taps creating twins.
create unique index if not exists fixtures_client_date_opp_uniq
  on fixtures (client_id, fixture_date, coalesce(opponent,''));

alter table fixtures enable row level security;

drop policy if exists client_rw_own_fixtures on fixtures;
create policy client_rw_own_fixtures on fixtures
  for all using (client_id = auth.uid()) with check (client_id = auth.uid());

drop policy if exists coach_read_client_fixtures on fixtures;
create policy coach_read_client_fixtures on fixtures
  for select using (exists (
    select 1 from coach_clients
    where coach_clients.coach_id = auth.uid()
      and coach_clients.client_id = fixtures.client_id
      and coach_clients.status = 'active'));

-- A coach may build the calendar, but only for a client they actively coach,
-- and created_by must be themselves so authorship cannot be forged.
drop policy if exists coach_insert_client_fixtures on fixtures;
create policy coach_insert_client_fixtures on fixtures
  for insert with check (created_by = auth.uid() and exists (
    select 1 from coach_clients
    where coach_clients.coach_id = auth.uid()
      and coach_clients.client_id = fixtures.client_id
      and coach_clients.status = 'active'));

drop policy if exists coach_update_client_fixtures on fixtures;
create policy coach_update_client_fixtures on fixtures
  for update using (exists (
    select 1 from coach_clients
    where coach_clients.coach_id = auth.uid()
      and coach_clients.client_id = fixtures.client_id
      and coach_clients.status = 'active'))
  with check (exists (
    select 1 from coach_clients
    where coach_clients.coach_id = auth.uid()
      and coach_clients.client_id = fixtures.client_id
      and coach_clients.status = 'active'));

drop policy if exists coach_delete_client_fixtures on fixtures;
create policy coach_delete_client_fixtures on fixtures
  for delete using (exists (
    select 1 from coach_clients
    where coach_clients.coach_id = auth.uid()
      and coach_clients.client_id = fixtures.client_id
      and coach_clients.status = 'active'));

-- A client must not be able to move a fixture onto someone else's calendar,
-- and neither side may rewrite who created it.
create or replace function fixtures_guard() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.client_id is distinct from old.client_id then
    raise exception 'client_id is immutable';
  end if;
  if new.created_by is distinct from old.created_by then
    raise exception 'created_by is immutable';
  end if;
  return new;
end $$;

drop trigger if exists fixtures_guard_trg on fixtures;
create trigger fixtures_guard_trg before update on fixtures
  for each row execute function fixtures_guard();

grant select, insert, update, delete on fixtures to authenticated;

-- A trigger function is never invoked through the REST API, so signed-in users
-- have no reason to hold EXECUTE on it (the security advisor flags it otherwise).
-- Safe here precisely because this one is NOT referenced inside an RLS policy —
-- unlike is_admin() and friends, which must keep their grants to be evaluated.
revoke execute on function public.fixtures_guard() from public, anon, authenticated;
