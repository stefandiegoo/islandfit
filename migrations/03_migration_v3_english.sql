-- ÍslandFit v3 — English reset + unit preferences
-- Run this in Supabase SQL Editor (replaces all Icelandic program data)

-- Add units preference to profiles
alter table profiles add column if not exists units text default 'metric' check (units in ('metric','imperial'));
alter table profiles add column if not exists language text default 'en';

-- Reset all program data (keeps user workouts, sets, PRs untouched)
delete from program_exercises;
delete from program_workouts;
delete from programs;

-- ═══════════════════════════════════════════════════════════
-- INSERT ENGLISH PROGRAMS
-- ═══════════════════════════════════════════════════════════

do $$
declare
  p_basketball uuid := gen_random_uuid();
  p_soccer uuid := gen_random_uuid();
  p_strength uuid := gen_random_uuid();
  p_crossfit uuid := gen_random_uuid();
  w_bb_1 uuid := gen_random_uuid();
  w_bb_2 uuid := gen_random_uuid();
  w_bb_3 uuid := gen_random_uuid();
  w_bb_4 uuid := gen_random_uuid();
  w_sc_1 uuid := gen_random_uuid();
  w_sc_2 uuid := gen_random_uuid();
  w_sc_3 uuid := gen_random_uuid();
  w_sc_4 uuid := gen_random_uuid();
  w_st_1 uuid := gen_random_uuid();
  w_st_2 uuid := gen_random_uuid();
  w_st_3 uuid := gen_random_uuid();
  w_cf_1 uuid := gen_random_uuid();
  w_cf_2 uuid := gen_random_uuid();
  w_cf_3 uuid := gen_random_uuid();
  w_cf_4 uuid := gen_random_uuid();
begin

