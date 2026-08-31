-- 17: fill the seven built-in sport programs that shipped as empty shells.
-- Badminton, Equestrian, Glíma, Gymnastics, Rock Climbing, Strongman and Winter
-- Sports each had a programs row but no program_workouts, so any athlete matched
-- to one of them landed on an empty home screen. Each block below is a no-op if
-- the program already has workouts, so this is safe to re-run.

-- Badminton Performance
with p as (select id from programs where name='Badminton Performance' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Lower Body & Footwork','Legs · Agility',50),(2,'Shoulder & Smash Power','Shoulders · Rotation',45),(3,'Agility & Core','Speed · Core',45)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Ankles · hips · shadow footwork','ti-stretching'),
  (1,2,'Goblet Squat',3,'10','20',90,'Chest tall · knees track the toes','ti-barbell'),
  (1,3,'Split Squat',3,'8 each','12',75,'Long stance · vertical torso','ti-walk'),
  (1,4,'Lateral Lunge',3,'8 each','10',75,'Push the hips back · stay low','ti-arrows-left-right'),
  (1,5,'Shadow Footwork Drill',4,'30 s','—',60,'Six corners · recover to centre','ti-run'),
  (1,6,'Calf Raise',3,'15','30',45,'Pause at the top · slow down','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
  (2,2,'Dumbbell Overhead Press',3,'8','14',90,'Ribs down · press tall','ti-barbell'),
  (2,3,'Medicine Ball Overhead Throw',4,'6','3kg',75,'Full extension · throw through it','ti-bolt'),
  (2,4,'Single-Arm Row',3,'10 each','18',75,'Pull to the hip · no twist','ti-barbell'),
  (2,5,'Band External Rotation',3,'12 each','—',45,'Elbow pinned · slow return','ti-activity'),
  (2,6,'Wrist Flexion & Extension',2,'15 each','4',45,'Light load · full range','ti-hand-move'),
  (3,1,'Skipping Rope',1,'5 min','—',30,'Light feet · relaxed shoulders','ti-run'),
  (3,2,'Ladder Quick Feet',4,'20 s','—',60,'Fast contacts · eyes up','ti-grid-dots'),
  (3,3,'Cone Reaction Drill',4,'20 s','—',75,'Split step · react · explode','ti-target-arrow'),
  (3,4,'Jump Squat',3,'8','—',75,'Soft landings · reset every rep','ti-arrow-up'),
  (3,5,'Plank',3,'40 s','—',45,'Straight line · brace hard','ti-activity'),
  (3,6,'Side Plank',3,'30 s each','—',45,'Hips high · shoulder stacked','ti-activity')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;

-- Equestrian Performance
with p as (select id from programs where name='Equestrian Performance' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Core & Seat Stability','Core · Anti-rotation',45),(2,'Leg Strength & Balance','Legs · Balance',50),(3,'Posture & Conditioning','Back · Endurance',45)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Mobility Warm-up',1,'6 min','—',30,'Hips · thoracic spine · ankles','ti-stretching'),
  (1,2,'Dead Bug',3,'10 each','—',60,'Low back flat · slow tempo','ti-activity'),
  (1,3,'Pallof Press',3,'10 each','15',60,'Resist the rotation · ribs down','ti-activity'),
  (1,4,'Bird Dog',3,'10 each','—',45,'Long spine · no hip drop','ti-activity'),
  (1,5,'Glute Bridge',3,'12','—',60,'Squeeze at the top · ribs down','ti-arrow-up'),
  (1,6,'Side Plank',3,'30 s each','—',45,'Stack the hips · breathe','ti-activity'),
  (2,1,'Dynamic Warm-up',1,'6 min','—',30,'Leg swings · hip circles','ti-stretching'),
  (2,2,'Goblet Squat',3,'10','16',90,'Heels down · knees out','ti-barbell'),
  (2,3,'Romanian Deadlift',3,'10','30',90,'Hinge back · long hamstrings','ti-barbell'),
  (2,4,'Single-Leg Romanian Deadlift',3,'8 each','10',75,'Hips square · slow and steady','ti-activity'),
  (2,5,'Wall Sit',3,'40 s','—',60,'Thighs parallel · quiet breathing','ti-square'),
  (2,6,'Standing Calf Raise',3,'15','20',45,'Full range · controlled','ti-arrow-bar-up'),
  (3,1,'Rowing Machine',1,'8 min','—',30,'Easy aerobic build','ti-heart'),
  (3,2,'Seated Cable Row',3,'12','30',75,'Shoulders down · squeeze','ti-barbell'),
  (3,3,'Face Pull',3,'15','15',60,'Elbows high · pull apart','ti-activity'),
  (3,4,'Reverse Lunge',3,'8 each','10',75,'Drop straight down · tall chest','ti-walk'),
  (3,5,'Farmer Carry',3,'30 m','20',75,'Tall posture · slow deliberate steps','ti-barbell'),
  (3,6,'Hip Flexor Stretch',1,'5 min','—',0,'Tuck the pelvis · breathe','ti-stretching')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;

-- Glíma Wrestling
with p as (select id from programs where name='Glíma Wrestling' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Hip Power','Strength · Explosiveness',60),(2,'Grip & Pulling','Back · Grip',55),(3,'Rotation & Throw','Power · Rotation',55),(4,'Conditioning & Sprawl','Endurance · Core',45)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · shoulders · sprawls','ti-stretching'),
  (1,2,'Back Squat',5,'5','85',150,'Brace · sit between the hips','ti-barbell'),
  (1,3,'Hang Power Clean',5,'3','55',150,'Triple extension · catch tall','ti-barbell'),
  (1,4,'Hip Thrust',4,'8','80',90,'Ribs down · squeeze at lockout','ti-arrow-up'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Turkish Get-up',3,'3 each','16',90,'Slow · own every position','ti-activity'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band work · scap pull-ups','ti-stretching'),
  (2,2,'Weighted Pull-up',4,'5','10',120,'Full hang · lead with the chest','ti-arrow-up'),
  (2,3,'Barbell Row',4,'6','70',105,'Flat back · pull to the navel','ti-barbell'),
  (2,4,'Towel Hang',4,'30 s','—',90,'Crush the towel · shoulders packed','ti-hand-move'),
  (2,5,'Farmer Carry',4,'40 m','40',90,'Tall · braced · do not rush','ti-barbell'),
  (2,6,'Wrist Roller',3,'2','5',60,'Up and down · no swinging','ti-rotate'),
  (3,1,'Mobility Flow',1,'6 min','—',30,'Thoracic rotation · hip openers','ti-stretching'),
  (3,2,'Push Press',4,'5','60',120,'Dip · drive · lock it out','ti-barbell'),
  (3,3,'Med Ball Rotational Throw',4,'5 each','5kg',90,'Drive from the hip · whip through','ti-bolt'),
  (3,4,'Landmine Rotation',3,'8 each','25',75,'Control the arc · brace','ti-rotate'),
  (3,5,'Cable Woodchop',3,'10 each','20',60,'Rotate from the trunk · control back','ti-activity'),
  (3,6,'Hanging Leg Raise',3,'10','—',60,'No swing · curl the pelvis','ti-activity'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Sled Push',8,'20 m','60',90,'Low angle · relentless steps','ti-run'),
  (4,3,'Kettlebell Swing',5,'15','32',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Burpee',5,'10','—',60,'Hips to the floor · pop straight up','ti-flame'),
  (4,5,'Bear Crawl',4,'20 m','—',60,'Knees low · quiet hands','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;

-- Gymnastics Foundation
with p as (select id from programs where name='Gymnastics Foundation' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Pull & Hollow','Back · Core',50),(2,'Push & Handstand','Shoulders · Balance',50),(3,'Legs & Flexibility','Legs · Mobility',50)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Joint Prep',1,'8 min','—',30,'Wrists · shoulders · hips','ti-stretching'),
  (1,2,'Scapular Pull-up',3,'8','—',75,'Depress the shoulders · arms straight','ti-arrow-up'),
  (1,3,'Assisted Pull-up',4,'6','—',105,'Full range · control the descent','ti-arrow-up'),
  (1,4,'Ring Row',3,'10','—',75,'Body straight · pull to the chest','ti-activity'),
  (1,5,'Hollow Body Hold',4,'20 s','—',60,'Low back pressed into the floor','ti-activity'),
  (1,6,'Dead Hang',3,'30 s','—',60,'Relax · breathe · build the grip','ti-hand-move'),
  (2,1,'Wrist & Shoulder Prep',1,'8 min','—',30,'Wrist rocks · band dislocates','ti-stretching'),
  (2,2,'Wall Handstand Hold',5,'30 s','—',90,'Ribs down · push the floor away','ti-arrow-up'),
  (2,3,'Pike Push-up',3,'8','—',90,'Head between the hands','ti-activity'),
  (2,4,'Parallel Bar Support Hold',4,'20 s','—',75,'Elbows locked · shoulders down','ti-square'),
  (2,5,'Push-up',3,'10','—',60,'Straight line · full lockout','ti-activity'),
  (2,6,'Bench Dip',3,'10','—',60,'Slow down · no shrugging','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'8 min','—',30,'Leg swings · hip circles','ti-stretching'),
  (3,2,'Bodyweight Squat',3,'15','—',60,'Heels down · knees out','ti-activity'),
  (3,3,'Split Squat',3,'8 each','—',75,'Vertical torso · long stance','ti-walk'),
  (3,4,'Jump Squat',3,'8','—',75,'Soft landings · reset every rep','ti-arrow-up'),
  (3,5,'Pancake Stretch',3,'60 s','—',30,'Long spine · breathe into it','ti-stretching'),
  (3,6,'Pike Stretch',3,'60 s','—',30,'Hinge from the hips · relax','ti-stretching')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;

-- Rock Climbing Strength
with p as (select id from programs where name='Rock Climbing Strength' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Pull Strength','Back · Grip',50),(2,'Core & Body Tension','Core · Tension',45),(3,'Legs & Antagonist','Legs · Balance work',45)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Shoulder Prep',1,'8 min','—',30,'Band work · scap pull-ups','ti-stretching'),
  (1,2,'Pull-up',4,'5','—',120,'Full hang · lead with the chest','ti-arrow-up'),
  (1,3,'Inverted Row',3,'10','—',75,'Body straight · pull to the chest','ti-activity'),
  (1,4,'Lat Pulldown',3,'10','40',75,'Shoulders down · control the way up','ti-barbell'),
  (1,5,'Dead Hang',4,'30 s','—',90,'Shoulders engaged · breathe','ti-hand-move'),
  (1,6,'Face Pull',3,'15','15',45,'Elbows high · pull apart','ti-activity'),
  (2,1,'Mobility Flow',1,'6 min','—',30,'Hips · thoracic spine','ti-stretching'),
  (2,2,'Hanging Knee Raise',4,'10','—',75,'No swing · curl the pelvis','ti-activity'),
  (2,3,'Front Lever Tuck Hold',4,'15 s','—',90,'Straight arms · hollow body','ti-activity'),
  (2,4,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (2,5,'Side Plank',3,'30 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (2,6,'Toes-to-Bar Negative',3,'6','—',60,'Slow lower · stay tight','ti-arrow-down'),
  (3,1,'Dynamic Warm-up',1,'6 min','—',30,'Hips · ankles · high steps','ti-stretching'),
  (3,2,'Goblet Squat',3,'10','20',90,'Heels down · knees out','ti-barbell'),
  (3,3,'Step-up',3,'10 each','12',75,'Drive through the whole foot','ti-walk'),
  (3,4,'Push-up',3,'12','—',60,'Straight line · full lockout','ti-activity'),
  (3,5,'Wrist Extension',3,'15','4',45,'Balances all the pulling work','ti-hand-move'),
  (3,6,'Band Finger Extension',3,'15','—',45,'Open the hand against the band','ti-hand-move')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;

-- Strongman Training
with p as (select id from programs where name='Strongman Training' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Max Lower','Squat · Deadlift',70),(2,'Overhead & Press','Shoulders · Pressing',65),(3,'Event Day','Carries · Stones',60),(4,'Hypertrophy & Grip','Volume · Grip',55)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Warm-up',1,'10 min','—',30,'Bike · hips · light squats','ti-stretching'),
  (1,2,'Back Squat',5,'3','140',210,'Brace hard · sit between the hips','ti-barbell'),
  (1,3,'Deadlift',4,'3','180',210,'Push the floor away · lats tight','ti-barbell'),
  (1,4,'Front Squat',3,'5','90',150,'Elbows high · stay upright','ti-barbell'),
  (1,5,'Back Extension',3,'12','20',90,'Squeeze the glutes at the top','ti-activity'),
  (1,6,'Standing Calf Raise',3,'12','60',60,'Full range · pause at the top','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band work · empty bar presses','ti-stretching'),
  (2,2,'Log Press',5,'3','70',180,'Big leg drive · lock out overhead','ti-barbell'),
  (2,3,'Push Press',4,'4','80',150,'Dip · drive · punch the bar up','ti-barbell'),
  (2,4,'Close-Grip Bench Press',4,'6','90',120,'Elbows tucked · drive the feet','ti-barbell'),
  (2,5,'Barbell Row',4,'8','80',105,'Flat back · pull to the navel','ti-barbell'),
  (2,6,'Triceps Pushdown',3,'12','30',60,'Elbows pinned · full lockout','ti-activity'),
  (3,1,'Warm-up',1,'10 min','—',30,'Full body · rehearse the events','ti-activity'),
  (3,2,'Yoke Walk',5,'20 m','160',180,'Short fast steps · stay braced','ti-run'),
  (3,3,'Farmer Carry',5,'20 m','80',150,'Tall posture · crush the handles','ti-barbell'),
  (3,4,'Atlas Stone Over Bar',4,'3','80',180,'Hips through · seal the stone','ti-ball-basketball'),
  (3,5,'Sandbag Carry',4,'30 m','60',120,'Hug it high · brace and breathe','ti-activity'),
  (3,6,'Sled Drag',4,'25 m','80',90,'Lean back · relentless steps','ti-run'),
  (4,1,'Warm-up',1,'6 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Incline Dumbbell Press',4,'10','32',90,'Control down · press together','ti-barbell'),
  (4,3,'Romanian Deadlift',4,'8','120',105,'Hinge back · long hamstrings','ti-barbell'),
  (4,4,'Weighted Pull-up',4,'6','15',105,'Full hang · lead with the chest','ti-arrow-up'),
  (4,5,'Thick Bar Hold',4,'30 s','80',90,'Crush the bar · stay tall','ti-hand-move'),
  (4,6,'Wrist Roller',3,'2','10',60,'Up and down · no swinging','ti-rotate')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;

-- Skiing & Snowboarding
with p as (select id from programs where name='Skiing & Snowboarding' and is_custom=false),
     w as (insert into program_workouts (program_id, day_number, title, focus, estimated_min)
           select p.id, v.d, v.t, v.f, v.m from p, (values (1,'Leg Endurance','Legs · Endurance',50),(2,'Balance & Lateral Power','Balance · Plyometrics',45),(3,'Core & Conditioning','Core · Aerobic',45)) as v(d,t,f,m)
           where not exists (select 1 from program_workouts x where x.program_id=p.id)
           returning id, day_number)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from (values (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · leg swings','ti-stretching'),
  (1,2,'Goblet Squat',3,'12','20',90,'Heels down · knees out','ti-barbell'),
  (1,3,'Wall Sit',4,'45 s','—',75,'Thighs parallel · breathe through it','ti-square'),
  (1,4,'Reverse Lunge',3,'10 each','12',75,'Drop straight down · tall chest','ti-walk'),
  (1,5,'Step-up',3,'10 each','12',75,'Drive through the whole foot','ti-arrow-up'),
  (1,6,'Standing Calf Raise',3,'15','30',45,'Pause at the top','ti-arrow-bar-up'),
  (2,1,'Mobility Flow',1,'6 min','—',30,'Ankles · hips · thoracic spine','ti-stretching'),
  (2,2,'Lateral Bound',4,'5 each','—',90,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (2,3,'Skater Jump',3,'10 each','—',75,'Land soft · hold for a beat','ti-bolt'),
  (2,4,'Single-Leg Balance',3,'30 s each','—',45,'Eyes forward · quiet foot','ti-activity'),
  (2,5,'Single-Leg Romanian Deadlift',3,'8 each','10',75,'Hips square · slow and steady','ti-activity'),
  (2,6,'Box Jump',3,'6','—',75,'Land quiet · step back down','ti-arrow-up'),
  (3,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (3,2,'Bike Intervals',8,'40s on/80s off','—',30,'Hard efforts · hold the quality','ti-heart'),
  (3,3,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (3,4,'Side Plank',3,'30 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (3,5,'Russian Twist',3,'20','8',45,'Rotate from the trunk · slow','ti-rotate'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching')) as x(d,o,n,s,r,tw,rest,c,i) join w on w.day_number=x.d;
