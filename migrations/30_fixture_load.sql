-- 30: a season's worth of fixtures at once, minutes actually played, and the
-- load board the coach reads them through.
--
-- Migration 19 gave every athlete a fixture list, one row at a time. A coach
-- does not plan one game at a time: a schedule arrives as a table for a whole
-- squad, and the reason to hold it is to see load building up before it turns
-- into an injury. Three things were missing, and all three live here.
--
-- 1. MINUTES. A fixture on the calendar says nothing about what it cost the
--    player. Two athletes at the same game did 90 minutes and 0. Load is per
--    person, so minutes are per person, recorded after the fact.
-- 2. A BATCH WRITER. Twenty athletes × twelve games is 240 rows, and the
--    coach must be able to hand them over in one action, with the athletes
--    they unticked genuinely left out.
-- 3. A READ MODEL. The signals that say "this player is in the red" sit in
--    five different tables. The dashboard should ask once.

alter table fixtures add column if not exists minutes int
  check (minutes is null or minutes between 0 and 240);

-- Nullable on purpose: null is "not logged yet", which is different from
-- 'absent'. A coach seeing a blank knows to ask; a zero would be a claim.
alter table fixtures add column if not exists participation text
  check (participation is null or participation in ('full','part','bench','absent'));

-- Which squad the fixture came from, so a schedule entered for a team can be
-- corrected or withdrawn as the batch it was, not row by row. ON DELETE SET
-- NULL: deleting a team must never delete an athlete's game history.
alter table fixtures add column if not exists team_id uuid
  references org_teams(id) on delete set null;

create index if not exists fixtures_team_date_idx
  on fixtures (team_id, fixture_date) where team_id is not null;

-- ── Batch writer ─────────────────────────────────────────────────────────────
-- Rows arrive as jsonb so one call covers both entry routes the coach has:
-- a pasted schedule and hand-typed rows. Access is re-checked per athlete
-- inside the loop rather than once at the top, because the coach may pick a
-- squad containing someone they do not actually coach — those are reported as
-- `blocked` instead of failing the whole batch. Partial success with an honest
-- count is worth more than an all-or-nothing error on a squad of twenty.
create or replace function fixtures_bulk_add(
  p_clients uuid[], p_rows jsonb, p_team uuid default null
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_client uuid; v_row record; v_added int := 0; v_skipped int := 0;
  v_blocked int := 0; v_ok boolean;
begin
  if p_clients is null or array_length(p_clients,1) is null then
    raise exception 'No athletes selected';
  end if;
  if p_rows is null or jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) = 0 then
    raise exception 'No fixtures to add';
  end if;

  foreach v_client in array p_clients loop
    select exists (
      select 1 from coach_clients
      where coach_id = auth.uid() and client_id = v_client and status = 'active'
    ) into v_ok;
    if not v_ok then v_blocked := v_blocked + 1; continue; end if;

    for v_row in
      select * from jsonb_to_recordset(p_rows) as x(
        fixture_date date, kickoff time, opponent text, competition text,
        home_away text, importance text, notes text)
    loop
      if v_row.fixture_date is null then continue; end if;
      insert into fixtures (client_id, fixture_date, kickoff, opponent, competition,
                            home_away, importance, notes, team_id, created_by)
      values (v_client, v_row.fixture_date, v_row.kickoff,
              nullif(btrim(coalesce(v_row.opponent,'')),''),
              nullif(btrim(coalesce(v_row.competition,'')),''),
              case when v_row.home_away in ('home','away','neutral') then v_row.home_away end,
              case when v_row.importance in ('key','normal','minor') then v_row.importance else 'normal' end,
              nullif(btrim(coalesce(v_row.notes,'')),''),
              p_team, auth.uid())
      -- Matches the unique index from 19: re-pasting a schedule that has grown
      -- by two games adds the two and leaves the rest alone.
      on conflict (client_id, fixture_date, coalesce(opponent,'')) do nothing;
      if found then v_added := v_added + 1; else v_skipped := v_skipped + 1; end if;
    end loop;
  end loop;

  return jsonb_build_object('added', v_added, 'skipped', v_skipped, 'blocked', v_blocked);
