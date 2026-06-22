-- ÍslandFit v10 — Sport-specific programs, batch 4 (advanced tier) — final batch
-- Evidence-informed, demands-matched, original designs. Level 'advanced'. Run AFTER v5. Re-run safe (guarded).
-- Sports: Equestrian, Strongman, Glíma, Badminton, Winter Sports.

-- EQUESTRIAN (3 days) — demands: core stability, posture, balance, adductor/leg endurance, anti-rotation
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid;
begin
  if exists (select 1 from programs where name='Equestrian Core & Stability' and sport='Equestrian') then raise notice 'skip Equestrian'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Equestrian Core & Stability','Equestrian','advanced',3,12,'Core stability · posture · balance · adductor & leg endurance','ti-horse-toy');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Core & Stability','Durability',45),(w2,p,2,'Lower & Adductor','Strength',50),
    (w3,p,3,'Posture & Mobility','Mobility',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Hips · t-spine · activation','ti-stretching'),
    (w1,2,'Pallof Press',4,'12 each','20',45,'Anti-rotation · ribs down','ti-activity'),
    (w1,3,'Dead Bug',3,'10 each','—',45,'Low back flat · slow','ti-activity'),
    (w1,4,'Bird Dog',3,'10 each','—',45,'Long limbs · no twist','ti-activity'),
    (w1,5,'Side Plank',3,'30 s each','—',45,'Stack hips · brace','ti-activity'),
    (w1,6,'Suitcase Carry',3,'30 m each','24',60,'Tall posture · resist lean','ti-flame');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · groin','ti-stretching'),
    (w2,2,'Bulgarian Split Squat',4,'8 each','20',75,'Tall torso · control','ti-walk'),
    (w2,3,'Romanian Deadlift',3,'8','60',90,'Hinge · hamstrings','ti-barbell'),
    (w2,4,'Copenhagen Plank',3,'20 s each','—',60,'Adductor strength · line','ti-activity'),
    (w2,5,'Glute Bridge',3,'12','40',60,'Squeeze glutes · ribs down','ti-activity'),
    (w2,6,'Calf Raise',3,'15','—',45,'Full range · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Mobility Flow',1,'10 min','—',20,'Hips · t-spine · shoulders','ti-stretching'),
    (w3,2,'Face Pull',4,'15','—',45,'Rear delts · posture','ti-activity'),
    (w3,3,'Single-Arm Row',3,'10 each','24',60,'Flat back · pull to hip','ti-barbell'),
    (w3,4,'Single-Leg Balance',3,'30 s each','—',45,'Stable hips · control','ti-activity'),
    (w3,5,'Hip Mobility',1,'8 min','—',0,'Open hips · breathe','ti-stretching');
  raise notice 'Added Equestrian Core & Stability';
end $$;

-- STRONGMAN — demands: max full-body strength, carries & odd objects, grip, work capacity
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Strongman Power' and sport='Strongman') then raise notice 'skip Strongman'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Strongman Power','Strongman','advanced',4,12,'Max full-body strength · loaded carries · grip · work capacity','ti-barbell');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Max Lower','Strength',65),(w2,p,2,'Max Press','Strength',60),
    (w3,p,3,'Events & Carries','Power · Grip',60),(w4,p,4,'Back & Conditioning','Endurance',50);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Hips · ankles · ramp','ti-stretching'),
    (w1,2,'Back Squat',5,'3','150',210,'Brace hard · drive · depth','ti-barbell'),
    (w1,3,'Deadlift',5,'2','190',240,'Push and pull · brace','ti-barbell'),
    (w1,4,'Front Squat',3,'5','100',150,'Tall chest · elbows up','ti-barbell'),
    (w1,5,'Weighted Plank',3,'45 s','—',60,'Brace · neutral','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Cuff · ramp','ti-stretching'),
    (w2,2,'Overhead Press',5,'3','75',210,'Brace · drive overhead','ti-barbell'),
    (w2,3,'Push Press',4,'3','90',150,'Dip-drive · lockout','ti-arrow-up'),
    (w2,4,'Bench Press',4,'5','110',150,'Tuck elbows · drive','ti-barbell'),
    (w2,5,'Barbell Row',4,'6','100',90,'Flat back · pull to sternum','ti-barbell'),
    (w2,6,'Triceps Extension',3,'12','—',60,'Control · lockout','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',30,'Full-body ramp','ti-stretching'),
    (w3,2,'Farmer Carry',4,'40 m','60',120,'Tall posture · crush grip','ti-flame'),
    (w3,3,'Sled Push',4,'30 m','—',120,'Drive hard · low angle','ti-flame'),
    (w3,4,'Sandbag Load',4,'3','60',150,'Hips through · hug tight','ti-barbell'),
    (w3,5,'Yoke Carry',3,'25 m','100',150,'Brace · short steps','ti-flame'),
    (w3,6,'Grip Hold',3,'30 s','—',60,'Crush · steady','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Activation','ti-stretching'),
    (w4,2,'Romanian Deadlift',4,'8','120',90,'Hinge · hamstrings','ti-barbell'),
    (w4,3,'Chest-Supported Row',4,'10','—',75,'Squeeze · control','ti-activity'),
    (w4,4,'Prowler Intervals',6,'30 s','—',90,'Hard push · build engine','ti-flame'),
    (w4,5,'Back Extension',3,'12','—',60,'Hinge · squeeze glutes','ti-activity');
  raise notice 'Added Strongman Power';
