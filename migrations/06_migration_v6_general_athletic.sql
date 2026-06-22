-- ÍslandFit v6 — General Athletic Performance (4-pillar balanced)
-- Adds a well-rounded "General" program covering all four athletic pillars:
--   Strength · Explosiveness · Speed · Endurance
-- Run in Supabase SQL Editor AFTER migration_v5_iceland_sports.sql. Safe to re-run (guarded).

do $$
declare
  p_general uuid := gen_random_uuid();
  w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  -- Idempotency guard: do not duplicate on re-run
  if exists (select 1 from programs where name = 'Athletic Performance' and sport = 'General') then
    raise notice 'Athletic Performance (General) already exists — skipping.';
    return;
  end if;

  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p_general, 'Athletic Performance', 'General', 'intermediate', 4, 12,
     'Balanced 4-pillar athletic development — strength, explosiveness, speed, and endurance in one week', 'ti-bolt');

  w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p_general, 1, 'Lower Strength & Power', 'Strength · Explosiveness', 55),
    (w2, p_general, 2, 'Upper Strength & Power', 'Strength · Explosiveness', 50),
    (w3, p_general, 3, 'Speed & Agility',        'Speed · Power',            45),
    (w4, p_general, 4, 'Conditioning & Core',    'Endurance · Engine',       40);

  -- DAY 1 — Lower Strength & Power (strength + explosive lower body)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1, 1, 'Dynamic Warm-up',     1, '8 min',  '—',   30,  'Hips · ankles · A-skips · build-ups',          'ti-stretching'),
    (w1, 2, 'Back Squat',          4, '5',      '80',  150, 'Brace · sit between the hips · drive up',       'ti-barbell'),
    (w1, 3, 'Trap Bar Deadlift',   3, '4',      '100', 150, 'Flat back · push the floor away',              'ti-barbell'),
    (w1, 4, 'Box Jump',            4, '4',      '—',   90,  'Explode up · full hip extension · land soft',   'ti-arrow-up'),
    (w1, 5, 'Walking Lunge',       3, '8 each', '20',  75,  'Long stride · tall torso · knee over toe',      'ti-walk'),
    (w1, 6, 'Pogo Hops',           3, '15',     '—',   45,  'Stiff ankles · minimal ground contact time',    'ti-bolt');

  -- DAY 2 — Upper Strength & Power (strength + explosive upper body)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2, 1, 'Dynamic Warm-up',     1, '6 min',   '—',  30,  'Band pull-aparts · shoulder circles',          'ti-stretching'),
    (w2, 2, 'Bench Press',         4, '5',       '70', 150, 'Tuck elbows · drive the feet · control down',   'ti-barbell'),
    (w2, 3, 'Push Press',          4, '3',       '50', 120, 'Dip-drive from the legs · punch overhead',      'ti-arrow-up'),
    (w2, 4, 'Weighted Pull-up',    4, '6',       '10', 120, 'Full hang · lead with the chest',              'ti-arrow-up'),
    (w2, 5, 'Med Ball Chest Pass', 4, '5',       '—',  75,  'Explosive throw · full extension',             'ti-bolt'),
    (w2, 6, 'Dumbbell Row',        3, '10 each', '28', 60,  'Flat back · pull to the hip',                  'ti-barbell'),
    (w2, 7, 'Hanging Knee Raise',  3, '12',      '—',  45,  'Control the swing · brace the core',           'ti-activity');

  -- DAY 3 — Speed & Agility (the speed pillar)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3, 1, 'Dynamic Warm-up',     1, '8 min',  '—', 30,  'Leg swings · A/B skips · progressive build-ups', 'ti-stretching'),
    (w3, 2, 'Sprint Intervals',    6, '30 m',   '—', 120, 'Max effort · full recovery between reps',         'ti-run'),
    (w3, 3, 'A-Skips',             3, '20 m',   '—', 60,  'Tall posture · drive the knee · quick contact',   'ti-run'),
    (w3, 4, 'Lateral Bounds',      4, '6 each', '—', 75,  'Push off the outside leg · stick the landing',    'ti-bolt'),
    (w3, 5, '5-10-5 Pro Agility',  5, '1 rep',  '—', 90,  'Low hips · plant hard · explode out of the cut',  'ti-target-arrow'),
    (w3, 6, 'Single-Leg Hops',     3, '8 each', '—', 60,  'Soft landings · stable knee · rhythmic',          'ti-bolt'),
    (w3, 7, 'Hip Mobility Flow',   1, '5 min',  '—', 0,   'Slow breathing · open the hips · cool down',      'ti-stretching');

  -- DAY 4 — Conditioning & Core (the endurance pillar)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4, 1, 'Warm-up Row/Bike',     1, '5 min',          '—', 30, 'Easy build until you break a sweat',      'ti-activity'),
    (w4, 2, 'Interval Conditioning',8, '30s on/30s off', '—', 30, 'Row · bike · or run · hard work efforts', 'ti-heart'),
    (w4, 3, 'Kettlebell Swing',     4, '15',             '24',60, 'Hip snap · brace · float the bell',       'ti-flame'),
    (w4, 4, 'Goblet Squat',         3, '12',             '20',45, 'Upright chest · controlled · steady pace','ti-barbell'),
    (w4, 5, 'Push-up',              3, '15',             '—', 45, 'Tight core · full range of motion',       'ti-activity'),
    (w4, 6, 'Plank',                3, '45s',            '—', 45, 'Straight line · brace hard · breathe',    'ti-activity'),
    (w4, 7, 'Cooldown Walk',        1, '5 min',          '—', 0,  'Nasal breathing · let the heart settle',  'ti-walk');

  raise notice 'Added Athletic Performance (General) — 4 balanced days.';
end $$;