end $$;

-- ── Minutes after the game ───────────────────────────────────────────────────
-- Either side may record them: the athlete knows what they played, the coach
-- picked the team. Both paths land in the same column so the load board does
-- not care who typed it.
create or replace function fixture_log_minutes(
  p_fixture uuid, p_minutes int, p_participation text default null
) returns void language plpgsql security definer set search_path = public as $$
declare v_client uuid;
begin
  select client_id into v_client from fixtures where id = p_fixture;
  if v_client is null then raise exception 'No such fixture'; end if;
  if v_client <> auth.uid() and not exists (
    select 1 from coach_clients
    where coach_id = auth.uid() and client_id = v_client and status = 'active'
  ) then
    raise exception 'Not your fixture';
  end if;
  update fixtures
     set minutes = p_minutes,
         participation = case when p_participation in ('full','part','bench','absent')
                              then p_participation else participation end
   where id = p_fixture;
end $$;

-- ── The load board ───────────────────────────────────────────────────────────
-- One row per athlete the coach actively coaches, with every signal the watch
-- uses side by side. Deliberately NOT a verdict: no thresholds, no colours, no
-- "at risk" flag. The numbers are facts about the last fortnight; what counts
-- as too much depends on the sport and the athlete, and that judgement belongs
-- to the coach reading it (and to what the assistant proposes), not to a view.
--
-- Training volume is split into this week and last week rather than summed,
-- because the ratio between them is the part that matters — a big week is
-- normal, a big week on top of a quiet one is the spike.
create or replace function coach_load_board(p_days int default 14)
returns table (
  client_id uuid, name text, sport text,
  games_ahead int, games_last_7 int, games_last_28 int,
  minutes_last_14 int, minutes_logged int, minutes_missing int,
  sessions_last_7 int, vol_this_week numeric, vol_prev_week numeric,
  rpe_last_7 numeric, energy int, sleep int, stress int,
  checkin_date date, next_date date, next_opponent text, next_importance text
) language sql stable security definer set search_path = public as $$
  with mine as (
    select cc.client_id from coach_clients cc
    where cc.coach_id = auth.uid() and cc.status = 'active'
  )
  select
    m.client_id,
    p.name, p.sport,
    (select count(*)::int from fixtures f where f.client_id = m.client_id
       and f.fixture_date between current_date and current_date + p_days),
    (select count(*)::int from fixtures f where f.client_id = m.client_id
       and f.fixture_date between current_date - 7 and current_date),
    (select count(*)::int from fixtures f where f.client_id = m.client_id
       and f.fixture_date between current_date - 28 and current_date),
    (select coalesce(sum(f.minutes),0)::int from fixtures f where f.client_id = m.client_id
       and f.fixture_date between current_date - 14 and current_date),
    (select count(*)::int from fixtures f where f.client_id = m.client_id
       and f.fixture_date between current_date - 14 and current_date and f.minutes is not null),
    -- Games already played with nothing recorded: the gap in the picture, shown
    -- rather than silently treated as zero load.
    (select count(*)::int from fixtures f where f.client_id = m.client_id
       and f.fixture_date between current_date - 14 and current_date and f.minutes is null),
    (select count(*)::int from workouts w where w.user_id = m.client_id
       and w.completed_at >= now() - interval '7 days'),
    (select coalesce(sum(s.reps * s.weight_kg),0) from workout_sets s where s.user_id = m.client_id
       and s.logged_at >= now() - interval '7 days'),
    (select coalesce(sum(s.reps * s.weight_kg),0) from workout_sets s where s.user_id = m.client_id
       and s.logged_at >= now() - interval '14 days' and s.logged_at < now() - interval '7 days'),
    (select round(avg(s.rpe),1) from workout_sets s where s.user_id = m.client_id
       and s.rpe is not null and s.logged_at >= now() - interval '7 days'),
    ci.energy, ci.sleep, ci.stress, ci.week_date,
    nx.fixture_date, nx.opponent, nx.importance
  from mine m
  join profiles p on p.id = m.client_id
  left join lateral (
    select c.energy, c.sleep, c.stress, c.week_date from weekly_checkins c
    where c.client_id = m.client_id order by c.week_date desc limit 1
  ) ci on true
  left join lateral (
    select f.fixture_date, f.opponent, f.importance from fixtures f
    where f.client_id = m.client_id and f.fixture_date >= current_date
    order by f.fixture_date limit 1
  ) nx on true
  order by p.name;
