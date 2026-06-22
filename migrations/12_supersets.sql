-- ÍslandFit v12 — Supersets
-- Adds a superset grouping to program_exercises. Exercises in the same workout sharing the
-- same non-null superset_group are performed as a superset (alternate exercises each round,
-- rest only after the last exercise in the group).
-- Run in Supabase SQL Editor (anytime after programs exist). Idempotent.

alter table program_exercises add column if not exists superset_group text;

-- Demo: superset the last two accessories (order 5 & 6) on days 1 and 4 of the General
-- "Athletic Performance" program. Both pairs have matching set counts (3 × 3).
update program_exercises set superset_group = 'A'
where order_idx in (5,6)
  and workout_id in (
    select pw.id from program_workouts pw
    join programs p on p.id = pw.program_id
    where p.name = 'Athletic Performance' and pw.day_number in (1,4)
  );

-- Verify (optional):
-- select pw.day_number, pe.order_idx, pe.exercise_name, pe.superset_group
-- from program_exercises pe join program_workouts pw on pw.id=pe.workout_id
-- join programs p on p.id=pw.program_id
-- where p.name='Athletic Performance' order by pw.day_number, pe.order_idx;