-- ─── BASKETBALL ──────────────────────────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_basketball, 'Basketball Foundation', 'Basketball', 'beginner', 4, 12,
   'Strength, explosiveness and speed for basketball players', 'ti-ball-basketball');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_bb_1, p_basketball, 1, 'Lower Body Strength', 'Legs · Power', 55),
  (w_bb_2, p_basketball, 2, 'Upper Body Strength', 'Chest · Back · Shoulders', 50),
  (w_bb_3, p_basketball, 3, 'Speed & Plyometrics', 'Vertical Jump · Speed', 45),
  (w_bb_4, p_basketball, 4, 'Full Body & Core', 'Conditioning · Mobility', 60);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_1, 1, 'Warm-up & Mobility', 1, '8 min', '—', 30, 'Light movement · prep hips and knees', 'ti-stretching'),
  (w_bb_1, 2, 'Back Squat', 4, '5', '80', 120, 'Feet shoulder-width · knees track toes · chest up', 'ti-barbell'),
  (w_bb_1, 3, 'Bulgarian Split Squat', 3, '8', '20', 90, 'Rear foot on bench · drop straight down · braced core', 'ti-walk'),
  (w_bb_1, 4, 'Box Jump', 4, '5', '24in', 90, 'Arm swing · explode from hips · soft landing', 'ti-arrow-up'),
  (w_bb_1, 5, 'Romanian Deadlift', 3, '8', '60', 90, 'Hinge at hips · bar close to legs · drive through glutes', 'ti-stretching'),
  (w_bb_1, 6, 'Calf Raise', 3, '15', '—', 60, 'Full range · 1 second hold at top', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_2, 1, 'Warm-up', 1, '5 min', '—', 30, 'Band pull-aparts · shoulder rotations', 'ti-stretching'),
  (w_bb_2, 2, 'Bench Press', 4, '6', '60', 120, 'Slight arch · bar to mid-chest · drive feet', 'ti-barbell'),
  (w_bb_2, 3, 'Pull-ups', 4, '6-8', '—', 90, 'Full range · chest to bar · controlled descent', 'ti-arrow-up'),
  (w_bb_2, 4, 'Dumbbell Shoulder Press', 3, '8', '15', 90, 'Sit tall · elbows under wrists · full lockout', 'ti-barbell'),
  (w_bb_2, 5, 'Bent Over Row', 3, '8', '50', 90, 'Flat back · pull to belly · elbows tight', 'ti-arrow-down'),
  (w_bb_2, 6, 'Face Pull', 3, '12', '15', 60, 'Cable to eye level · external rotation · pause', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_3, 1, 'Warm-up & A-skips', 2, '20m', '—', 30, 'High knees · rhythm focus', 'ti-run'),
  (w_bb_3, 2, 'Sprint 20m', 6, '20m', '—', 90, 'All out · 90% effort · full rest', 'ti-flame'),
  (w_bb_3, 3, 'Broad Jump', 4, '5', '—', 90, 'Arm swing · jump for distance · stick landing', 'ti-arrow-right'),
  (w_bb_3, 4, 'Lateral Bound', 3, '6 each', '—', 75, 'Side jump · stick on single leg · pause', 'ti-arrows-left-right'),
  (w_bb_3, 5, 'Pogo Hops', 4, '20', '—', 60, 'Low jumps · stiff ankles · quick contact', 'ti-arrow-up-bar'),
  (w_bb_3, 6, 'Cool Down', 1, '5 min', '—', 0, 'Slow jog · static stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_4, 1, 'Foam Roll', 1, '5 min', '—', 0, 'Slow · deep pressure on tight areas', 'ti-stretching'),
  (w_bb_4, 2, 'Goblet Squat', 3, '12', '24', 60, 'Dumbbell at chest · deep squat · upright torso', 'ti-barbell'),
  (w_bb_4, 3, 'Push-up', 3, '12-15', '—', 60, 'Body in line · chest to floor · full lockout', 'ti-arrow-up'),
  (w_bb_4, 4, 'Plank', 3, '60s', '—', 60, 'Hips in line · core braced · breathe deep', 'ti-square'),
  (w_bb_4, 5, 'Side Plank', 3, '30s each', '—', 45, 'Body straight · hip up · normal breathing', 'ti-square'),
  (w_bb_4, 6, 'Hanging Leg Raise', 3, '10', '—', 60, 'Hang from bar · legs to 90° · no swing', 'ti-arrow-up'),
  (w_bb_4, 7, 'Stretch & Mobility', 1, '10 min', '—', 0, 'Deep stretches · 30 sec holds', 'ti-stretching');

-- ─── SOCCER ──────────────────────────────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_soccer, 'Soccer Foundation', 'Soccer', 'beginner', 4, 12,
   'Endurance, footwork and strength for soccer players', 'ti-ball-football');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_sc_1, p_soccer, 1, 'Leg Strength', 'Legs · Stability', 55),
  (w_sc_2, p_soccer, 2, 'Endurance & Speed', 'Cardio · Sprints', 50),
  (w_sc_3, p_soccer, 3, 'Upper Body & Core', 'Full body · Stability', 45),
  (w_sc_4, p_soccer, 4, 'Footwork & Agility', 'Cone work · Quickness', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_1, 1, 'Dynamic Warm-up', 1, '10 min', '—', 0, 'A/B skips · leg swings · walking lunges', 'ti-run'),
  (w_sc_1, 2, 'Back Squat', 4, '6', '70', 120, 'Deep · controlled · drive up', 'ti-barbell'),
  (w_sc_1, 3, 'Single Leg RDL', 3, '8 each', '15', 90, 'Hinge at hip · one line from head to foot', 'ti-stretching'),
  (w_sc_1, 4, 'Walking Lunges', 3, '12 each', '20', 90, 'Long stride · drop knee · upright torso', 'ti-walk'),
  (w_sc_1, 5, 'Nordic Hamstring Curl', 3, '6', '—', 90, 'Slow descent · 3 sec hold · push up', 'ti-arrow-down'),
  (w_sc_1, 6, 'Copenhagen Plank', 3, '30s each', '—', 60, 'Inner thigh focus · hold in line', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_2, 1, 'Warm-up Jog', 1, '8 min', '—', 0, 'Easy pace · dynamic stretches', 'ti-run'),
  (w_sc_2, 2, '400m Tempo Run', 6, '400m', '—', 90, '80% effort · steady pace', 'ti-flame'),
  (w_sc_2, 3, '100m Sprints', 6, '100m', '—', 60, '90-95% effort · full recovery', 'ti-bolt'),
  (w_sc_2, 4, 'Shuttle Run', 4, '5x20m', '—', 90, 'Speed and turns · low center of gravity', 'ti-arrows-left-right'),
  (w_sc_2, 5, 'Cool Down Jog', 1, '5 min', '—', 0, 'Easy pace · controlled breathing', 'ti-run');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_3, 1, 'Warm-up', 1, '5 min', '—', 0, 'Arm circles · band work', 'ti-stretching'),
  (w_sc_3, 2, 'Push-up', 4, '12', '—', 60, 'Body in line · full range of motion', 'ti-arrow-up'),
  (w_sc_3, 3, 'Pull-up', 4, '6-8', '—', 90, 'Full range · vary grip', 'ti-arrow-up'),
  (w_sc_3, 4, 'Dumbbell Row', 3, '10 each', '20', 75, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w_sc_3, 5, 'Plank', 3, '45s', '—', 60, 'Hips in line · braced core', 'ti-square'),
  (w_sc_3, 6, 'Russian Twist', 3, '20', '8', 60, 'Sit · feet up · rotate side to side', 'ti-rotate');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_4, 1, 'Warm-up', 1, '8 min', '—', 0, 'Progressive cardio · ankle mobility', 'ti-run'),
  (w_sc_4, 2, 'Ladder Drills', 4, '6 patterns', '—', 60, 'Quick feet · light on toes · eyes up', 'ti-grid-dots'),
  (w_sc_4, 3, 'T-Drill', 4, '1 set', '—', 75, '5m forward · 5m side · 5m back', 'ti-arrows-cross'),
  (w_sc_4, 4, 'Box Drill (5m)', 4, '1 set', '—', 75, 'Forward · side · back · side · sprint', 'ti-square'),
  (w_sc_4, 5, 'Lateral Cone Hops', 3, '20 sec', '—', 60, 'Side hops over cone · light on toes', 'ti-arrows-left-right'),
  (w_sc_4, 6, 'Mobility & Stretch', 1, '10 min', '—', 0, 'Deep hip and leg stretches', 'ti-stretching');

