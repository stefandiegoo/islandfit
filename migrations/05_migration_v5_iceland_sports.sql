-- ÍslandFit v5 — All major Icelandic sports
-- Adds programs for sports popular in Iceland
-- Run in Supabase SQL Editor AFTER migration_v3_english.sql

do $$
declare
  -- New sport programs
  p_handball uuid := gen_random_uuid();
  p_athletics uuid := gen_random_uuid();
  p_golf uuid := gen_random_uuid();
  p_swimming uuid := gen_random_uuid();
  p_volleyball uuid := gen_random_uuid();
  p_skiing uuid := gen_random_uuid();
  p_icehockey uuid := gen_random_uuid();
  p_tennis uuid := gen_random_uuid();
  p_gymnastics uuid := gen_random_uuid();
  p_climbing uuid := gen_random_uuid();
  p_horseriding uuid := gen_random_uuid();
  p_strongman uuid := gen_random_uuid();
  p_powerlifting uuid := gen_random_uuid();
  p_glima uuid := gen_random_uuid();
  p_mma uuid := gen_random_uuid();
  p_running uuid := gen_random_uuid();
  p_cycling uuid := gen_random_uuid();
  p_badminton uuid := gen_random_uuid();
  -- Workout UUIDs (one per program, kept simple — 4 days each)
  w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin

-- ════════════════════════════════════════
-- HANDBALL (Iceland's most popular sport)
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_handball, 'Handball Performance', 'Handball', 'beginner', 4, 12,
   'Explosive power, shoulder strength, and lateral movement for handball', 'ti-hand-grab');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_handball, 1, 'Lower Body Power', 'Legs · Explosive Jump', 55),
  (w2, p_handball, 2, 'Throwing Power', 'Shoulders · Core · Rotation', 50),
  (w3, p_handball, 3, 'Lateral Speed', 'Agility · Cutting', 45),
  (w4, p_handball, 4, 'Conditioning & Core', 'Endurance · Anti-rotation', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Dynamic Warm-up', 1, '8 min', '—', 30, 'Hip openers · ankle mobility · A-skips', 'ti-stretching'),
  (w1, 2, 'Back Squat', 4, '5', '80', 120, 'Deep · explosive concentric', 'ti-barbell'),
  (w1, 3, 'Trap Bar Deadlift', 4, '5', '90', 120, 'Push floor away · neutral spine', 'ti-barbell'),
  (w1, 4, 'Single Leg Box Jump', 4, '4 each', '24in', 90, 'Stick the landing · explosive drive', 'ti-arrow-up'),
  (w1, 5, 'Reverse Lunge', 3, '8 each', '20', 75, 'Step long · drop straight down', 'ti-walk'),
  (w1, 6, 'Calf Raise', 3, '15', '40', 60, 'Pause at top · controlled descent', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Shoulder Warm-up', 1, '8 min', '—', 30, 'Band pull-aparts · YTW · rotations', 'ti-stretching'),
  (w2, 2, 'Push Press', 4, '5', '50', 120, 'Dip and drive · lockout overhead', 'ti-arrow-up'),
  (w2, 3, 'Medicine Ball Slam', 4, '6', '6kg', 90, 'Full body extension · slam hard', 'ti-bolt'),
  (w2, 4, 'Rotational MB Throw', 3, '5 each', '5kg', 90, 'Rotate from hips · explosive release', 'ti-rotate'),
  (w2, 5, 'Cable Wood Chop', 3, '10 each', '20', 60, 'High to low rotation · brace core', 'ti-arrow-down'),
  (w2, 6, 'Plank', 3, '45s', '—', 60, 'Hips level · braced throughout', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Side shuffles · carioca · skips', 'ti-run'),
  (w3, 2, 'Lateral Bound', 4, '5 each', '—', 90, 'Stick single leg landing · pause', 'ti-arrows-left-right'),
  (w3, 3, '5-10-5 Pro Agility', 5, '1', '—', 90, 'Plant low · explode out of cut', 'ti-arrows-cross'),
  (w3, 4, 'Cone Reaction Drill', 4, '20 sec', '—', 75, 'Quick feet · stay athletic', 'ti-grid-dots'),
  (w3, 5, 'Lateral Sled Drag', 3, '20m each', '40', 90, 'Hips low · short choppy steps', 'ti-arrow-right'),
  (w3, 6, 'Cool Down', 1, '5 min', '—', 0, 'Light jog · stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '5 min', '—', 30, 'Light cardio · band work', 'ti-stretching'),
  (w4, 2, 'Pull-ups', 4, '6-8', '—', 90, 'Full hang · chest to bar', 'ti-arrow-up'),
  (w4, 3, 'Sled Push', 5, '20m', '60', 90, 'Drive through legs · low body angle', 'ti-arrow-right'),
  (w4, 4, 'Pallof Press', 3, '10 each', '15', 60, 'Resist rotation · breathe out', 'ti-square'),
  (w4, 5, 'Farmers Carry', 3, '30m', '25 each', 90, 'Tall posture · short fast steps', 'ti-grip'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Deep hip and shoulder stretches', 'ti-stretching');

-- ════════════════════════════════════════
-- ATHLETICS (Track & Field)
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_athletics, 'Athletics Foundation', 'Athletics', 'beginner', 4, 12,
   'Sprint speed, power development, and conditioning for track & field', 'ti-run');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_athletics, 1, 'Sprint Development', 'Acceleration · Top Speed', 60),
  (w2, p_athletics, 2, 'Lower Body Strength', 'Legs · Posterior Chain', 55),
  (w3, p_athletics, 3, 'Plyometrics & Power', 'Jump · Bound · Explode', 50),
  (w4, p_athletics, 4, 'Tempo & Core', 'Aerobic · Stability', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Sprint Warm-up', 1, '12 min', '—', 30, 'A-skips · B-skips · build-up runs', 'ti-run'),
  (w1, 2, '10m Acceleration', 6, '10m', '—', 90, 'Drive low · push the ground', 'ti-bolt'),
  (w1, 3, '30m Flying Sprint', 5, '30m', '—', 150, 'Smooth acceleration · max speed', 'ti-bolt'),
  (w1, 4, '60m Sprint', 4, '60m', '—', 180, 'Full effort · tall posture at top', 'ti-flame'),
  (w1, 5, 'Cool Down', 1, '8 min', '—', 0, 'Easy jog · static stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Mobility drills', 'ti-stretching'),
  (w2, 2, 'Back Squat', 4, '5', '85', 150, 'Heavy · drive up explosively', 'ti-barbell'),
  (w2, 3, 'Romanian Deadlift', 4, '6', '70', 120, 'Push hips back · hamstrings load', 'ti-stretching'),
  (w2, 4, 'Bulgarian Split Squat', 3, '8 each', '25', 90, 'Rear foot elevated · drop straight', 'ti-walk'),
  (w2, 5, 'Glute Bridge', 3, '10', '60', 75, 'Squeeze glutes at top · 2 sec hold', 'ti-arrow-up'),
  (w2, 6, 'Hip Flexor Stretch', 1, '5 min', '—', 0, 'Open up hips · 30 sec holds', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '10 min', '—', 30, 'Dynamic mobility', 'ti-stretching'),
  (w3, 2, 'Broad Jump', 5, '3', '—', 120, 'Arm swing · jump for distance', 'ti-arrow-right'),
  (w3, 3, 'Box Jump', 4, '5', '24in', 90, 'Land soft · stand tall', 'ti-arrow-up'),
  (w3, 4, 'Bounding', 4, '20m', '—', 120, 'Long strides · arm drive · float', 'ti-walk'),
  (w3, 5, 'Single Leg Hop', 3, '5 each', '—', 90, 'Stick each landing · stay balanced', 'ti-arrow-up'),
  (w3, 6, 'Cool Down', 1, '5 min', '—', 0, 'Easy stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Easy jog · drills', 'ti-run'),
  (w4, 2, 'Tempo Run', 6, '200m', '—', 60, '70-75% effort · relaxed form', 'ti-run'),
  (w4, 3, 'Plank Variations', 3, '45s', '—', 45, 'Front · side · side · breathe', 'ti-square'),
  (w4, 4, 'Dead Bug', 3, '10 each', '—', 60, 'Press low back to floor · slow', 'ti-arrows-left-right'),
  (w4, 5, 'Hanging Leg Raise', 3, '10', '—', 60, 'No swing · 90° hip flexion', 'ti-arrow-up'),
  (w4, 6, 'Mobility', 1, '10 min', '—', 0, 'Full body stretches', 'ti-stretching');

-- ════════════════════════════════════════
-- GOLF
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_golf, 'Golf Performance', 'Golf', 'beginner', 3, 12,
   'Rotational power, mobility, and stability for a longer drive', 'ti-golf');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_golf, 1, 'Rotational Power', 'Core · Hips · Swing Speed', 50),
  (w2, p_golf, 2, 'Strength & Stability', 'Legs · Back · Balance', 55),
  (w3, p_golf, 3, 'Mobility & Recovery', 'Thoracic · Hips · Wrists', 40);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Cat-cow · thoracic rotations · hip openers', 'ti-stretching'),
  (w1, 2, 'Medicine Ball Rotational Throw', 4, '6 each', '4kg', 75, 'Hips lead · release at impact', 'ti-rotate'),
  (w1, 3, 'Landmine Rotation', 3, '8 each', '15', 75, 'Rotate through hips · stable feet', 'ti-rotate'),
  (w1, 4, 'Cable Wood Chop', 3, '10 each', '20', 60, 'High to low · core engaged', 'ti-arrow-down'),
  (w1, 5, 'Pallof Press', 3, '10 each', '15', 60, 'Anti-rotation · hold 2 sec', 'ti-square'),
  (w1, 6, 'Stretch', 1, '5 min', '—', 0, 'Spine and hip stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Glute activation · band walks', 'ti-stretching'),
  (w2, 2, 'Goblet Squat', 4, '10', '24', 75, 'Upright torso · deep range', 'ti-barbell'),
  (w2, 3, 'Single Leg RDL', 3, '8 each', '15', 75, 'Hip hinge · stable balance', 'ti-stretching'),
  (w2, 4, 'Dumbbell Row', 3, '10 each', '17', 60, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w2, 5, 'Push-up', 3, '10', '—', 60, 'Solid plank · full range', 'ti-arrow-up'),
  (w2, 6, 'Side Plank', 3, '30s each', '—', 45, 'Hip up · body in line', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Foam Roll', 1, '8 min', '—', 30, 'Upper back · glutes · quads', 'ti-stretching'),
  (w3, 2, 'Thoracic Spine Rotations', 3, '8 each', '—', 30, 'Slow controlled rotation', 'ti-rotate'),
  (w3, 3, 'Hip 90/90 Stretch', 3, '30s each', '—', 30, 'Sit tall · breathe deep', 'ti-stretching'),
  (w3, 4, 'Wrist Mobility', 2, '8 each direction', '—', 20, 'Circles and flexion', 'ti-rotate'),
  (w3, 5, 'World''s Greatest Stretch', 3, '5 each', '—', 30, 'Lunge · rotate · reach', 'ti-stretching'),
  (w3, 6, 'Deep Breathing', 1, '5 min', '—', 0, 'Box breathing 4-4-4-4', 'ti-lungs');

-- ════════════════════════════════════════
-- SWIMMING
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_swimming, 'Swimmer Strength', 'Swimming', 'beginner', 4, 12,
   'Dryland training for swimmers — pull power, core stability, shoulder health', 'ti-pool');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_swimming, 1, 'Pull Power', 'Lats · Back · Pull Strength', 50),
  (w2, p_swimming, 2, 'Lower Body & Kick', 'Glutes · Hamstrings · Calves', 50),
  (w3, p_swimming, 3, 'Core & Stability', 'Anti-rotation · Endurance', 45),
  (w4, p_swimming, 4, 'Shoulder Health', 'Rotator Cuff · Mobility', 40);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder mobility · band work', 'ti-stretching'),
  (w1, 2, 'Pull-ups', 4, '6-8', '—', 90, 'Full hang · pull chest to bar', 'ti-arrow-up'),
  (w1, 3, 'Straight Arm Pulldown', 3, '12', '25', 60, 'Mimic swim pull · lats engaged', 'ti-arrow-down'),
  (w1, 4, 'Single Arm Row', 3, '10 each', '20', 60, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w1, 5, 'Face Pull', 3, '12', '15', 60, 'External rotation · pause', 'ti-arrow-left'),
  (w1, 6, 'Hanging Leg Raise', 3, '10', '—', 60, 'Hollow body position', 'ti-arrow-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Mobility · activation', 'ti-stretching'),
  (w2, 2, 'Romanian Deadlift', 4, '8', '60', 90, 'Push hips back · long hamstrings', 'ti-stretching'),
  (w2, 3, 'Bulgarian Split Squat', 3, '10 each', '15', 75, 'Rear foot elevated', 'ti-walk'),
  (w2, 4, 'Hip Thrust', 3, '10', '50', 75, 'Drive hips up · squeeze glutes', 'ti-arrow-up'),
  (w2, 5, 'Standing Calf Raise', 3, '15', '40', 60, 'Full range · pause at top', 'ti-arrow-bar-up'),
  (w2, 6, 'Glute Bridge Hold', 3, '30s', '—', 45, 'Squeeze glutes throughout', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w3, 2, 'Hollow Body Hold', 4, '30s', '—', 60, 'Lower back pressed down', 'ti-square'),
  (w3, 3, 'Plank', 3, '60s', '—', 60, 'Tight body · breathe', 'ti-square'),
  (w3, 4, 'Side Plank with Reach', 3, '8 each', '—', 60, 'Hip up · reach under and through', 'ti-rotate'),
  (w3, 5, 'Pallof Press', 3, '10 each', '15', 60, 'Anti-rotation', 'ti-square'),
  (w3, 6, 'Dead Bug', 3, '10 each', '—', 60, 'Slow controlled · low back flat', 'ti-arrows-left-right');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Foam Roll', 1, '5 min', '—', 30, 'Upper back · lats · pecs', 'ti-stretching'),
  (w4, 2, 'YTW Raises', 3, '8 each', '3', 60, 'Light weight · perfect form', 'ti-arrows-up-down'),
  (w4, 3, 'External Rotation', 3, '12 each', '5', 60, 'Elbow tucked · slow', 'ti-rotate'),
  (w4, 4, 'Scapular Pull-up', 3, '8', '—', 60, 'Hang · pull shoulder blades down', 'ti-arrow-up'),
  (w4, 5, 'Thoracic Mobility', 3, '8 each', '—', 30, 'Open chest · rotate', 'ti-rotate'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Full body · deep breathing', 'ti-stretching');

-- ════════════════════════════════════════
-- VOLLEYBALL
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_volleyball, 'Volleyball Power', 'Volleyball', 'beginner', 4, 12,
   'Vertical jump, shoulder power, and lateral quickness', 'ti-ball-volleyball');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_volleyball, 1, 'Vertical Jump', 'Plyometrics · Power', 50),
  (w2, p_volleyball, 2, 'Upper Body Power', 'Shoulders · Hitting Strength', 50),
  (w3, p_volleyball, 3, 'Lower Body Strength', 'Legs · Glutes', 55),
  (w4, p_volleyball, 4, 'Agility & Core', 'Lateral · Stability', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Dynamic · jump prep', 'ti-stretching'),
  (w1, 2, 'Box Jump', 5, '5', '24in', 90, 'Explosive · soft landing', 'ti-arrow-up'),
  (w1, 3, 'Approach Jump', 4, '5', '—', 90, 'Practice your spike approach', 'ti-arrow-up'),
  (w1, 4, 'Depth Jump', 3, '4', '18in', 120, 'Step off · jump immediately', 'ti-arrow-up'),
  (w1, 5, 'Squat Jump', 3, '6', '—', 90, 'Bodyweight · max height', 'ti-arrow-up'),
  (w1, 6, 'Cool Down', 1, '5 min', '—', 0, 'Light stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder prep', 'ti-stretching'),
  (w2, 2, 'Overhead Press', 4, '6', '45', 90, 'Press straight up · lockout', 'ti-arrow-up'),
  (w2, 3, 'Medicine Ball Overhead Slam', 4, '6', '5kg', 90, 'Full extension · slam down', 'ti-bolt'),
  (w2, 4, 'Pull-ups', 4, '6-8', '—', 90, 'Full range · controlled', 'ti-arrow-up'),
  (w2, 5, 'Dumbbell Push Press', 3, '8', '15', 75, 'Use legs to drive', 'ti-arrow-up'),
  (w2, 6, 'Face Pull', 3, '12', '15', 60, 'Shoulder health', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Glute activation', 'ti-stretching'),
  (w3, 2, 'Back Squat', 4, '5', '75', 120, 'Heavy · drive up', 'ti-barbell'),
  (w3, 3, 'Trap Bar Deadlift', 4, '5', '85', 120, 'Push floor away', 'ti-barbell'),
  (w3, 4, 'Walking Lunge', 3, '10 each', '20', 75, 'Long stride · drop knee', 'ti-walk'),
  (w3, 5, 'Romanian Deadlift', 3, '8', '60', 75, 'Hamstrings load', 'ti-stretching'),
  (w3, 6, 'Calf Raise', 3, '12', '40', 60, 'Slow eccentric', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Dynamic movement', 'ti-run'),
  (w4, 2, 'Lateral Bound', 4, '5 each', '—', 75, 'Stick the landing', 'ti-arrows-left-right'),
  (w4, 3, 'Cone Shuffle Drill', 4, '20 sec', '—', 75, 'Stay low · quick feet', 'ti-grid-dots'),
  (w4, 4, 'Plank', 3, '60s', '—', 60, 'Tight body', 'ti-square'),
  (w4, 5, 'Russian Twist', 3, '20', '8', 60, 'Rotate through core', 'ti-rotate'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Full body cool down', 'ti-stretching');

-- ════════════════════════════════════════
-- POWERLIFTING
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_powerlifting, 'Powerlifting Strength', 'Powerlifting', 'intermediate', 4, 12,
   'Build max strength in squat, bench, and deadlift', 'ti-barbell');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_powerlifting, 1, 'Squat Day', 'Max Squat · Accessories', 75),
  (w2, p_powerlifting, 2, 'Bench Day', 'Max Bench · Accessories', 70),
  (w3, p_powerlifting, 3, 'Deadlift Day', 'Max Deadlift · Accessories', 75),
  (w4, p_powerlifting, 4, 'Light Volume Day', 'Pump · Recovery · Form', 60);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hips · ankles · empty bar sets', 'ti-stretching'),
  (w1, 2, 'Back Squat', 5, '3', '90', 180, 'Tight setup · controlled descent · drive', 'ti-barbell'),
  (w1, 3, 'Front Squat', 3, '5', '60', 120, 'Upright torso · elbows high', 'ti-barbell'),
  (w1, 4, 'Bulgarian Split Squat', 3, '8 each', '20', 90, 'Quad emphasis', 'ti-walk'),
  (w1, 5, 'Leg Curl', 3, '10', '30', 75, 'Slow eccentric', 'ti-arrow-down'),
  (w1, 6, 'Plank', 3, '60s', '—', 60, 'Bracing practice', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '10 min', '—', 30, 'Shoulder mobility · empty bar', 'ti-stretching'),
  (w2, 2, 'Bench Press', 5, '3', '80', 180, 'Tight setup · pause on chest · drive', 'ti-barbell'),
  (w2, 3, 'Close Grip Bench', 4, '6', '60', 120, 'Elbows tucked', 'ti-barbell'),
  (w2, 4, 'Dumbbell Row', 4, '10 each', '25', 75, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w2, 5, 'Overhead Press', 3, '8', '40', 90, 'Strict press · core tight', 'ti-arrow-up'),
  (w2, 6, 'Face Pull', 3, '15', '15', 60, 'Rear delt health', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hip openers · empty bar pulls', 'ti-stretching'),
  (w3, 2, 'Conventional Deadlift', 5, '3', '110', 180, 'Tight back · push the floor', 'ti-barbell'),
  (w3, 3, 'Romanian Deadlift', 4, '6', '80', 120, 'Hamstring focus · push hips back', 'ti-stretching'),
  (w3, 4, 'Pull-ups', 4, '6-8', '—', 90, 'Wide grip · full range', 'ti-arrow-up'),
  (w3, 5, 'Barbell Row', 3, '8', '60', 90, 'Pendlay style', 'ti-arrow-down'),
  (w3, 6, 'Back Extension', 3, '10', '—', 60, 'Squeeze glutes at top', 'ti-arrow-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Full body mobility', 'ti-stretching'),
  (w4, 2, 'Goblet Squat', 4, '10', '24', 60, 'Light · perfect form', 'ti-barbell'),
  (w4, 3, 'Push-up', 4, '12', '—', 60, 'Strict form', 'ti-arrow-up'),
  (w4, 4, 'Single Leg RDL', 3, '8 each', '12', 60, 'Balance work', 'ti-stretching'),
  (w4, 5, 'Curl & Press', 3, '10', '12', 60, 'Bicep + shoulder pump', 'ti-rotate'),
  (w4, 6, 'Stretch', 1, '10 min', '—', 0, 'Recovery focus', 'ti-stretching');

-- ════════════════════════════════════════
-- ICE HOCKEY
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_icehockey, 'Hockey Performance', 'Ice Hockey', 'beginner', 4, 12,
   'Skating power, rotational strength, and conditioning', 'ti-skating');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_icehockey, 1, 'Skating Power', 'Hips · Glutes · Lateral', 55),
  (w2, p_icehockey, 2, 'Upper Body & Shot Power', 'Chest · Back · Core Rotation', 50),
  (w3, p_icehockey, 3, 'Conditioning', 'Anaerobic · Sprint Intervals', 45),
  (w4, p_icehockey, 4, 'Core & Stability', 'Anti-rotation · Endurance', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hip mobility · skater drills', 'ti-stretching'),
  (w1, 2, 'Front Squat', 4, '5', '60', 120, 'Upright posture · deep range', 'ti-barbell'),
  (w1, 3, 'Lateral Lunge', 3, '8 each', '20', 90, 'Push hip back · stay low', 'ti-arrows-left-right'),
  (w1, 4, 'Skater Hop', 4, '6 each', '—', 75, 'Side bound · stick landing', 'ti-arrows-left-right'),
  (w1, 5, 'Single Leg RDL', 3, '8 each', '15', 75, 'Balance · hamstrings', 'ti-stretching'),
  (w1, 6, 'Copenhagen Plank', 3, '20s each', '—', 60, 'Inner thigh strength', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder prep · band work', 'ti-stretching'),
  (w2, 2, 'Bench Press', 4, '6', '60', 90, 'Solid base · controlled', 'ti-barbell'),
  (w2, 3, 'Pull-ups', 4, '6-8', '—', 90, 'Full range · pause at top', 'ti-arrow-up'),
  (w2, 4, 'Cable Wood Chop', 4, '8 each', '20', 75, 'Mimic shot motion · explosive', 'ti-arrow-down'),
  (w2, 5, 'Medicine Ball Rotational Throw', 3, '6 each', '5kg', 75, 'Hips lead · release at peak', 'ti-rotate'),
  (w2, 6, 'Plank', 3, '60s', '—', 60, 'Strong core base', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Easy jog · dynamic', 'ti-run'),
  (w3, 2, 'Bike Sprints', 8, '30s', '—', 60, 'All out 30s · 60s rest', 'ti-bike'),
  (w3, 3, '40-yard Sprint', 6, '40 yd', '—', 90, 'Max effort', 'ti-bolt'),
  (w3, 4, 'Shuttle Run', 4, '5x20m', '—', 90, 'Turn fast · drive out', 'ti-arrows-left-right'),
  (w3, 5, 'Cool Down', 1, '5 min', '—', 0, 'Easy jog · stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w4, 2, 'Pallof Press', 4, '10 each', '15', 60, 'Resist rotation · breathe', 'ti-square'),
  (w4, 3, 'Side Plank', 3, '45s each', '—', 60, 'Hip up · solid line', 'ti-square'),
  (w4, 4, 'Dead Bug', 3, '10 each', '—', 60, 'Low back pressed down', 'ti-arrows-left-right'),
  (w4, 5, 'Bird Dog', 3, '8 each', '—', 45, 'Opposite arm/leg · controlled', 'ti-stretching'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Recovery focus', 'ti-stretching');

-- ════════════════════════════════════════
-- TENNIS
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_tennis, 'Tennis Performance', 'Tennis', 'beginner', 3, 12,
   'Rotational power, agility, and shoulder strength', 'ti-trophy');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_tennis, 1, 'Power & Rotation', 'Hips · Core · Serve Power', 55),
  (w2, p_tennis, 2, 'Lower Body & Speed', 'Legs · Footwork', 55),
  (w3, p_tennis, 3, 'Upper Body & Shoulder', 'Stability · Strength', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Dynamic · thoracic mobility', 'ti-stretching'),
  (w1, 2, 'Medicine Ball Rotational Throw', 4, '6 each', '5kg', 75, 'Hips lead · explosive', 'ti-rotate'),
  (w1, 3, 'Landmine Rotation', 3, '8 each', '20', 75, 'Stable feet · drive through core', 'ti-rotate'),
  (w1, 4, 'Cable Wood Chop', 3, '10 each', '20', 60, 'High to low · controlled', 'ti-arrow-down'),
  (w1, 5, 'Plank with Rotation', 3, '8 each', '—', 60, 'Anti-rotation challenge', 'ti-rotate'),
  (w1, 6, 'Russian Twist', 3, '20', '8', 60, 'Side to side', 'ti-rotate');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '10 min', '—', 30, 'Footwork drills · ladder', 'ti-run'),
  (w2, 2, 'Back Squat', 4, '6', '70', 90, 'Deep · controlled', 'ti-barbell'),
  (w2, 3, 'Lateral Bound', 4, '5 each', '—', 75, 'Single leg landing', 'ti-arrows-left-right'),
  (w2, 4, 'Ladder Drills', 4, '3 patterns', '—', 60, 'Quick feet · light contacts', 'ti-grid-dots'),
  (w2, 5, 'Cone Sprint', 4, '20m', '—', 75, 'Decel and reaccel', 'ti-bolt'),
  (w2, 6, 'Calf Raise', 3, '12', '40', 60, 'Slow eccentric', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder prep · YTW', 'ti-stretching'),
  (w3, 2, 'Overhead Press', 4, '6', '40', 90, 'Strict press · core braced', 'ti-arrow-up'),
  (w3, 3, 'Pull-ups', 4, '6-8', '—', 90, 'Full hang · chest to bar', 'ti-arrow-up'),
  (w3, 4, 'Dumbbell Row', 3, '10 each', '20', 60, 'Back focus', 'ti-arrow-down'),
  (w3, 5, 'External Rotation', 3, '12 each', '5', 60, 'Cuff strength', 'ti-rotate'),
  (w3, 6, 'Face Pull', 3, '15', '15', 60, 'Posture · rear delt', 'ti-arrow-left');

-- ════════════════════════════════════════
-- RUNNING (Distance / Road Running)
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_running, 'Runner Strength', 'Running', 'beginner', 3, 12,
   'Strength and stability work for runners — injury prevention + performance', 'ti-run');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_running, 1, 'Lower Body Strength', 'Glutes · Hamstrings · Calves', 50),
  (w2, p_running, 2, 'Core & Hip Stability', 'Anti-rotation · Glute Med', 45),
  (w3, p_running, 3, 'Upper Body & Form', 'Posture · Arm Drive', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Glute activation · ankle mobility', 'ti-stretching'),
  (w1, 2, 'Single Leg RDL', 4, '8 each', '15', 75, 'Hip hinge · balance', 'ti-stretching'),
  (w1, 3, 'Bulgarian Split Squat', 3, '10 each', '15', 75, 'Quad and glute focus', 'ti-walk'),
  (w1, 4, 'Calf Raise', 4, '15', '40', 60, 'Full range · single leg variation', 'ti-arrow-bar-up'),
  (w1, 5, 'Glute Bridge', 3, '12', '40', 60, 'Squeeze at top', 'ti-arrow-up'),
  (w1, 6, 'Nordic Hamstring', 3, '6', '—', 75, 'Slow eccentric · 3 sec', 'ti-arrow-down');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w2, 2, 'Plank', 4, '60s', '—', 60, 'Tight body', 'ti-square'),
  (w2, 3, 'Side Plank', 3, '45s each', '—', 60, 'Hip up · stable line', 'ti-square'),
  (w2, 4, 'Dead Bug', 3, '10 each', '—', 60, 'Slow controlled', 'ti-arrows-left-right'),
  (w2, 5, 'Clamshell', 3, '15 each', '—', 45, 'Glute med activation', 'ti-arrow-right'),
  (w2, 6, 'Bird Dog', 3, '10 each', '—', 45, 'Opposite limbs', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Upper body mobility', 'ti-stretching'),
  (w3, 2, 'Push-up', 4, '10', '—', 60, 'Full body tension', 'ti-arrow-up'),
  (w3, 3, 'Inverted Row', 3, '10', '—', 60, 'Pull chest to bar', 'ti-arrow-down'),
  (w3, 4, 'Dumbbell Row', 3, '10 each', '15', 60, 'Posture focus', 'ti-arrow-down'),
  (w3, 5, 'Face Pull', 3, '12', '12', 60, 'Counteract running posture', 'ti-arrow-left'),
  (w3, 6, 'Stretch', 1, '10 min', '—', 0, 'Hips · hamstrings · calves', 'ti-stretching');

-- ════════════════════════════════════════
-- CYCLING
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_cycling, 'Cyclist Strength', 'Cycling', 'beginner', 3, 12,
   'Build leg strength and core stability for cycling power', 'ti-bike');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_cycling, 1, 'Leg Power', 'Quads · Glutes · Hamstrings', 55),
  (w2, p_cycling, 2, 'Core & Back', 'Riding Posture · Stability', 45),
  (w3, p_cycling, 3, 'Single Leg & Balance', 'Imbalance Correction', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hip and knee mobility', 'ti-stretching'),
  (w1, 2, 'Back Squat', 4, '6', '70', 120, 'Deep · explosive', 'ti-barbell'),
  (w1, 3, 'Leg Press', 4, '8', '120', 90, 'Full range', 'ti-arrow-up'),
  (w1, 4, 'Walking Lunge', 3, '12 each', '20', 75, 'Long stride', 'ti-walk'),
  (w1, 5, 'Leg Curl', 3, '10', '30', 60, 'Slow eccentric', 'ti-arrow-down'),
  (w1, 6, 'Calf Raise', 3, '15', '40', 60, 'Full range', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w2, 2, 'Plank', 4, '60s', '—', 60, 'Solid line', 'ti-square'),
  (w2, 3, 'Side Plank', 3, '45s each', '—', 60, 'Hip up', 'ti-square'),
  (w2, 4, 'Superman Hold', 3, '20s', '—', 60, 'Back extension', 'ti-arrow-up'),
  (w2, 5, 'Cable Row', 3, '10', '40', 60, 'Posture support', 'ti-arrow-down'),
  (w2, 6, 'Face Pull', 3, '12', '12', 60, 'Counter cycling posture', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Single leg mobility', 'ti-stretching'),
  (w3, 2, 'Single Leg Squat', 3, '6 each', '—', 90, 'Balance · controlled', 'ti-walk'),
  (w3, 3, 'Bulgarian Split Squat', 3, '10 each', '15', 75, 'Rear foot elevated', 'ti-walk'),
  (w3, 4, 'Single Leg RDL', 3, '8 each', '15', 75, 'Hip hinge balance', 'ti-stretching'),
  (w3, 5, 'Single Leg Glute Bridge', 3, '10 each', '—', 60, 'Squeeze glute', 'ti-arrow-up'),
  (w3, 6, 'Stretch', 1, '10 min', '—', 0, 'Hip flexors · quads · calves', 'ti-stretching');

-- ════════════════════════════════════════
-- MMA / COMBAT SPORTS
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_mma, 'MMA Strength', 'MMA', 'intermediate', 4, 12,
   'Strength, power, and conditioning for combat athletes', 'ti-karate');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_mma, 1, 'Strength Day', 'Compound Lifts · Power', 60),
  (w2, p_mma, 2, 'Conditioning', 'Anaerobic · HIIT', 45),
  (w3, p_mma, 3, 'Power & Speed', 'Plyo · Explosive', 50),
  (w4, p_mma, 4, 'Grappling Strength', 'Grip · Core · Pull', 55);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Full body dynamic', 'ti-stretching'),
  (w1, 2, 'Trap Bar Deadlift', 4, '5', '90', 120, 'Tight back · push the floor', 'ti-barbell'),
  (w1, 3, 'Front Squat', 4, '5', '70', 120, 'Upright torso', 'ti-barbell'),
  (w1, 4, 'Overhead Press', 3, '6', '45', 90, 'Strict press', 'ti-arrow-up'),
  (w1, 5, 'Pull-ups', 3, '6-8', '—', 90, 'Full range', 'ti-arrow-up'),
  (w1, 6, 'Plank', 3, '60s', '—', 60, 'Bracing', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Dynamic mobility', 'ti-run'),
  (w2, 2, 'Burpee', 5, '10', '—', 60, 'Full extension · explosive', 'ti-arrow-up'),
  (w2, 3, 'Battle Ropes', 5, '30s', '—', 60, 'Max intensity', 'ti-arrows-left-right'),
  (w2, 4, 'Box Jump', 5, '5', '24in', 60, 'Explosive · soft landing', 'ti-arrow-up'),
  (w2, 5, 'Bike Sprint', 6, '30s', '—', 60, 'All out 30/60', 'ti-bike'),
  (w2, 6, 'Cool Down', 1, '5 min', '—', 0, 'Stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '10 min', '—', 30, 'Explosive prep', 'ti-stretching'),
  (w3, 2, 'Power Clean', 5, '3', '60', 120, 'Explosive triple extension', 'ti-bolt'),
  (w3, 3, 'Medicine Ball Slam', 4, '6', '8kg', 75, 'Full power · slam hard', 'ti-bolt'),
  (w3, 4, 'Broad Jump', 4, '5', '—', 90, 'Max distance', 'ti-arrow-right'),
  (w3, 5, 'Push-up Clap', 3, '6', '—', 75, 'Explosive push', 'ti-arrow-up'),
  (w3, 6, 'Plyo Lunge', 3, '8', '—', 75, 'Switch in air', 'ti-walk');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Pull prep · grip', 'ti-stretching'),
  (w4, 2, 'Pull-ups', 5, '6-8', '—', 90, 'Mixed grip', 'ti-arrow-up'),
  (w4, 3, 'Farmers Walk', 4, '30m', '30 each', 90, 'Grip · core · posture', 'ti-grip'),
  (w4, 4, 'Dumbbell Row', 4, '8 each', '25', 75, 'Heavy · controlled', 'ti-arrow-down'),
  (w4, 5, 'Towel Hang', 3, '30s', '—', 75, 'Grip endurance', 'ti-grip'),
  (w4, 6, 'Hanging Leg Raise', 3, '10', '—', 60, 'Strict form', 'ti-arrow-up');

end $$;

-- Add the remaining sports as simpler programs (1 default workout each for now — can be expanded)
-- This way users can still select them in onboarding even if programs are minimal

insert into programs (name, sport, level, days_per_week, duration_weeks, description, icon) values
  ('Gymnastics Foundation', 'Gymnastics', 'beginner', 3, 12, 'Strength, flexibility, and body control', 'ti-stretching'),
  ('Rock Climbing Strength', 'Rock Climbing', 'beginner', 3, 12, 'Grip, pulling power, and finger strength', 'ti-mountain'),
  ('Equestrian Performance', 'Equestrian', 'beginner', 3, 12, 'Core stability, balance, and leg strength for riding', 'ti-horse-toy'),
  ('Strongman Training', 'Strongman', 'intermediate', 4, 12, 'Maximal strength and event-specific power', 'ti-barbell'),
  ('Glíma Wrestling', 'Glíma', 'intermediate', 4, 12, 'Grip, hip mobility, and rotational strength for Icelandic wrestling', 'ti-karate'),
  ('Badminton Performance', 'Badminton', 'beginner', 3, 12, 'Lateral quickness, shoulder power, and footwork', 'ti-trophy'),
  ('Skiing & Snowboarding', 'Winter Sports', 'beginner', 3, 12, 'Leg endurance, balance, and core for the slopes', 'ti-ski-jumping');

-- Done! 18 sports total now available
