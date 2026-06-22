-- ÍslandFit v2 — Auto-regulation & framfarir
-- Keyrðu þetta í SQL Editor (eftir fyrri migrations)

-- Bæta RPE dálki við workout_sets fyrir auto-regulation
alter table workout_sets add column if not exists rpe numeric;

-- Index fyrir hraðari lookup á síðustu frammistöðu
create index if not exists idx_workout_sets_user_exercise 
  on workout_sets(user_id, exercise_name, logged_at desc);

-- View sem sýnir vikulega heildarþyngd (volume)
create or replace view weekly_volume as
select 
  user_id,
  date_trunc('week', logged_at) as week,
  sum(weight_kg * reps) as total_volume_kg
from workout_sets
where weight_kg is not null
group by user_id, date_trunc('week', logged_at)
order by week;

-- View fyrir framfarir á hverri æfingu
create or replace view exercise_progression as
select 
  user_id,
  exercise_name,
  date_trunc('week', logged_at) as week,
  max(weight_kg) as max_weight,
  avg(weight_kg) as avg_weight,
  avg(rpe) as avg_rpe
from workout_sets
where weight_kg is not null
group by user_id, exercise_name, date_trunc('week', logged_at)
order by week;

-- Búið!
