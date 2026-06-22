-- ÍslandFit v8 — Sport-specific programs, batch 2 (advanced tier)
-- Evidence-informed, demands-matched, original designs. Level 'advanced' (no collision with v5).
-- Run AFTER v5. Safe to re-run (guarded per program). Sports: Athletics, Swimming, Golf, Volleyball, Tennis.

-- ATHLETICS (sprint/jump bias) — demands: max speed, elastic power, acceleration, max strength base
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Athletics Sprint & Power' and sport='Athletics') then raise notice 'skip Athletics'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Athletics Sprint & Power','Athletics','advanced',4,12,'Max speed · elastic power · acceleration · maximal strength base','ti-run');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Max Strength','Strength',60),(w2,p,2,'Explosive Power','Explosiveness',55),
    (w3,p,3,'Max Speed','Speed',50),(w4,p,4,'Tempo & Core','Endurance',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · skips','ti-stretching'),
    (w1,2,'Back Squat',5,'4','100',180,'Brace · drive · full depth','ti-barbell'),
    (w1,3,'Romanian Deadlift',4,'5','85',120,'Hinge · long hamstrings','ti-barbell'),
    (w1,4,'Bench Press',4,'5','70',120,'Tuck elbows · drive','ti-barbell'),
    (w1,5,'Weighted Pull-up',4,'6','10',90,'Full hang · chest to bar','ti-arrow-up'),
    (w1,6,'Hanging Leg Raise',3,'12','—',45,'Control · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Skips · openers','ti-stretching'),
    (w2,2,'Power Clean',6,'2','70',180,'Triple extension · aggressive pull','ti-barbell'),
    (w2,3,'Push Press',4,'3','55',120,'Dip-drive · punch overhead','ti-arrow-up'),
    (w2,4,'Box Jump',5,'3','—',120,'Max height · land soft','ti-arrow-up'),
    (w2,5,'Standing Long Jump',5,'3','—',90,'Explode forward · stick landing','ti-bolt'),
    (w2,6,'Med Ball Overhead Throw',4,'4','—',75,'Full body · throw far','ti-bolt');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Dynamic Warm-up',1,'10 min','—',30,'Skips · build-ups · drills','ti-stretching'),
    (w3,2,'Acceleration Sprints',6,'20 m','—',150,'Aggressive push · patient rise','ti-run'),
    (w3,3,'Flying Sprints',4,'30 m','—',180,'Build to max · relax at speed','ti-run'),
    (w3,4,'Bounding',4,'20 m','—',120,'Big springs · drive the knee','ti-bolt'),
    (w3,5,'A-Skips',3,'20 m','—',60,'Tall · rhythmic · quick contact','ti-run'),
    (w3,6,'Hip Mobility',1,'6 min','—',0,'Open hips · cool down','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up Jog',1,'8 min','—',30,'Easy build','ti-run'),
    (w4,2,'Tempo Runs',8,'100 m','—',60,'Smooth · 75 percent · float','ti-heart'),
    (w4,3,'Plank Circuit',3,'45 s','—',45,'Front and sides · brace','ti-activity'),
    (w4,4,'Single-Leg Calf Raise',3,'12 each','—',45,'Full range · stiffness','ti-activity'),
    (w4,5,'Cooldown Walk',1,'5 min','—',0,'Settle · breathe','ti-walk');
  raise notice 'Added Athletics Sprint & Power';
end $$;

-- SWIMMING — demands: pulling power & endurance, shoulder health, dryland power, core, aerobic
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Swimming Dryland Power' and sport='Swimming') then raise notice 'skip Swimming'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Swimming Dryland Power','Swimming','advanced',4,12,'Pulling power · shoulder health · explosive starts · dryland engine','ti-swimming');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Pulling Strength','Strength',55),(w2,p,2,'Power & Starts','Explosiveness',50),
    (w3,p,3,'Shoulder Health & Core','Durability',40),(w4,p,4,'Dryland Conditioning','Endurance',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Shoulder Warm-up',1,'6 min','—',30,'Band · cuff · scap','ti-stretching'),
    (w1,2,'Weighted Pull-up',5,'5','10',150,'Full range · lead with chest','ti-arrow-up'),
    (w1,3,'Lat Pulldown',4,'10','—',75,'Long pull · control','ti-activity'),
    (w1,4,'Dumbbell Bench Press',4,'8','28',90,'Control · full range','ti-barbell'),
    (w1,5,'Barbell Row',4,'8','70',90,'Flat back · pull to sternum','ti-barbell'),
    (w1,6,'Pallof Press',3,'10 each','20',45,'Anti-rotation · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Skips · openers','ti-stretching'),
    (w2,2,'Hang Power Clean',5,'3','55',150,'Triple extension · catch tall','ti-barbell'),
    (w2,3,'Squat Jump',5,'3','—',120,'Explode · land soft','ti-arrow-up'),
    (w2,4,'Med Ball Slam',4,'6','—',60,'Overhead · slam hard','ti-bolt'),
    (w2,5,'Plyo Push-up',4,'5','—',90,'Explode off floor · soft catch','ti-bolt'),
    (w2,6,'Streamline Jump',4,'4','—',75,'Tight streamline · vertical drive','ti-arrow-up');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Band Activation',1,'8 min','—',20,'Cuff · scap · all directions','ti-stretching'),
    (w3,2,'Face Pull',4,'15','—',45,'Elbows high · squeeze rear delts','ti-activity'),
    (w3,3,'Scapular Pull-up',3,'8','—',60,'Depress and retract · control','ti-arrow-up'),
    (w3,4,'Pallof Press',3,'12 each','20',45,'Anti-rotation · ribs down','ti-activity'),
    (w3,5,'Hollow Hold',3,'30 s','—',45,'Low back flat · brace','ti-activity'),
    (w3,6,'Thoracic Mobility',1,'6 min','—',0,'Open the t-spine · breathe','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Row Erg Intervals',8,'45s on/30s off','—',30,'Strong pulls · hold pace','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Plank',3,'45 s','—',45,'Straight line · brace','ti-activity'),
    (w4,5,'Mobility Flow',1,'8 min','—',0,'Shoulders · hips · breathe','ti-stretching');
  raise notice 'Added Swimming Dryland Power';
end $$;

-- GOLF (3 days) — demands: rotational power, t-spine/hip mobility, anti-rotation core, posterior chain, grip
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid;
begin
  if exists (select 1 from programs where name='Golf Rotational Power' and sport='Golf') then raise notice 'skip Golf'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Golf Rotational Power','Golf','advanced',3,12,'Rotational power · mobility · anti-rotation core · posterior-chain strength','ti-golf');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Rotational Power','Power',50),(w2,p,2,'Strength & Stability','Strength',50),
    (w3,p,3,'Mobility & Speed','Speed · Mobility',40);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'T-spine · hips · activation','ti-stretching'),
    (w1,2,'Med Ball Rotational Throw',5,'4 each','—',90,'Drive from hip · whip through','ti-bolt'),
    (w1,3,'Cable Woodchop',4,'10 each','20',60,'Rotate from trunk · control','ti-activity'),
    (w1,4,'Landmine Rotation',3,'8 each','20',60,'Hips lead · arms follow','ti-barbell'),
    (w1,5,'Goblet Squat',3,'10','24',75,'Upright · controlled','ti-barbell'),
    (w1,6,'Pallof Press',3,'12 each','20',45,'Anti-rotation · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Hips · core · activation','ti-stretching'),
    (w2,2,'Trap Bar Deadlift',4,'5','90',120,'Flat back · push floor','ti-barbell'),
    (w2,3,'Bulgarian Split Squat',3,'8 each','20',75,'Tall torso · controlled','ti-walk'),
    (w2,4,'Single-Arm Row',3,'10 each','28',60,'Flat back · pull to hip','ti-barbell'),
    (w2,5,'Side Plank',3,'30 s each','—',45,'Stack hips · brace','ti-activity'),
    (w2,6,'Wrist & Grip Work',3,'12','—',45,'Forearm strength · control','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Mobility Flow',1,'10 min','—',20,'T-spine · hips · shoulders','ti-stretching'),
    (w3,2,'Overspeed Med Ball Swing',5,'5 each','—',75,'Fast as possible · stay balanced','ti-bolt'),
    (w3,3,'Half-Kneel Cable Rotation',3,'10 each','15',45,'Smooth rotation · tall spine','ti-activity'),
    (w3,4,'Single-Leg Balance',3,'30 s each','—',45,'Stable hips · control','ti-activity'),
    (w3,5,'Hip Mobility',1,'8 min','—',0,'Open hips · breathe','ti-stretching');
  raise notice 'Added Golf Rotational Power';
