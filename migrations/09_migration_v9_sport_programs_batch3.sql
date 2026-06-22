-- ÍslandFit v9 — Sport-specific programs, batch 3 (advanced tier)
-- Evidence-informed, demands-matched, original designs. Level 'advanced'. Run AFTER v5. Re-run safe (guarded).
-- Sports: CrossFit, Cycling, Ice Hockey, Gymnastics, Rock Climbing.

-- CROSSFIT — demands: mixed strength + Olympic lifting + gymnastics skill + metcon (all energy systems)
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='CrossFit Engine' and sport='CrossFit') then raise notice 'skip CrossFit'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'CrossFit Engine','CrossFit','advanced',4,12,'Strength · Olympic lifting · gymnastics skill · mixed-modal metcon','ti-flame');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Strength','Strength',55),(w2,p,2,'Olympic Lifting','Explosiveness',55),
    (w3,p,3,'Gymnastics & Skill','Skill · Strength',45),(w4,p,4,'Metcon','Endurance · Engine',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Mobility · ramp','ti-stretching'),
    (w1,2,'Back Squat',5,'5','100',180,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Strict Press',4,'5','55',120,'Brace · press tall','ti-barbell'),
    (w1,4,'Deadlift',4,'4','120',150,'Flat back · push floor','ti-barbell'),
    (w1,5,'Weighted Pull-up',4,'6','10',90,'Full hang · control','ti-arrow-up'),
    (w1,6,'Hanging Leg Raise',3,'12','—',45,'Control · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'8 min','—',30,'Hips · ankles · barbell drills','ti-stretching'),
    (w2,2,'Power Snatch',6,'2','50',180,'Aggressive extension · catch fast','ti-barbell'),
    (w2,3,'Clean & Jerk',6,'2','70',180,'Triple extension · drive overhead','ti-barbell'),
    (w2,4,'Front Squat',4,'4','90',150,'Elbows up · tall chest','ti-barbell'),
    (w2,5,'Box Jump',4,'4','—',90,'Explode · land soft','ti-arrow-up');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',30,'Shoulders · wrists · scap','ti-stretching'),
    (w3,2,'Handstand Push-up',4,'6','—',90,'Stack · brace · control','ti-arrow-up'),
    (w3,3,'Muscle-up Progression',4,'4','—',120,'Tight pull · fast transition','ti-arrow-up'),
    (w3,4,'Ring Dip',4,'8','—',75,'Control · full depth','ti-activity'),
    (w3,5,'Toes-to-Bar',4,'10','—',60,'Compress · control swing','ti-activity'),
    (w3,6,'Handstand Hold',3,'30 s','—',45,'Stack · brace · breathe','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Build to a sweat','ti-activity'),
    (w4,2,'AMRAP Circuit',5,'4min on/1min off','—',60,'Sustain output · smooth pace','ti-heart'),
    (w4,3,'Wall Ball',5,'15','9',45,'Full squat · drive to target','ti-flame'),
    (w4,4,'Rowing Sprints',6,'250 m','—',60,'Strong pulls · hold split','ti-heart'),
    (w4,5,'Cooldown',1,'5 min','—',0,'Settle · breathe','ti-walk');
  raise notice 'Added CrossFit Engine';
end $$;

-- CYCLING — demands: aerobic/threshold engine, leg strength & sprint power, single-leg, posture
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Cyclist Power & Engine' and sport='Cycling') then raise notice 'skip Cycling'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Cyclist Power & Engine','Cycling','advanced',4,12,'Aerobic & threshold engine · leg strength · sprint power · core posture','ti-bike');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Leg Strength','Strength',50),(w2,p,2,'Endurance Ride','Endurance · Base',70),
    (w3,p,3,'Threshold & VO2','Endurance · Engine',55),(w4,p,4,'Power & Core','Power',45);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Hips · knees · activation','ti-stretching'),
    (w1,2,'Back Squat',4,'5','90',150,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Romanian Deadlift',3,'6','80',120,'Hinge · hamstrings','ti-barbell'),
    (w1,4,'Bulgarian Split Squat',3,'8 each','22',75,'Tall torso · control','ti-walk'),
    (w1,5,'Single-Leg Calf Raise',3,'12 each','—',45,'Full range · stiffness','ti-activity'),
    (w1,6,'Core Circuit',3,'45 s','—',45,'Plank · side plank · dead bug','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Zone 2 Ride',1,'60 min','—',0,'Steady aerobic · conversational','ti-heart'),
    (w2,2,'Mobility Cooldown',1,'8 min','—',0,'Hips · quads · breathe','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up Ride',1,'12 min','—',30,'Easy build · openers','ti-heart'),
    (w3,2,'Threshold Intervals',4,'8min on/4min off','—',30,'Sustained hard · controlled','ti-heart'),
    (w3,3,'VO2 Intervals',5,'3min on/3min off','—',30,'Near max · strong cadence','ti-heart'),
    (w3,4,'Cooldown Ride',1,'10 min','—',0,'Easy · flush legs','ti-heart');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Activation · ramp','ti-stretching'),
    (w4,2,'Jump Squat',5,'3','—',120,'Explode · land soft','ti-arrow-up'),
    (w4,3,'Trap Bar Deadlift',4,'4','100',120,'Flat back · drive','ti-barbell'),
    (w4,4,'Sprint Intervals',6,'15 s','—',120,'Max effort standing sprint','ti-bolt'),
    (w4,5,'Pallof Press',3,'10 each','20',45,'Anti-rotation','ti-activity'),
    (w4,6,'Mobility Flow',1,'6 min','—',0,'Hips · back · breathe','ti-stretching');
  raise notice 'Added Cyclist Power & Engine';
end $$;

-- ICE HOCKEY — demands: explosive skating power (lateral hip), acceleration, shot power, shift conditioning
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Ice Hockey Power' and sport='Ice Hockey') then raise notice 'skip Ice Hockey'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Ice Hockey Power','Ice Hockey','advanced',4,12,'Lateral skating power · acceleration · shot power · shift conditioning','ti-ice-skating');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Lower Power','Strength · Explosiveness',60),(w2,p,2,'Upper & Shot Power','Strength · Rotation',50),
    (w3,p,3,'Speed & Lateral','Speed',45),(w4,p,4,'Shift Conditioning','Endurance · Anaerobic',45);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · groin · skips','ti-stretching'),
    (w1,2,'Back Squat',5,'4','95',180,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Trap Bar Deadlift',4,'4','110',150,'Flat back · push floor','ti-barbell'),
    (w1,4,'Lateral Bound',4,'5 each','—',90,'Skating push · stick landing','ti-bolt'),
    (w1,5,'Bulgarian Split Squat',3,'8 each','24',75,'Tall torso · control','ti-walk'),
    (w1,6,'Copenhagen Plank',3,'20 s each','—',60,'Adductor strength · line','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Cuff · t-spine','ti-stretching'),
    (w2,2,'Bench Press',4,'5','75',150,'Tuck elbows · drive','ti-barbell'),
    (w2,3,'Med Ball Rotational Throw',4,'4 each','—',75,'Shot pattern · hip drive','ti-bolt'),
    (w2,4,'Weighted Pull-up',4,'6','10',120,'Full hang · control','ti-arrow-up'),
    (w2,5,'Landmine Press',3,'8 each','25',75,'Brace · press across','ti-barbell'),
    (w2,6,'Cable Woodchop',3,'10 each','20',45,'Rotation · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups','ti-stretching'),
    (w3,2,'Acceleration Sprints',6,'15 m','—',120,'First-step drive','ti-run'),
    (w3,3,'Lateral Crossover Bound',4,'5 each','—',90,'Crossover power · stick','ti-bolt'),
    (w3,4,'Reactive Shuffle',4,'20 s','—',60,'Low · quick · react','ti-bolt'),
    (w3,5,'Single-Leg Hop',3,'6 each','—',60,'Soft landing · stable','ti-bolt'),
    (w3,6,'Hip Mobility',1,'5 min','—',0,'Open hips · groin','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Shift Intervals',10,'40s on/60s off','—',30,'Mimic shift demands · hard','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','28',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Pallof Press',3,'10 each','20',45,'Anti-rotation','ti-activity'),
    (w4,5,'Cooldown Walk',1,'5 min','—',0,'Settle','ti-walk');
  raise notice 'Added Ice Hockey Power';
end $$;

-- GYMNASTICS — demands: relative strength, straight-arm strength, body control/skill, core, mobility
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Gymnastics Strength' and sport='Gymnastics') then raise notice 'skip Gymnastics'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Gymnastics Strength','Gymnastics','advanced',4,12,'Relative strength · straight-arm strength · body control · core · mobility','ti-gymnastics');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Upper Strength','Strength',55),(w2,p,2,'Lower & Power','Explosiveness',45),
    (w3,p,3,'Skill & Straight-Arm','Skill',50),(w4,p,4,'Core & Mobility','Durability',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Wrists · shoulders · scap','ti-stretching'),
    (w1,2,'Weighted Pull-up',5,'5','12',150,'Full range · control','ti-arrow-up'),
    (w1,3,'Weighted Dip',4,'6','15',120,'Control · full depth','ti-activity'),
    (w1,4,'Strict Press',4,'5','45',120,'Brace · press tall','ti-barbell'),
    (w1,5,'Ring Row',4,'10','—',75,'Body tight · pull to chest','ti-activity'),
    (w1,6,'Hollow Rock',3,'30 s','—',45,'Low back flat · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · ankles','ti-stretching'),
    (w2,2,'Back Squat',4,'5','70',150,'Brace · drive · depth','ti-barbell'),
    (w2,3,'Squat Jump',5,'3','—',120,'Explode · land soft','ti-arrow-up'),
    (w2,4,'Broad Jump',4,'3','—',90,'Explode forward · stick','ti-bolt'),
    (w2,5,'Single-Leg RDL',3,'8 each','16',60,'Hinge · balance · control','ti-walk'),
    (w2,6,'Calf Raise',3,'15','—',45,'Full range · stiffness','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'10 min','—',20,'Wrists · scap · shoulders','ti-stretching'),
    (w3,2,'Handstand Practice',5,'30 s','—',60,'Stack · brace · breathe','ti-arrow-up'),
    (w3,3,'L-Sit Hold',4,'20 s','—',75,'Compress · push down · point','ti-activity'),
    (w3,4,'Planche Lean',4,'15 s','—',75,'Lean forward · protract · brace','ti-activity'),
    (w3,5,'Tuck Front Lever',4,'15 s','—',75,'Straight arms · pull down','ti-activity'),
    (w3,6,'Wrist & Shoulder Mobility',1,'8 min','—',0,'Prep joints · breathe','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',20,'Activation','ti-stretching'),
    (w4,2,'Hanging Leg Raise',4,'10','—',60,'Control · compress','ti-activity'),
    (w4,3,'Arch Hold',3,'30 s','—',45,'Squeeze glutes · long body','ti-activity'),
    (w4,4,'Side Plank',3,'30 s each','—',45,'Stack · brace','ti-activity'),
    (w4,5,'Active Flexibility',1,'12 min','—',0,'Pike · pancake · bridge','ti-stretching');
  raise notice 'Added Gymnastics Strength';
end $$;

-- ROCK CLIMBING — demands: finger/grip strength, pulling strength & endurance, core tension, antagonist balance
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Climbing Power & Grip' and sport='Rock Climbing') then raise notice 'skip Rock Climbing'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Climbing Power & Grip','Rock Climbing','advanced',4,12,'Finger & grip strength · pulling power · core tension · antagonist balance','ti-mountain');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Pulling Strength','Strength',55),(w2,p,2,'Grip & Fingers','Strength · Grip',50),
    (w3,p,3,'Core & Body Tension','Durability',45),(w4,p,4,'Antagonist & Conditioning','Balance',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'10 min','—',30,'Shoulders · fingers · easy climbing','ti-stretching'),
    (w1,2,'Weighted Pull-up',5,'5','12',150,'Full range · control','ti-arrow-up'),
    (w1,3,'Barbell Row',4,'8','65',90,'Flat back · pull to sternum','ti-barbell'),
    (w1,4,'Lat Pulldown',3,'10','—',75,'Long pull · control','ti-activity'),
    (w1,5,'Scapular Pull-up',3,'8','—',60,'Depress · retract','ti-arrow-up'),
    (w1,6,'Hanging Leg Raise',3,'12','—',45,'Compress · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'12 min','—',30,'Progressive finger warm-up · do not rush','ti-stretching'),
    (w2,2,'Hangboard Repeaters',5,'7 s','—',180,'Half-crimp · controlled · stop if sharp pain','ti-activity'),
    (w2,3,'Pinch Block Hold',4,'20 s','—',90,'Crush · steady · breathe','ti-activity'),
    (w2,4,'Wrist Curl',3,'12','—',45,'Control both directions','ti-activity'),
    (w2,5,'Antagonist Push-up',3,'12','—',45,'Balance the pull · full range','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Warm-up',1,'8 min','—',20,'Hips · shoulders · core','ti-stretching'),
    (w3,2,'Front Lever Progression',4,'15 s','—',90,'Straight arms · pull down','ti-activity'),
    (w3,3,'Toes-to-Bar',4,'8','—',60,'Compress · control swing','ti-activity'),
    (w3,4,'Tension Plank',3,'45 s','—',45,'Full body tight · brace','ti-activity'),
    (w3,5,'Hip Flexor Raise',3,'10 each','—',45,'Tension through legs','ti-activity'),
    (w3,6,'Shoulder Mobility',1,'8 min','—',0,'Open shoulders · breathe','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Activation','ti-stretching'),
    (w4,2,'Overhead Press',4,'8','40',75,'Brace · press tall','ti-barbell'),
    (w4,3,'Dumbbell Bench Press',3,'10','24',75,'Control · full range','ti-barbell'),
    (w4,4,'Reverse Wrist Curl',3,'15','—',45,'Forearm balance · control','ti-activity'),
    (w4,5,'Light Conditioning',1,'10 min','—',0,'Easy aerobic · recover','ti-heart');
  raise notice 'Added Climbing Power & Grip';
end $$;