$$;

-- ── Assistant suggestions the coach signs off on ─────────────────────────────
-- The assistant may write here freely; nothing in this table reaches the
-- athlete until a coach approves it. That is the whole point of the table
-- existing instead of the suggestion being sent directly: it is a draft queue,
-- and the coach is the one who decides what the athlete is told to do.
create table if not exists load_advice (
  id           uuid primary key default gen_random_uuid(),
  coach_id     uuid not null references auth.users(id) on delete cascade,
  client_id    uuid not null references auth.users(id) on delete cascade,
  severity     text not null default 'watch' check (severity in ('red','watch','ok')),
  headline     text not null,
  detail       text,
  action_kind  text check (action_kind in ('deload','shift_session','extra_recovery','cap_minutes','no_change')),
  evidence     jsonb,
  status       text not null default 'pending' check (status in ('pending','approved','dismissed')),
  approved_at  timestamptz,
  created_at   timestamptz default now()
);

create index if not exists load_advice_coach_idx
  on load_advice (coach_id, status, created_at desc);

-- One live suggestion per athlete per coach: a re-run replaces the old draft
-- instead of stacking up a pile the coach has to wade through.
create unique index if not exists load_advice_one_pending
  on load_advice (coach_id, client_id) where status = 'pending';

alter table load_advice enable row level security;

drop policy if exists coach_rw_own_advice on load_advice;
create policy coach_rw_own_advice on load_advice
  for all using (coach_id = auth.uid()) with check (coach_id = auth.uid());

-- The athlete never reads this table. They see the message the coach approved,
-- in the inbox they already have — not a queue of machine guesses about them.

-- Approving is one step: the advice is stamped and the athlete is told, in the
-- coach's own name, through the existing message thread.
create or replace function load_advice_approve(p_id uuid, p_message text default null)
returns void language plpgsql security definer set search_path = public as $$
declare v_row load_advice;
begin
  select * into v_row from load_advice where id = p_id and coach_id = auth.uid();
  if v_row.id is null then raise exception 'No such suggestion'; end if;
  update load_advice set status = 'approved', approved_at = now() where id = p_id;
  insert into coach_messages (coach_id, client_id, sender_id, body)
  values (auth.uid(), v_row.client_id, auth.uid(),
          coalesce(nullif(btrim(p_message),''), v_row.headline));
end $$;

grant select, insert, update, delete on load_advice to authenticated;
grant execute on function public.fixtures_bulk_add(uuid[],jsonb,uuid) to authenticated;
grant execute on function public.fixture_log_minutes(uuid,int,text) to authenticated;
grant execute on function public.coach_load_board(int) to authenticated;
grant execute on function public.load_advice_approve(uuid,text) to authenticated;
revoke execute on function public.fixtures_bulk_add(uuid[],jsonb,uuid) from public, anon;
revoke execute on function public.fixture_log_minutes(uuid,int,text) from public, anon;
revoke execute on function public.coach_load_board(int) from public, anon;
revoke execute on function public.load_advice_approve(uuid,text) from public, anon;