end $$;

-- VOLLEYBALL — demands: vertical jump power, shoulder/spike health, landing mechanics, lateral, core
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Volleyball Vertical' and sport='Volleyball') then raise notice 'skip Volleyball'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Volleyball Vertical','Volleyball','advanced',4,12,'Vertical power · spike & shoulder health · landing mechanics · court conditioning','ti-ball-volleyball');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Lower Power & Jump','Explosiveness',60),(w2,p,2,'Upper & Shoulder','Strength · Durability',50),
    (w3,p,3,'Speed & Landing','Speed',45),(w4,p,4,'Conditioning & Core','Endurance',45);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · skips','ti-stretching'),
    (w1,2,'Back Squat',5,'4','85',180,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Squat Jump',5,'3','—',120,'Explode · land soft','ti-arrow-up'),
    (w1,4,'Depth Jump',4,'4','—',120,'Quick contact · max height','ti-arrow-up'),
    (w1,5,'Approach Jump',4,'4','—',90,'Plant · transfer · reach high','ti-bolt'),
    (w1,6,'Pogo Hops',3,'20','—',45,'Stiff ankles · fast contacts','ti-bolt');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band · cuff · scap','ti-stretching'),
    (w2,2,'Bench Press',4,'6','60',120,'Tuck elbows · control','ti-barbell'),
    (w2,3,'Landmine Press',4,'8 each','25',75,'Brace · press up and across','ti-barbell'),
    (w2,4,'Pull-up',4,'8','—',90,'Full hang · chest to bar','ti-arrow-up'),
    (w2,5,'Med Ball Overhead Slam',4,'6','—',60,'Spike pattern · slam hard','ti-bolt'),
    (w2,6,'Face Pull',3,'15','—',45,'Rear delts · cuff health','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups','ti-stretching'),
    (w3,2,'Lateral Bound',4,'5 each','—',75,'Push outside · stick','ti-bolt'),
    (w3,3,'Approach Footwork',4,'6 reps','—',75,'Plant timing · explode up','ti-target-arrow'),
    (w3,4,'Reactive Shuffle',4,'20 s','—',60,'Low · quick · react','ti-bolt'),
    (w3,5,'Single-Leg Landing',3,'6 each','—',60,'Soft · stable knee','ti-activity'),
    (w3,6,'Ankle Mobility',1,'5 min','—',0,'Dorsiflexion · calves','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Interval Conditioning',8,'30s on/30s off','—',30,'Rally-pace efforts','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Pallof Press',3,'10 each','20',45,'Anti-rotation','ti-activity'),
    (w4,5,'Plank',3,'45 s','—',45,'Brace · straight line','ti-activity'),
    (w4,6,'Cooldown Walk',1,'5 min','—',0,'Settle · breathe','ti-walk');
  raise notice 'Added Volleyball Vertical';
end $$;

-- TENNIS — demands: rotational serve/stroke power, repeated lateral movement, first-step speed, shoulder health
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Tennis Court Power' and sport='Tennis') then raise notice 'skip Tennis'; return; end if;
  insert into programs (id,name,sport,level,days_per_week,duration_weeks,description,icon) values
    (p,'Tennis Court Power','Tennis','advanced',4,12,'Rotational power · lateral movement · first-step speed · shoulder durability','ti-ball-tennis');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id,program_id,day_number,title,focus,estimated_min) values
    (w1,p,1,'Lower Strength & Lateral','Strength',55),(w2,p,2,'Rotational & Upper','Power',50),
    (w3,p,3,'Speed & Agility','Speed',45),(w4,p,4,'Conditioning & Core','Endurance',45);
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · skips','ti-stretching'),
    (w1,2,'Back Squat',4,'5','80',150,'Brace · drive · depth','ti-barbell'),
    (w1,3,'Lateral Lunge',3,'8 each','20',75,'Sit into hip · push back','ti-walk'),
    (w1,4,'Romanian Deadlift',3,'6','70',120,'Hinge · hamstrings','ti-barbell'),
    (w1,5,'Split Squat',3,'8 each','22',75,'Tall torso · control','ti-walk'),
    (w1,6,'Side Plank',3,'30 s each','—',45,'Stack hips · brace','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Cuff · t-spine · openers','ti-stretching'),
    (w2,2,'Med Ball Rotational Throw',5,'4 each','—',75,'Hip drive · whip','ti-bolt'),
    (w2,3,'Landmine Press',4,'8 each','22',75,'Brace · press across','ti-barbell'),
    (w2,4,'Pull-up',4,'8','—',90,'Full hang · control','ti-arrow-up'),
    (w2,5,'Cable Woodchop',3,'10 each','20',45,'Trunk rotation · control','ti-activity'),
    (w2,6,'External Rotation',3,'15 each','—',45,'Cuff health · slow','ti-activity');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups','ti-stretching'),
    (w3,2,'Spider Drill',5,'1 rep','—',90,'Explosive court coverage','ti-target-arrow'),
    (w3,3,'Lateral Shuffle',4,'20 s','—',60,'Stay low · quick feet','ti-bolt'),
    (w3,4,'Acceleration Sprints',5,'10 m','—',90,'First-step quickness','ti-run'),
    (w3,5,'Reactive Split-Step',4,'20 s','—',60,'Bounce · react · push','ti-bolt'),
    (w3,6,'Hip Mobility',1,'5 min','—',0,'Open hips · cool down','ti-stretching');
  insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Point-Play Intervals',8,'20s on/40s off','—',30,'Repeat hard efforts','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Pallof Press',3,'10 each','20',45,'Anti-rotation','ti-activity'),
    (w4,5,'Plank',3,'45 s','—',45,'Brace','ti-activity'),
    (w4,6,'Cooldown Walk',1,'5 min','—',0,'Settle','ti-walk');
  raise notice 'Added Tennis Court Power';
end $$;
