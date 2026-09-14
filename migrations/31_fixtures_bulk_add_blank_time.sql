-- 31: a blank kick-off time must not fail the whole batch.
--
-- fixtures_bulk_add() declared its jsonb columns with their final SQL types:
--
--   jsonb_to_recordset(p_rows) as x(fixture_date date, kickoff time, ...)
--
-- The coach website always sends every field, using an empty string for the
-- ones the coach left blank. Casting "" to `time` raises
--
--   22007  invalid input syntax for type time: ""
--
-- and because the cast happens while the set is being expanded, it takes the
-- whole call with it — a pasted season of twenty games is rejected because
-- nobody typed a kick-off time. Most schedules do not carry one.
--
-- Caught by driving the real page rather than calling the RPC: the earlier
-- tests omitted `kickoff` entirely, so it arrived as NULL and cast cleanly. An
-- absent key and an empty string are not the same thing, and the browser sends
-- the second one.
--
-- The fix is to take every field as text and convert it here, where a blank can
-- be turned into NULL first. A row whose date is unusable is skipped rather
-- than fatal, for the same reason: one bad line out of twenty should cost that
-- line, not the paste.

create or replace function fixtures_bulk_add(
  p_clients uuid[], p_rows jsonb, p_team uuid default null
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_client uuid; v_row record; v_added int := 0; v_skipped int := 0;
  v_blocked int := 0; v_bad int := 0; v_ok boolean;
  v_date date; v_time time;
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
      -- Everything arrives as text; the casts happen below where '' can become
      -- NULL first.
      select * from jsonb_to_recordset(p_rows) as x(
        fixture_date text, kickoff text, opponent text, competition text,
        home_away text, importance text, notes text)
    loop
      begin
        v_date := nullif(btrim(coalesce(v_row.fixture_date,'')),'')::date;
        v_time := nullif(btrim(coalesce(v_row.kickoff,'')),'')::time;
      exception when others then
        -- An unreadable date or time costs this line, not the batch.
        v_bad := v_bad + 1; continue;
      end;
      if v_date is null then v_bad := v_bad + 1; continue; end if;

      insert into fixtures (client_id, fixture_date, kickoff, opponent, competition,
                            home_away, importance, notes, team_id, created_by)
      values (v_client, v_date, v_time,
              nullif(btrim(coalesce(v_row.opponent,'')),''),
              nullif(btrim(coalesce(v_row.competition,'')),''),
              case when v_row.home_away in ('home','away','neutral') then v_row.home_away end,
              case when v_row.importance in ('key','normal','minor') then v_row.importance else 'normal' end,
              nullif(btrim(coalesce(v_row.notes,'')),''),
              p_team, auth.uid())
      on conflict (client_id, fixture_date, coalesce(opponent,'')) do nothing;
      if found then v_added := v_added + 1; else v_skipped := v_skipped + 1; end if;
    end loop;
  end loop;

  -- 'bad' is new; older callers read only added/skipped/blocked and are
  -- unaffected by the extra key.
  return jsonb_build_object('added', v_added, 'skipped', v_skipped,
                            'blocked', v_blocked, 'bad', v_bad);
end $$;

grant execute on function public.fixtures_bulk_add(uuid[],jsonb,uuid) to authenticated;
revoke execute on function public.fixtures_bulk_add(uuid[],jsonb,uuid) from public, anon;