-- ─── GENERAL STRENGTH (Push/Pull/Legs) ──────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_strength, 'General Strength', 'General', 'beginner', 3, 12,
   'Full body strength · 3x/week Push/Pull/Legs split', 'ti-barbell');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_st_1, p_strength, 1, 'Push (Chest & Shoulders)', 'Chest · Shoulders · Triceps', 50),
  (w_st_2, p_strength, 2, 'Pull (Back & Biceps)', 'Back · Biceps · Rear Delts', 50),
  (w_st_3, p_strength, 3, 'Legs & Core', 'Legs · Glutes · Core', 55);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_st_1, 1, 'Warm-up', 1, '5 min', '—', 0, 'Shoulder mobility · band pull-aparts', 'ti-stretching'),
  (w_st_1, 2, 'Bench Press', 4, '8', '60', 120, 'Slight arch · bar to mid-chest · drive feet', 'ti-barbell'),
  (w_st_1, 3, 'Overhead Press', 3, '8', '40', 90, 'Braced core · press straight up · full lockout', 'ti-arrow-up'),
  (w_st_1, 4, 'Incline Dumbbell Press', 3, '10', '17', 90, '30° incline · press up and slightly in', 'ti-barbell'),
  (w_st_1, 5, 'Tricep Dips', 3, '10-12', '—', 60, 'Elbows close to body · full range', 'ti-arrow-down'),
  (w_st_1, 6, 'Lateral Raise', 3, '12', '7', 60, 'Slow · elbows below wrists · 90° max', 'ti-arrows-left-right');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_st_2, 1, 'Warm-up', 1, '5 min', '—', 0, 'Light pulls · band work', 'ti-stretching'),
  (w_st_2, 2, 'Pull-ups', 4, '6-8', '—', 90, 'Full range · chest to bar · controlled', 'ti-arrow-up'),
  (w_st_2, 3, 'Barbell Row', 4, '8', '50', 90, 'Flat back · pull to belly', 'ti-arrow-down'),
  (w_st_2, 4, 'Lat Pulldown', 3, '10', '40', 75, 'Pull to chest · elbows down', 'ti-arrow-down'),
  (w_st_2, 5, 'Dumbbell Curl', 3, '10 each', '12', 60, 'Elbow pinned · full contraction', 'ti-rotate'),
  (w_st_2, 6, 'Face Pull', 3, '12', '15', 60, 'Cable to eyes · external rotation', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_st_3, 1, 'Warm-up', 1, '8 min', '—', 0, 'Hip mobility · bodyweight squats', 'ti-stretching'),
  (w_st_3, 2, 'Back Squat', 4, '8', '70', 120, 'Deep · controlled · drive up', 'ti-barbell'),
  (w_st_3, 3, 'Romanian Deadlift', 4, '8', '60', 90, 'Hinge at hips · bar close to legs', 'ti-stretching'),
  (w_st_3, 4, 'Bulgarian Split Squat', 3, '10 each', '20', 75, 'Rear foot on bench · drop straight', 'ti-walk'),
  (w_st_3, 5, 'Leg Curl', 3, '12', '30', 60, 'Slow · full range', 'ti-arrow-down'),
  (w_st_3, 6, 'Plank', 3, '60s', '—', 60, 'Hips in line · core braced', 'ti-square'),
  (w_st_3, 7, 'Hanging Leg Raise', 3, '10', '—', 60, 'Hang · legs to 90° · no swing', 'ti-arrow-up');

