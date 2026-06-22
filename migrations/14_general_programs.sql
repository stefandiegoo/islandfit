-- ÍslandFit v14 — General training library (5 evidence-informed programs)
-- Original programs built on PUBLIC training principles (push/pull/legs split, novice linear
-- progression, dumbbell-only, bodyweight, powerbuilding). All loading is auto-managed by the app
-- %1RM (NSCA load chart) + RPE auto-regulation + periodization engine; target_weight is just a start.
-- Exercise names chosen to match the public-domain exercise library so every lift has a demo + how-to.
-- Run in Supabase SQL Editor anytime after programs exist. Each program is guarded (idempotent).

-- ===== Push Pull Legs =====
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid; w5 uuid; w6 uuid;
begin
  if exists (select 1 from programs where name='Push Pull Legs' and sport='General') then raise notice 'Push Pull Legs exists — skip'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Push Pull Legs','General','intermediate',6,8,'6-day push/pull/legs hypertrophy split · auto-loaded by the app''s %1RM + RPE engine','ti-barbell');
  w1:=gen_random_uuid();
  w2:=gen_random_uuid();
  w3:=gen_random_uuid();
  w4:=gen_random_uuid();
  w5:=gen_random_uuid();
  w6:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Push — Chest','Hypertrophy · chest/shoulders/triceps',60),
    (w2,p,2,'Pull — Back','Hypertrophy · back/biceps',60),
    (w3,p,3,'Legs','Hypertrophy · quads/hams/calves',65),
    (w4,p,4,'Push — Shoulders','Hypertrophy · shoulders/chest/triceps',60),
    (w5,p,5,'Pull — Width','Hypertrophy · back/biceps',60),
    (w6,p,6,'Legs — Posterior','Hypertrophy · hams/glutes/quads',65);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'6 min','—',30,'Shoulders · cuff · ramp','ti-stretching'),
    (w1,2,'Bench Press',4,'6','60',150,'Tuck elbows · drive through the floor','ti-barbell'),
    (w1,3,'Overhead Press',3,'8','40',120,'Brace · press tall','ti-barbell'),
    (w1,4,'Incline Bench Press',3,'10','45',90,'Upper-chest focus · controlled','ti-barbell'),
    (w1,5,'Lateral Raise',3,'15','—',60,'Lead with elbows · no swing','ti-activity'),
    (w1,6,'Triceps Pushdown',3,'12','—',60,'Lock out · control the return','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · lats · band pull-aparts','ti-stretching'),
    (w2,2,'Deadlift',4,'5','90',180,'Brace · push and pull · neutral spine','ti-barbell'),
    (w2,3,'Pull-up',4,'8','—',120,'Full hang · chest to bar','ti-arrow-up'),
    (w2,4,'Barbell Row',3,'10','55',90,'Flat back · pull to sternum','ti-barbell'),
    (w2,5,'Lat Pulldown',3,'12','—',75,'Long pull · squeeze lats','ti-arrow-up'),
    (w2,6,'Barbell Curl',3,'12','—',60,'Control both directions','ti-barbell');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',30,'Hips · ankles · ramp','ti-stretching'),
    (w3,2,'Back Squat',4,'6','80',180,'Brace · full depth','ti-barbell'),
    (w3,3,'Romanian Deadlift',3,'10','65',120,'Hinge · long hamstrings','ti-barbell'),
    (w3,4,'Leg Press',3,'12','—',90,'Full range · controlled','ti-barbell'),
    (w3,5,'Leg Curl',3,'12','—',60,'Squeeze · slow eccentric','ti-activity'),
    (w3,6,'Standing Calf Raise',4,'15','—',45,'Pause at the top','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Cuff · band · ramp','ti-stretching'),
    (w4,2,'Overhead Press',4,'6','42',150,'Strict · brace hard','ti-barbell'),
    (w4,3,'Incline Bench Press',4,'8','45',120,'Upper chest','ti-barbell'),
    (w4,4,'Dumbbell Shoulder Press',3,'10','20',90,'Control · full range','ti-barbell'),
    (w4,5,'Lateral Raise',4,'15','—',45,'Slow · constant tension','ti-activity'),
    (w4,6,'Dips',3,'10','—',75,'Lean forward for chest, upright for triceps','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w5,1,'Warm-up',1,'6 min','—',30,'Lats · cuff · ramp','ti-stretching'),
    (w5,2,'Weighted Pull-up',4,'6','5',150,'Add load · full range','ti-arrow-up'),
    (w5,3,'Barbell Row',4,'8','60',120,'Strict · no body english','ti-barbell'),
    (w5,4,'Lat Pulldown',3,'12','—',75,'Wide grip · to upper chest','ti-arrow-up'),
    (w5,5,'Face Pull',3,'15','—',45,'Rear delts · external rotation','ti-activity'),
    (w5,6,'Hammer Curl',3,'12','14',60,'Neutral grip · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w6,1,'Warm-up',1,'8 min','—',30,'Hamstrings · hips · ramp','ti-stretching'),
    (w6,2,'Front Squat',4,'6','60',150,'Tall chest · elbows up','ti-barbell'),
    (w6,3,'Romanian Deadlift',4,'8','70',120,'Hinge · hamstring stretch','ti-barbell'),
    (w6,4,'Walking Lunge',3,'10 each','16',90,'Tall torso · controlled','ti-walk'),
    (w6,5,'Leg Extension',3,'15','—',60,'Squeeze quads at the top','ti-activity'),
    (w6,6,'Seated Calf Raise',4,'15','—',45,'Full stretch and contraction','ti-activity');
  raise notice 'Added Push Pull Legs';
end $$;

-- ===== Full Body Starter =====
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid;
begin
  if exists (select 1 from programs where name='Full Body Starter' and sport='General') then raise notice 'Full Body Starter exists — skip'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Full Body Starter','General','beginner',3,8,'Beginner full-body linear progression · 3 sessions/week · add a little weight each week','ti-barbell');
  w1:=gen_random_uuid();
  w2:=gen_random_uuid();
  w3:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Full Body A','Squat · push · pull',50),
    (w2,p,2,'Full Body B','Hinge · press · pull',50),
    (w3,p,3,'Full Body C','Squat · push · hinge',50);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Full-body mobility · ramp-up sets','ti-stretching'),
    (w1,2,'Back Squat',3,'5','50',180,'Learn the groove · full depth','ti-barbell'),
    (w1,3,'Bench Press',3,'5','40',150,'Tuck elbows · controlled','ti-barbell'),
    (w1,4,'Barbell Row',3,'8','40',120,'Flat back · pull to sternum','ti-barbell'),
    (w1,5,'Plank',3,'40 s','—',45,'Brace · straight line','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'8 min','—',30,'Hips · shoulders · ramp','ti-stretching'),
    (w2,2,'Deadlift',2,'5','60',210,'Hinge · brace · neutral spine','ti-barbell'),
    (w2,3,'Overhead Press',3,'5','25',150,'Strict press · brace','ti-barbell'),
    (w2,4,'Lat Pulldown',3,'10','—',90,'Long pull · build toward pull-ups','ti-arrow-up'),
    (w2,5,'Hanging Leg Raise',3,'10','—',45,'Control the swing','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',30,'Full-body mobility · ramp','ti-stretching'),
    (w3,2,'Front Squat',3,'5','40',180,'Tall chest · elbows up','ti-barbell'),
    (w3,3,'Incline Bench Press',3,'8','35',120,'Controlled · full range','ti-barbell'),
    (w3,4,'Romanian Deadlift',3,'8','45',120,'Hinge · hamstring stretch','ti-barbell'),
    (w3,5,'Plank',3,'45 s','—',45,'Brace · breathe','ti-activity');
  raise notice 'Added Full Body Starter';
end $$;

-- ===== Dumbbell Only — Home =====
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Dumbbell Only — Home' and sport='General') then raise notice 'Dumbbell Only — Home exists — skip'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Dumbbell Only — Home','General','intermediate',4,8,'Full upper/lower split with dumbbells only · perfect for home or a minimal gym','ti-barbell');
  w1:=gen_random_uuid();
  w2:=gen_random_uuid();
  w3:=gen_random_uuid();
  w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Upper A','Push/pull balance',45),
    (w2,p,2,'Lower A','Quad-focused',45),
    (w3,p,3,'Upper B','Shoulder/back focus',45),
    (w4,p,4,'Lower B','Posterior chain',45);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'6 min','—',30,'Shoulders · ramp','ti-stretching'),
    (w1,2,'Dumbbell Bench Press',4,'8','22',120,'Full range · control','ti-barbell'),
    (w1,3,'Dumbbell Row',4,'10','24',90,'Brace · pull to the hip','ti-barbell'),
    (w1,4,'Dumbbell Shoulder Press',3,'10','18',90,'Press tall · brace','ti-barbell'),
    (w1,5,'Lateral Raise',3,'15','8',45,'Lead with elbows','ti-activity'),
    (w1,6,'Hammer Curl',3,'12','14',45,'Neutral grip · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · ankles · ramp','ti-stretching'),
    (w2,2,'Goblet Squat',4,'10','24',120,'Tall chest · full depth','ti-barbell'),
    (w2,3,'Romanian Deadlift',4,'10','24',90,'Hinge · hamstrings','ti-barbell'),
    (w2,4,'Walking Lunge',3,'10 each','16',75,'Controlled · tall torso','ti-walk'),
    (w2,5,'Standing Calf Raise',3,'15','—',45,'Full range','ti-activity'),
    (w2,6,'Plank',3,'45 s','—',45,'Brace · straight line','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'6 min','—',30,'Cuff · ramp','ti-stretching'),
    (w3,2,'Dumbbell Shoulder Press',4,'8','18',120,'Strict','ti-barbell'),
    (w3,3,'Dumbbell Bench Press',4,'10','20',90,'Control','ti-barbell'),
    (w3,4,'Dumbbell Row',4,'10','24',90,'Strict · no momentum','ti-barbell'),
    (w3,5,'Dumbbell Curl',3,'12','12',45,'Control','ti-activity'),
    (w3,6,'Dips',3,'10','—',60,'Triceps focus','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Hamstrings · hips · ramp','ti-stretching'),
    (w4,2,'Goblet Squat',4,'12','24',90,'Depth · control','ti-barbell'),
    (w4,3,'Reverse Lunge',3,'10 each','16',75,'Controlled','ti-walk'),
    (w4,4,'Romanian Deadlift',4,'12','24',90,'Hinge','ti-barbell'),
    (w4,5,'Hip Thrust',3,'12','—',60,'Squeeze glutes · ribs down','ti-barbell'),
    (w4,6,'Standing Calf Raise',4,'15','—',45,'Pause at top','ti-activity');
  raise notice 'Added Dumbbell Only — Home';
end $$;

-- ===== Bodyweight — No Equipment =====
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Bodyweight — No Equipment' and sport='General') then raise notice 'Bodyweight — No Equipment exists — skip'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Bodyweight — No Equipment','General','beginner',4,6,'Zero-equipment calisthenics · build strength anywhere (use a band/inverted rows if pull-ups are hard)','ti-activity');
  w1:=gen_random_uuid();
  w2:=gen_random_uuid();
  w3:=gen_random_uuid();
  w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Push & Core','Chest/shoulders/triceps + core',35),
    (w2,p,2,'Lower','Legs/glutes/calves',35),
    (w3,p,3,'Pull & Core','Back/biceps + core',35),
    (w4,p,4,'Full Body','Total-body circuit',35);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'5 min','—',30,'Shoulders · wrists · ramp','ti-stretching'),
    (w1,2,'Push-up',4,'12','—',75,'Full range · brace','ti-activity'),
    (w1,3,'Dips',3,'10','—',75,'Triceps and chest','ti-activity'),
    (w1,4,'Plank',3,'45 s','—',45,'Brace · straight line','ti-activity'),
    (w1,5,'Side Plank',3,'30 s each','—',30,'Stack hips · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'5 min','—',30,'Hips · ankles · ramp','ti-stretching'),
    (w2,2,'Split Squat',4,'12 each','—',75,'Tall torso · controlled depth','ti-activity'),
    (w2,3,'Walking Lunge',3,'12 each','—',60,'Controlled','ti-walk'),
    (w2,4,'Glute Bridge',3,'15','—',45,'Squeeze glutes at the top','ti-barbell'),
    (w2,5,'Standing Calf Raise',4,'20','—',30,'Full range · slow','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'5 min','—',30,'Lats · cuff · ramp','ti-stretching'),
    (w3,2,'Pull-up',4,'6','—',90,'Band-assist if needed · full hang','ti-arrow-up'),
    (w3,3,'Chin-up',3,'8','—',90,'Underhand · chest to bar','ti-arrow-up'),
    (w3,4,'Hanging Leg Raise',3,'10','—',45,'Control the swing','ti-activity'),
    (w3,5,'Plank',3,'60 s','—',45,'Brace · breathe','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Full-body mobility · ramp','ti-stretching'),
    (w4,2,'Push-up',4,'15','—',60,'Full range','ti-activity'),
    (w4,3,'Reverse Lunge',3,'12 each','—',60,'Controlled','ti-walk'),
    (w4,4,'Pull-up',3,'8','—',90,'Band-assist if needed','ti-arrow-up'),
    (w4,5,'Glute Bridge',3,'20','—',45,'Squeeze','ti-barbell'),
    (w4,6,'Side Plank',3,'40 s each','—',30,'Brace · stack hips','ti-activity');
  raise notice 'Added Bodyweight — No Equipment';
end $$;

-- ===== Powerbuilding =====
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Powerbuilding' and sport='General') then raise notice 'Powerbuilding exists — skip'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Powerbuilding','General','intermediate',4,8,'Strength + size hybrid · heavy compounds then hypertrophy accessories · upper/lower','ti-barbell');
  w1:=gen_random_uuid();
  w2:=gen_random_uuid();
  w3:=gen_random_uuid();
  w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Upper Power','Heavy push/pull',55),
    (w2,p,2,'Lower Power','Heavy squat/hinge',60),
    (w3,p,3,'Upper Hypertrophy','Volume push/pull',55),
    (w4,p,4,'Lower Hypertrophy','Volume legs',55);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Shoulders · cuff · ramp sets','ti-stretching'),
    (w1,2,'Bench Press',5,'3','70',210,'Heavy · ~90% zone · explosive intent','ti-barbell'),
    (w1,3,'Barbell Row',4,'5','65',150,'Strict · powerful pull','ti-barbell'),
    (w1,4,'Overhead Press',3,'6','42',120,'Strict press · brace','ti-barbell'),
    (w1,5,'Weighted Pull-up',3,'6','5',120,'Add load · full range','ti-arrow-up'),
    (w1,6,'Barbell Curl',3,'10','—',60,'Control','ti-barbell');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'8 min','—',30,'Hips · ankles · ramp sets','ti-stretching'),
    (w2,2,'Back Squat',5,'3','95',240,'Heavy · brace hard · full depth','ti-barbell'),
    (w2,3,'Deadlift',3,'3','110',240,'Reset each rep · brace','ti-barbell'),
    (w2,4,'Leg Press',3,'8','—',120,'Controlled · full range','ti-barbell'),
    (w2,5,'Leg Curl',3,'10','—',60,'Squeeze · slow eccentric','ti-activity'),
    (w2,6,'Standing Calf Raise',4,'12','—',45,'Pause at top','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'6 min','—',30,'Cuff · band · ramp','ti-stretching'),
    (w3,2,'Incline Bench Press',4,'10','45',90,'Upper chest · squeeze','ti-barbell'),
    (w3,3,'Lat Pulldown',4,'12','—',75,'Long pull · control','ti-arrow-up'),
    (w3,4,'Dumbbell Shoulder Press',3,'12','18',75,'Full range','ti-barbell'),
    (w3,5,'Lateral Raise',4,'15','—',45,'Constant tension','ti-activity'),
    (w3,6,'Triceps Pushdown',3,'15','—',45,'Lock out','ti-activity'),
    (w3,7,'Hammer Curl',3,'12','14',45,'Neutral grip','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Hamstrings · hips · ramp','ti-stretching'),
    (w4,2,'Front Squat',4,'8','60',120,'Tall chest · elbows up','ti-barbell'),
    (w4,3,'Romanian Deadlift',4,'10','70',90,'Hinge · hamstring stretch','ti-barbell'),
    (w4,4,'Walking Lunge',3,'12 each','18',75,'Controlled · tall torso','ti-walk'),
    (w4,5,'Leg Extension',3,'15','—',60,'Squeeze quads','ti-activity'),
    (w4,6,'Seated Calf Raise',4,'15','—',45,'Full range','ti-activity');
  raise notice 'Added Powerbuilding';
end $$;
