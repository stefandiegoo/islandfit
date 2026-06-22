-- ÍslandFit v13 — "Strength Foundations" (NSCA-principles linear periodization)
-- ORIGINAL program built on the NSCA's PUBLIC guidelines (not copied from their copyrighted
-- textbook/journal): rep ranges mapped to the NSCA Training Load Chart
--   (5 reps ≈ 87% 1RM · 6 ≈ 85% · 8 ≈ 80% · 10 ≈ 75% · 12 ≈ 67%),
-- strength work loaded in the ≥85% 1RM zone, classic upper/lower split, intensity-up / volume-down.
-- Source for the load-rep relationship: NSCA Training Load Chart (nsca.com).
-- Run in Supabase SQL Editor anytime after programs exist. Idempotent (guarded).

do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Strength Foundations' and sport='General') then raise notice 'Strength Foundations exists — skip'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Strength Foundations','General','beginner',4,12,'NSCA-principles linear periodization · upper/lower · strength + hypertrophy zones','ti-barbell');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Lower — Strength','Strength (~85% 1RM)',55),
    (w2,p,2,'Upper — Strength','Strength (~85% 1RM)',55),
    (w3,p,3,'Lower — Power & Hypertrophy','Power · Hypertrophy',60),
    (w4,p,4,'Upper — Hypertrophy','Hypertrophy (~75% 1RM)',55);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'6 min','—',30,'Hips · ankles · ramp-up sets','ti-stretching'),
    (w1,2,'Back Squat',4,'5','80',180,'NSCA strength zone ~87% 1RM · brace · full depth','ti-barbell'),
    (w1,3,'Romanian Deadlift',3,'8','70',120,'Hinge · long hamstrings · flat back','ti-barbell'),
    (w1,4,'Leg Press',3,'10','—',90,'Full range · controlled tempo','ti-activity'),
    (w1,5,'Standing Calf Raise',3,'12','40',60,'Pause at top · controlled descent','ti-activity'),
    (w1,6,'Plank',3,'45 s','—',45,'Brace · straight line','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Cuff · band pull-aparts · ramp','ti-stretching'),
    (w2,2,'Bench Press',4,'5','70',180,'NSCA strength zone ~87% 1RM · tuck elbows · drive','ti-barbell'),
    (w2,3,'Barbell Row',4,'6','70',120,'Flat back · pull to sternum','ti-barbell'),
    (w2,4,'Overhead Press',3,'8','45',90,'Brace · press tall · ~80% zone','ti-barbell'),
    (w2,5,'Lat Pulldown',3,'10','—',75,'Long pull · control','ti-activity'),
    (w2,6,'Triceps Extension',3,'12','—',45,'Control · full lockout','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',30,'Hips · hamstrings · ramp','ti-stretching'),
    (w3,2,'Deadlift',4,'3','100',210,'NSCA strength/power ~90% 1RM · push & pull · brace','ti-barbell'),
    (w3,3,'Front Squat',3,'6','70',150,'Tall chest · elbows up · ~85% zone','ti-barbell'),
    (w3,4,'Bulgarian Split Squat',3,'8 each','20',90,'Tall torso · controlled depth','ti-walk'),
    (w3,5,'Hip Thrust',3,'10','80',75,'Squeeze glutes · ribs down','ti-barbell'),
    (w3,6,'Hanging Leg Raise',3,'12','—',45,'Control the swing · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Cuff · band · ramp','ti-stretching'),
    (w4,2,'Incline Bench Press',4,'8','55',120,'NSCA hypertrophy ~80% 1RM · controlled','ti-barbell'),
    (w4,3,'Weighted Pull-up',4,'6','8',120,'Full hang · chest to bar','ti-arrow-up'),
    (w4,4,'Dumbbell Shoulder Press',3,'10','20',90,'Control · full range · ~75% zone','ti-barbell'),
    (w4,5,'Face Pull',3,'15','—',45,'Rear delts · cuff health','ti-activity'),
    (w4,6,'Biceps Curl',3,'12','—',45,'Control both directions','ti-activity');
  raise notice 'Added Strength Foundations (NSCA principles)';
end $$;