end $$;

-- GLÍMA (Icelandic wrestling) — demands: grip, hip & throw power, balance, posterior chain, anaerobic capacity
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Glíma Grappler' and sport='Glíma') then raise notice 'skip Glíma'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Glíma Grappler','Glíma','advanced',4,12,'Grip · hip & throw power · balance · posterior chain · grappling conditioning','ti-karate');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Max Strength','Strength',60),(w2,p,2,'Power & Throw','Explosiveness',50),
    (w3,p,3,'Grappling Conditioning','Anaerobic',45),(w4,p,4,'Aerobic & Mobility','Endurance',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Hips · shoulders · ramp','ti-stretching'),
    (w1,2,'Back Squat',5,'4','100',180,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Deadlift',4,'4','130',180,'Flat back · push floor','ti-barbell'),
    (w1,4,'Weighted Pull-up',4,'5','12',120,'Full hang · control','ti-arrow-up'),
    (w1,5,'Overhead Press',3,'6','50',90,'Brace · press tall','ti-barbell'),
    (w1,6,'Grip Hold',3,'30 s','—',60,'Crush · steady','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · skips','ti-stretching'),
    (w2,2,'Hang Power Clean',5,'3','65',150,'Triple extension · catch tall','ti-barbell'),
    (w2,3,'Kettlebell Swing',5,'12','32',75,'Hip snap · brace','ti-flame'),
    (w2,4,'Med Ball Rotational Throw',4,'4 each','—',60,'Hip drive · whip','ti-bolt'),
    (w2,5,'Broad Jump',4,'3','—',90,'Explode forward · stick','ti-bolt'),
    (w2,6,'Hip Thrust',3,'8','100',75,'Squeeze glutes · ribs down','ti-barbell');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'6 min','—',30,'Build to a sweat','ti-activity'),
    (w3,2,'Round Circuit',5,'3min on/1min off','—',60,'Sustain output · grip tight','ti-heart'),
    (w3,3,'Sled Drag',4,'30 m','—',75,'Low · drive · grip','ti-flame'),
    (w3,4,'Neck Iso Hold',3,'30 s','—',45,'Brace neck · all directions','ti-activity'),
    (w3,5,'Core Anti-Rotation',3,'10 each','20',45,'Resist twist · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Zone 2 Conditioning',1,'25 min','—',0,'Easy bike or row · aerobic base','ti-heart'),
    (w4,2,'Hip Mobility',1,'10 min','—',0,'Open hips · groin','ti-stretching'),
    (w4,3,'Plank',3,'45 s','—',45,'Brace · line','ti-activity');
  raise notice 'Added Glíma Grappler';
end $$;

-- BADMINTON — demands: repeated lunging & lateral movement, jump-smash power, overhead shoulder, first-step speed
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Badminton Agility' and sport='Badminton') then raise notice 'skip Badminton'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Badminton Agility','Badminton','advanced',4,12,'Lunge & lateral strength · jump-smash power · overhead shoulder · first-step speed','ti-feather');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Lower Strength & Lunge','Strength',50),(w2,p,2,'Power & Overhead','Power · Durability',50),
    (w3,p,3,'Speed & Agility','Speed',45),(w4,p,4,'Conditioning & Core','Endurance',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · skips','ti-stretching'),
    (w1,2,'Back Squat',4,'5','75',150,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Lateral Lunge',3,'8 each','18',75,'Sit into hip · push back','ti-walk'),
    (w1,4,'Split Squat',3,'8 each','20',75,'Tall torso · control','ti-walk'),
    (w1,5,'Romanian Deadlift',3,'6','65',90,'Hinge · hamstrings','ti-barbell'),
    (w1,6,'Calf Raise',3,'15','—',45,'Full range · stiffness','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Cuff · t-spine','ti-stretching'),
    (w2,2,'Squat Jump',5,'3','—',120,'Explode · land soft','ti-arrow-up'),
    (w2,3,'Med Ball Overhead Throw',4,'5','—',60,'Smash pattern · throw hard','ti-bolt'),
    (w2,4,'Landmine Press',4,'8 each','20',75,'Brace · press across','ti-barbell'),
    (w2,5,'Pull-up',4,'8','—',90,'Full hang · control','ti-arrow-up'),
    (w2,6,'External Rotation',3,'15 each','—',45,'Cuff health · slow','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups','ti-stretching'),
    (w3,2,'Court Movement Drill',5,'1 rep','—',75,'Explosive corners · recover center','ti-target-arrow'),
    (w3,3,'Lateral Shuffle',4,'20 s','—',60,'Low · quick feet','ti-bolt'),
    (w3,4,'Lunge Reach',4,'6 each','—',60,'Deep lunge · push back fast','ti-walk'),
    (w3,5,'First-Step Sprints',5,'8 m','—',75,'Explosive start · stay low','ti-run'),
    (w3,6,'Hip Mobility',1,'5 min','—',0,'Open hips · cool down','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Rally Intervals',8,'20s on/40s off','—',30,'Repeat hard efforts','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Pallof Press',3,'10 each','20',45,'Anti-rotation','ti-activity'),
    (w4,5,'Plank',3,'45 s','—',45,'Brace','ti-activity'),
    (w4,6,'Cooldown Walk',1,'5 min','—',0,'Settle','ti-walk');
  raise notice 'Added Badminton Agility';
end $$;

-- WINTER SPORTS (alpine bias) — demands: eccentric & isometric leg strength, lateral power, balance, core, aerobic
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Alpine & Snow Power' and sport='Winter Sports') then raise notice 'skip Winter Sports'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Alpine & Snow Power','Winter Sports','advanced',4,12,'Eccentric & isometric leg strength · lateral power · balance · aerobic base','ti-ski-jumping');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Leg Strength & Eccentric','Strength',55),(w2,p,2,'Power & Lateral','Explosiveness',50),
    (w3,p,3,'Balance & Core','Durability',45),(w4,p,4,'Aerobic & Conditioning','Endurance',45);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Hips · knees · ankles','ti-stretching'),
    (w1,2,'Back Squat',4,'5','90',150,'Three sec down · brace · drive','ti-barbell'),
    (w1,3,'Bulgarian Split Squat',3,'8 each','24',75,'Tall torso · control','ti-walk'),
    (w1,4,'Wall Sit',3,'45 s','—',60,'Isometric quad · brace','ti-activity'),
    (w1,5,'Romanian Deadlift',3,'6','75',90,'Hinge · hamstrings','ti-barbell'),
    (w1,6,'Calf Raise',3,'15','40',45,'Pause top · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · skips','ti-stretching'),
    (w2,2,'Squat Jump',5,'3','—',120,'Explode · land soft','ti-arrow-up'),
    (w2,3,'Lateral Bound',4,'5 each','—',90,'Push outside · stick','ti-bolt'),
    (w2,4,'Box Jump',4,'4','—',90,'Explode · soft landing','ti-arrow-up'),
    (w2,5,'Skater Hops',4,'8 each','—',60,'Side to side · control','ti-bolt'),
    (w2,6,'Core Anti-Rotation',3,'10 each','20',45,'Brace · resist twist','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',20,'Activation','ti-stretching'),
    (w3,2,'Single-Leg Balance',4,'30 s each','—',45,'Stable knee · control','ti-activity'),
    (w3,3,'Single-Leg RDL',3,'8 each','16',60,'Hinge · balance','ti-walk'),
    (w3,4,'Side Plank',3,'30 s each','—',45,'Stack hips · brace','ti-activity'),
    (w3,5,'Pallof Press',3,'12 each','20',45,'Anti-rotation','ti-activity'),
    (w3,6,'Mobility Flow',1,'8 min','—',0,'Hips · ankles · breathe','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Zone 2 Conditioning',1,'30 min','—',0,'Easy bike or row or ski · aerobic base','ti-heart'),
    (w4,3,'Interval Conditioning',6,'1min on/1min off','—',30,'Hard efforts · controlled','ti-heart'),
    (w4,4,'Plank',3,'45 s','—',45,'Brace','ti-activity'),
    (w4,5,'Cooldown',1,'5 min','—',0,'Settle · breathe','ti-walk');
  raise notice 'Added Alpine & Snow Power';
end $$;