-- ─── CROSSFIT / FUNCTIONAL FITNESS ──────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_crossfit, 'Functional Fitness', 'CrossFit', 'intermediate', 4, 12,
   'High-intensity · Olympic lifts · Conditioning · WODs', 'ti-flame');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_cf_1, p_crossfit, 1, 'Olympic Lifts', 'Snatch · Clean & Jerk', 60),
  (w_cf_2, p_crossfit, 2, 'Strength + WOD', 'Squat + Metcon', 50),
  (w_cf_3, p_crossfit, 3, 'Gymnastics + Cardio', 'Pull-ups · Rowing', 45),
  (w_cf_4, p_crossfit, 4, 'Hero WOD', 'High-intensity full body', 55);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_1, 1, 'Warm-up', 1, '10 min', '—', 0, 'Mobility · light barbell work', 'ti-stretching'),
  (w_cf_1, 2, 'Power Snatch', 5, '3', '50', 120, 'Explode from hips · elbows high · solid grip', 'ti-bolt'),
  (w_cf_1, 3, 'Hang Clean', 5, '3', '60', 120, 'Hang position · explode up · full catch', 'ti-arrow-up'),
  (w_cf_1, 4, 'Push Jerk', 4, '3', '50', 90, 'Dip and drive · press under bar', 'ti-arrow-up-bar'),
  (w_cf_1, 5, 'Overhead Squat', 3, '5', '40', 90, 'Bar overhead · deep squat · stable', 'ti-barbell'),
  (w_cf_1, 6, 'Cool Down', 1, '5 min', '—', 0, 'Mobility · breathing', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_2, 1, 'Warm-up', 1, '8 min', '—', 0, 'Air squats · light barbell', 'ti-stretching'),
  (w_cf_2, 2, 'Back Squat', 5, '5', '90', 150, 'Heavy · deep · drive up', 'ti-barbell'),
  (w_cf_2, 3, 'WOD: 21-15-9', 1, 'AMRAP', '—', 0, 'Thrusters @ 40kg + Pull-ups · for time', 'ti-flame'),
  (w_cf_2, 4, 'Cool Down', 1, '5 min', '—', 0, 'Static stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_3, 1, 'Warm-up', 1, '8 min', '—', 0, 'Kipping practice · band work', 'ti-stretching'),
  (w_cf_3, 2, 'Strict Pull-ups', 5, '5', '—', 90, 'Slow · full range · no swing', 'ti-arrow-up'),
  (w_cf_3, 3, 'Handstand Practice', 5, '30s', '—', 60, 'Hold against wall · braced core', 'ti-arrow-up'),
  (w_cf_3, 4, 'Ring Dips', 4, '8', '—', 75, 'Stable rings · elbows in', 'ti-arrow-down'),
  (w_cf_3, 5, 'Row 500m', 4, '500m', '—', 120, 'All out · steady pace', 'ti-flame'),
  (w_cf_3, 6, 'Cool Down', 1, '5 min', '—', 0, 'Light stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_4, 1, 'Warm-up', 1, '10 min', '—', 0, 'Full body · mobility', 'ti-stretching'),
  (w_cf_4, 2, 'Hero WOD ''Murph''', 1, '1 round', '—', 0, '1mi run + 100 pull-ups + 200 push-ups + 300 squats + 1mi run', 'ti-flame'),
  (w_cf_4, 3, 'Cool Down', 1, '10 min', '—', 0, 'Easy jog · deep stretches', 'ti-stretching');

end $$;

-- Done! 4 programs · 14 workout days · ~80 exercises (all in English)
