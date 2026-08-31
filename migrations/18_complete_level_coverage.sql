-- 18: complete the sport x level grid for the built-in programmes.
-- Every sport previously had only two of the three levels. Five sports
-- (CrossFit, Glima, MMA, Powerlifting, Strongman) had no beginner programme at
-- all, so a true novice was matched to intermediate loads; sixteen sports had
-- no intermediate; General had no advanced. renderProgramMatch() falls back to
-- matches[0] when the level does not match, which is how those mismatches
-- reached real athletes. Each block is a no-op if the programme already exists,
-- so this is safe to re-run.

-- Advanced Strength & Power (General · advanced)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Advanced Strength & Power','General','advanced',5,12,'High-volume upper/lower split with olympic pulls and accessory work','ti-barbell',false
  where not exists (select 1 from programs where name='Advanced Strength & Power') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Heavy Lower','Squat · Max strength',70),(2,'Heavy Upper','Bench · Pressing',65),(3,'Power & Pulls','Olympic · Explosiveness',60),(4,'Volume Lower','Hinge · Hypertrophy',65),(5,'Volume Upper','Back · Arms',60)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Warm-up',1,'10 min','—',30,'Bike · hips · ramping squat sets','ti-stretching'),
  (1,2,'Back Squat',5,'3','85% 1RM',210,'Brace hard · sit between the hips','ti-barbell'),
  (1,3,'Front Squat',3,'5','70% 1RM',150,'Elbows high · stay upright','ti-barbell'),
  (1,4,'Bulgarian Split Squat',3,'8 each','24',105,'Long stance · knee tracks the toes','ti-walk'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Hanging Leg Raise',3,'12','—',60,'No swing · curl the pelvis','ti-activity'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band work · ramping bench sets','ti-stretching'),
  (2,2,'Bench Press',5,'3','85% 1RM',210,'Tuck the elbows · drive the feet','ti-barbell'),
  (2,3,'Overhead Press',4,'5','60',150,'Ribs down · press tall · lock out','ti-barbell'),
  (2,4,'Weighted Pull-up',4,'5','15',120,'Full hang · lead with the chest','ti-arrow-up'),
  (2,5,'Incline Dumbbell Press',3,'8','30',90,'Control down · press together','ti-barbell'),
  (2,6,'Face Pull',3,'15','20',60,'Elbows high · pull apart','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'10 min','—',30,'Hips · shoulders · empty bar pulls','ti-stretching'),
  (3,2,'Power Clean',6,'2','75% 1RM',180,'Triple extension · catch tall','ti-barbell'),
  (3,3,'Push Press',5,'3','75',150,'Dip · drive · punch the bar up','ti-barbell'),
  (3,4,'Snatch-Grip High Pull',4,'3','60',120,'Bar close · elbows lead','ti-barbell'),
  (3,5,'Box Jump',5,'3','—',120,'Land quiet · step back down','ti-arrow-up'),
  (3,6,'Med Ball Rotational Throw',3,'5 each','5kg',90,'Drive from the hip · whip through','ti-bolt'),
  (4,1,'Warm-up',1,'8 min','—',30,'Hips · hamstrings · light hinges','ti-stretching'),
  (4,2,'Deadlift',4,'5','80% 1RM',180,'Push the floor away · lats tight','ti-barbell'),
  (4,3,'Romanian Deadlift',4,'8','100',120,'Hinge back · long hamstrings','ti-barbell'),
  (4,4,'Hip Thrust',4,'8','120',105,'Ribs down · squeeze at lockout','ti-arrow-up'),
  (4,5,'Walking Lunge',3,'12 each','20',90,'Long steps · tall chest','ti-walk'),
  (4,6,'Standing Calf Raise',4,'12','70',60,'Full range · pause at the top','ti-arrow-bar-up'),
  (5,1,'Warm-up',1,'6 min','—',30,'Band work · easy rowing','ti-activity'),
  (5,2,'Barbell Row',4,'8','90',105,'Flat back · pull to the navel','ti-barbell'),
  (5,3,'Close-Grip Bench Press',4,'8','80',105,'Elbows tucked · drive the feet','ti-barbell'),
  (5,4,'Lat Pulldown',4,'10','60',75,'Shoulders down · control the way up','ti-barbell'),
  (5,5,'Lateral Raise',4,'12','10',60,'Lead with the elbow · no swing','ti-activity'),
  (5,6,'Barbell Curl',3,'10','30',60,'Elbows pinned · slow lower','ti-barbell')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Alpine Development (Winter Sports · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Alpine Development','Winter Sports','intermediate',4,12,'Eccentric leg strength, lateral power and the endurance for a full day','ti-ski-jumping',false
  where not exists (select 1 from programs where name='Alpine Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Leg Strength','Legs · Eccentric',55),(2,'Lateral Power','Balance · Plyometrics',50),(3,'Posterior & Core','Hinge · Core',50),(4,'Conditioning','Engine · Legs',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · leg swings','ti-stretching'),
  (1,2,'Back Squat',4,'6','75',150,'Slow down · brace · drive out','ti-barbell'),
  (1,3,'Bulgarian Split Squat',4,'8 each','20',105,'Long stance · knee tracks the toes','ti-walk'),
  (1,4,'Wall Sit',4,'60 s','—',75,'Thighs parallel · breathe through it','ti-square'),
  (1,5,'Eccentric Leg Extension',3,'10','30',75,'5 seconds down · control the burn','ti-activity'),
  (1,6,'Standing Calf Raise',3,'15','50',45,'Full range · pause at the top','ti-arrow-bar-up'),
  (2,1,'Mobility Flow',1,'6 min','—',30,'Ankles · hips · thoracic spine','ti-stretching'),
  (2,2,'Lateral Bound',5,'5 each','—',105,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (2,3,'Skater Jump',4,'10 each','—',90,'Land soft · hold for a beat','ti-bolt'),
  (2,4,'Box Jump',4,'5','—',105,'Land quiet · step back down','ti-arrow-up'),
  (2,5,'Single-Leg Balance',3,'45 s each','—',45,'Eyes forward · quiet foot','ti-activity'),
  (2,6,'Lateral Lunge',3,'8 each','20',75,'Push the hips back · stay low','ti-arrows-left-right'),
  (3,1,'Warm-up',1,'8 min','—',30,'Hips · hamstrings · light hinges','ti-stretching'),
  (3,2,'Trap Bar Deadlift',4,'5','100',150,'Push the floor away · neutral spine','ti-barbell'),
  (3,3,'Romanian Deadlift',3,'8','70',105,'Hinge back · long hamstrings','ti-barbell'),
  (3,4,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (3,5,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (3,6,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Bike Intervals',10,'60s on/60s off','—',30,'Legs burning · keep the cadence','ti-heart'),
  (4,3,'Kettlebell Swing',4,'15','28',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Step-up',3,'12 each','16',75,'Drive through the whole foot','ti-arrow-up'),
  (4,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (4,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Athletics Development (Athletics · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Athletics Development','Athletics','intermediate',4,12,'Sprint mechanics, barbell strength and plyometrics between foundation and elite','ti-run',false
  where not exists (select 1 from programs where name='Athletics Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Speed & Acceleration','Speed · Posterior',55),(2,'Strength','Squat · Olympic',60),(3,'Plyometrics & Jumps','Power · Elasticity',50),(4,'Tempo & Core','Tempo · Core',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'10 min','—',30,'A-skips · build-ups · openers','ti-stretching'),
  (1,2,'Acceleration Sprints',6,'20 m','—',150,'Hard push · low heel recovery','ti-run'),
  (1,3,'Flying Sprints',4,'30 m','—',180,'Build in · relax at top speed','ti-run'),
  (1,4,'Trap Bar Deadlift',4,'5','100',150,'Push the floor away · neutral spine','ti-barbell'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Hip Mobility Flow',1,'6 min','—',0,'Open the hips · breathe · cool down','ti-stretching'),
  (2,1,'Warm-up',1,'8 min','—',30,'Bike · hips · ramping sets','ti-stretching'),
  (2,2,'Back Squat',5,'4','90',180,'Brace · sit between the hips · drive','ti-barbell'),
  (2,3,'Hang Power Clean',5,'3','60',150,'Triple extension · catch tall','ti-barbell'),
  (2,4,'Bulgarian Split Squat',3,'8 each','20',105,'Long stance · knee tracks the toes','ti-walk'),
  (2,5,'Weighted Pull-up',3,'6','10',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,6,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'10 min','—',30,'Skips · pogo hops · build-ups','ti-stretching'),
  (3,2,'Depth Jump',4,'4','—',150,'Drop · minimal contact · explode up','ti-arrow-up'),
  (3,3,'Bounding',5,'20 m','—',120,'Long strides · drive the knee','ti-bolt'),
  (3,4,'Single-Leg Hop',4,'5 each','—',90,'Soft landings · stable knee','ti-bolt'),
  (3,5,'Med Ball Overhead Throw',4,'5','4kg',90,'Full extension · throw through it','ti-bolt'),
  (3,6,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (4,1,'Warm-up',1,'8 min','—',30,'Easy jog · drills','ti-run'),
  (4,2,'Tempo Runs',8,'100 m','—',60,'Relaxed 75% · consistent splits','ti-run'),
  (4,3,'Kettlebell Swing',4,'15','28',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Hanging Leg Raise',3,'12','—',60,'No swing · curl the pelvis','ti-activity'),
  (4,5,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Badminton Development (Badminton · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Badminton Development','Badminton','intermediate',4,12,'Court speed, overhead power and rally conditioning','ti-trophy',false
  where not exists (select 1 from programs where name='Badminton Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Power','Legs · Plyometrics',55),(2,'Overhead Power','Shoulders · Pressing',50),(3,'Court Speed','Footwork · Reaction',45),(4,'Rotation & Endurance','Rotation · Engine',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Ankles · hips · shadow footwork','ti-stretching'),
  (1,2,'Back Squat',4,'5','70',150,'Brace · sit between the hips','ti-barbell'),
  (1,3,'Split Squat',4,'6 each','20',105,'Long stance · vertical torso','ti-walk'),
  (1,4,'Lateral Bound',4,'5 each','—',90,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Calf Raise',3,'15','50',45,'Pause at the top','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
  (2,2,'Push Press',4,'5','45',120,'Dip · drive · lock out overhead','ti-barbell'),
  (2,3,'Medicine Ball Overhead Throw',4,'6','4kg',90,'Full extension · throw through it','ti-bolt'),
  (2,4,'Weighted Pull-up',3,'6','8',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,5,'Single-Arm Row',3,'10 each','24',75,'Pull to the hip · no twist','ti-barbell'),
  (2,6,'Band External Rotation',3,'15 each','—',45,'Elbow pinned · slow return','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Skips · side shuffles · split steps','ti-run'),
  (3,2,'Shadow Footwork Drill',6,'45 s','—',90,'Six corners · recover to centre','ti-run'),
  (3,3,'Cone Reaction Drill',5,'20 s','—',75,'Split step · react · explode','ti-target-arrow'),
  (3,4,'Lunge Jump',4,'8','—',75,'Switch in the air · land soft','ti-bolt'),
  (3,5,'Depth Jump',3,'4','—',120,'Drop · minimal contact · explode up','ti-arrow-up'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Rotational MB Throw',4,'5 each','4kg',90,'Drive from the hip · whip through','ti-rotate'),
  (4,3,'Cable Woodchop',3,'12 each','25',60,'Rotate from the trunk · control back','ti-activity'),
  (4,4,'Bike Intervals',10,'30s on/60s off','—',30,'Match a rally · repeat the quality','ti-heart'),
  (4,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (4,6,'Cooldown Stretch',1,'5 min','—',0,'Shoulders · hips · breathe','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Basketball Development (Basketball · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Basketball Development','Basketball','intermediate',4,12,'Vertical power, change of direction and repeat-sprint conditioning','ti-ball-basketball',false
  where not exists (select 1 from programs where name='Basketball Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Power','Legs · Jump',55),(2,'Upper & Core','Upper body · Core',50),(3,'Agility & Cutting','Change of direction',45),(4,'Conditioning','RSA · Endurance',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · A-skips','ti-stretching'),
  (1,2,'Back Squat',4,'5','80',150,'Brace · sit between the hips','ti-barbell'),
  (1,3,'Trap Bar Deadlift',4,'5','100',150,'Push the floor away · neutral spine','ti-barbell'),
  (1,4,'Box Jump',4,'4','—',120,'Land quiet · step back down','ti-arrow-up'),
  (1,5,'Bulgarian Split Squat',3,'8 each','20',90,'Long stance · knee tracks the toes','ti-walk'),
  (1,6,'Calf Raise',3,'15','50',45,'Pause at the top','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band work · scap pull-ups','ti-stretching'),
  (2,2,'Bench Press',4,'6','60',120,'Tuck the elbows · drive the feet','ti-barbell'),
  (2,3,'Weighted Pull-up',4,'6','10',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,4,'Dumbbell Overhead Press',3,'8','20',90,'Ribs down · press tall','ti-barbell'),
  (2,5,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (2,6,'Hanging Leg Raise',3,'12','—',60,'No swing · curl the pelvis','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Side shuffles · carioca · build-ups','ti-run'),
  (3,2,'5-10-5 Pro Agility',6,'1 rep','—',90,'Plant low · explode out of the cut','ti-target-arrow'),
  (3,3,'Lateral Bound',4,'5 each','—',90,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (3,4,'Defensive Slide Drill',4,'25 s','—',75,'Stay low · no crossover','ti-activity'),
  (3,5,'Acceleration Sprints',6,'15 m','—',90,'Hard push · low heel recovery','ti-run'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Repeated Sprint Intervals',10,'15s on/45s off','—',30,'Repeat max efforts · hold the quality','ti-heart'),
  (4,3,'Kettlebell Swing',4,'15','28',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (4,5,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Climbing Development (Rock Climbing · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Climbing Development','Rock Climbing','intermediate',4,12,'Hangboard finger strength, lock-off power and body tension','ti-mountain',false
  where not exists (select 1 from programs where name='Climbing Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Pull & Lock-off','Back · Pulling',55),(2,'Fingers & Hangboard','Grip · Fingers',45),(3,'Core Tension','Core · Tension',45),(4,'Legs & Antagonist','Legs · Balance work',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Shoulder Prep',1,'10 min','—',30,'Band work · scap pull-ups · easy climbing','ti-stretching'),
  (1,2,'Weighted Pull-up',5,'5','10',150,'Full hang · lead with the chest','ti-arrow-up'),
  (1,3,'Lock-off Hold',4,'10 s each','—',105,'Hold at 90° · shoulder engaged','ti-activity'),
  (1,4,'Campus Ladder',4,'4','—',150,'Controlled catches · no swinging','ti-bolt'),
  (1,5,'Ring Row',3,'10','—',75,'Body straight · pull to the chest','ti-activity'),
  (1,6,'Face Pull',3,'15','18',60,'Elbows high · pull apart','ti-activity'),
  (2,1,'Finger Warm-up',1,'12 min','—',30,'Easy hangs · build up gradually · never rush this','ti-stretching'),
  (2,2,'Hangboard Repeaters',6,'7 s','—',180,'20 mm edge · half crimp · 7 on / 3 off ×6','ti-hand-move'),
  (2,3,'Half Crimp Max Hang',5,'10 s','10',180,'Add weight only if form holds','ti-hand-move'),
  (2,4,'Open Hand Hang',4,'15 s','—',120,'Fingers relaxed open · shoulders packed','ti-hand-move'),
  (2,5,'Wrist Extension',3,'15','5',45,'Balances all the pulling work','ti-hand-move'),
  (2,6,'Band Finger Extension',3,'15','—',45,'Open the hand against the band','ti-hand-move'),
  (3,1,'Mobility Flow',1,'6 min','—',30,'Hips · thoracic spine','ti-stretching'),
  (3,2,'Front Lever Tuck Hold',5,'15 s','—',105,'Straight arms · hollow body','ti-activity'),
  (3,3,'Toes-to-Bar',4,'8','—',90,'No swing · curl the pelvis','ti-arrow-up'),
  (3,4,'Hanging Windshield Wiper',3,'6 each','—',90,'Slow and controlled · stay tight','ti-rotate'),
  (3,5,'Hollow Body Hold',4,'30 s','—',60,'Low back pressed into the floor','ti-activity'),
  (3,6,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,1,'Dynamic Warm-up',1,'6 min','—',30,'Hips · ankles · high steps','ti-stretching'),
  (4,2,'Back Squat',4,'6','60',120,'Heels down · knees out · brace','ti-barbell'),
  (4,3,'Step-up',3,'10 each','16',75,'Drive through the whole foot','ti-walk'),
  (4,4,'High Step Drill',3,'8 each','—',75,'Push through the heel · stay over the foot','ti-activity'),
  (4,5,'Push-up',3,'15','—',60,'Straight line · full lockout','ti-activity'),
  (4,6,'Shoulder Mobility Flow',1,'5 min','—',0,'Open the chest · breathe','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- CrossFit Fundamentals (CrossFit · beginner)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'CrossFit Fundamentals','CrossFit','beginner',3,12,'Learn the core lifts and build an engine before scaling up','ti-flame',false
  where not exists (select 1 from programs where name='CrossFit Fundamentals') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Movement & Squat','Technique · Legs',50),(2,'Press & Engine','Shoulders · Aerobic',50),(3,'Hinge & Conditioning','Posterior · Metcon',50)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Bike · hips · shoulders','ti-stretching'),
  (1,2,'Air Squat',4,'12','—',75,'Heels down · knees out · full depth','ti-activity'),
  (1,3,'Goblet Squat',3,'10','16',90,'Chest tall · elbows inside the knees','ti-barbell'),
  (1,4,'Ring Row',3,'10','—',75,'Body straight · pull to the chest','ti-activity'),
  (1,5,'AMRAP Circuit',1,'10 min','—',0,'10 air squats · 8 ring rows · 6 push-ups','ti-flame'),
  (1,6,'Cooldown Stretch',1,'5 min','—',0,'Hips · shoulders · breathe','ti-stretching'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band work · PVC pass-throughs','ti-stretching'),
  (2,2,'Strict Press',4,'8','25',90,'Ribs down · press tall · lock out','ti-barbell'),
  (2,3,'Push-up',3,'8','—',75,'Straight line · full lockout','ti-activity'),
  (2,4,'Dumbbell Row',3,'10 each','14',75,'Pull to the hip · no twist','ti-barbell'),
  (2,5,'Row Intervals',6,'250 m','—',90,'Steady pace · same split every round','ti-heart'),
  (2,6,'Plank',3,'30 s','—',45,'Straight line · brace hard','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · hamstrings · light hinges','ti-stretching'),
  (3,2,'Deadlift',4,'8','50',105,'Push the floor away · flat back','ti-barbell'),
  (3,3,'Kettlebell Swing',4,'12','16',75,'Hip snap · float the bell','ti-flame'),
  (3,4,'Box Step-up',3,'10 each','10',75,'Drive through the whole foot','ti-arrow-up'),
  (3,5,'EMOM Circuit',1,'12 min','—',0,'10 swings · 8 step-ups · rest the remainder','ti-clock'),
  (3,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Cyclist Development (Cycling · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Cyclist Development','Cycling','intermediate',4,12,'Threshold work paired with the gym strength that holds power late in a ride','ti-bike',false
  where not exists (select 1 from programs where name='Cyclist Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Leg Strength','Legs · Gym',55),(2,'Threshold Ride','FTP · Bike',60),(3,'Power & Core','Hinge · Core',50),(4,'Endurance Ride','Aerobic base',90)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Warm-up',1,'8 min','—',30,'Easy spin · hips · light squats','ti-stretching'),
  (1,2,'Back Squat',4,'6','75',150,'Brace · sit between the hips','ti-barbell'),
  (1,3,'Romanian Deadlift',4,'8','70',105,'Hinge back · long hamstrings','ti-barbell'),
  (1,4,'Step-up',3,'10 each','20',90,'Drive through the whole foot','ti-arrow-up'),
  (1,5,'Single-Leg Calf Raise',3,'12 each','20',60,'Full range · pause at the top','ti-arrow-bar-up'),
  (1,6,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (2,1,'Warm-up Spin',1,'15 min','—',0,'Easy build · a few short openers','ti-heart'),
  (2,2,'Threshold Intervals',4,'8 min','—',240,'Just below race pace · steady power','ti-heart'),
  (2,3,'Cadence Drills',4,'2 min','—',120,'High cadence · quiet upper body','ti-rotate'),
  (2,4,'Cooldown Spin',1,'10 min','—',0,'Easy gear · settle the legs','ti-heart'),
  (2,5,'Hip Flexor Stretch',1,'4 min','—',0,'Tuck the pelvis · breathe','ti-stretching'),
  (2,6,'Foam Roll Quads',1,'4 min','—',0,'Slow passes · breathe out the tension','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Hips · glutes · light hinges','ti-stretching'),
  (3,2,'Trap Bar Deadlift',4,'5','90',150,'Push the floor away · neutral spine','ti-barbell'),
  (3,3,'Hip Thrust',4,'8','80',90,'Ribs down · squeeze at lockout','ti-arrow-up'),
  (3,4,'Box Jump',4,'4','—',120,'Land quiet · step back down','ti-arrow-up'),
  (3,5,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (3,6,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,1,'Warm-up Spin',1,'10 min','—',0,'Easy build','ti-heart'),
  (4,2,'Steady Endurance Ride',1,'60 min','—',0,'Conversational pace · stay fuelled','ti-heart'),
  (4,3,'Seated Climb Efforts',4,'3 min','—',120,'Big gear · stay seated · smooth','ti-mountain'),
  (4,4,'Cooldown Spin',1,'10 min','—',0,'Easy gear · settle the legs','ti-heart'),
  (4,5,'Hamstring Stretch',1,'4 min','—',0,'Long spine · breathe into it','ti-stretching'),
  (4,6,'Foam Roll IT Band',1,'4 min','—',0,'Slow passes · do not rush','ti-activity')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Equestrian Development (Equestrian · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Equestrian Development','Equestrian','intermediate',4,12,'Loaded core work, single-leg strength and the endurance to ride long','ti-horse-toy',false
  where not exists (select 1 from programs where name='Equestrian Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Core & Anti-rotation','Core · Bracing',45),(2,'Leg Strength','Legs · Single leg',55),(3,'Posture & Upper','Back · Shoulders',45),(4,'Balance & Conditioning','Balance · Engine',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Mobility Warm-up',1,'6 min','—',30,'Hips · thoracic spine · ankles','ti-stretching'),
  (1,2,'Pallof Press',4,'10 each','25',60,'Resist the rotation · ribs down','ti-activity'),
  (1,3,'Weighted Dead Bug',3,'10 each','6',60,'Low back flat · slow tempo','ti-activity'),
  (1,4,'Hanging Knee Raise',3,'12','—',60,'No swing · curl the pelvis','ti-activity'),
  (1,5,'Suitcase Carry',3,'30 m each','24',75,'Do not lean · stay square','ti-barbell'),
  (1,6,'Side Plank',3,'40 s each','—',45,'Stack the hips · breathe','ti-activity'),
  (2,1,'Dynamic Warm-up',1,'8 min','—',30,'Leg swings · hip circles','ti-stretching'),
  (2,2,'Back Squat',4,'6','60',150,'Heels down · knees out · brace','ti-barbell'),
  (2,3,'Romanian Deadlift',4,'8','60',105,'Hinge back · long hamstrings','ti-barbell'),
  (2,4,'Bulgarian Split Squat',3,'8 each','16',90,'Long stance · vertical torso','ti-walk'),
  (2,5,'Wall Sit',3,'60 s','—',60,'Thighs parallel · quiet breathing','ti-square'),
  (2,6,'Standing Calf Raise',3,'15','30',45,'Full range · controlled','ti-arrow-bar-up'),
  (3,1,'Shoulder Warm-up',1,'6 min','—',30,'Band pull-aparts · scap work','ti-stretching'),
  (3,2,'Barbell Row',4,'8','45',90,'Flat back · pull to the navel','ti-barbell'),
  (3,3,'Lat Pulldown',3,'10','40',75,'Shoulders down · control the way up','ti-barbell'),
  (3,4,'Face Pull',3,'15','18',60,'Elbows high · pull apart','ti-activity'),
  (3,5,'Dumbbell Overhead Press',3,'8','16',90,'Ribs down · press tall','ti-barbell'),
  (3,6,'Thoracic Extension',1,'5 min','—',0,'Open the chest · breathe','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Single-Leg Balance',3,'45 s each','—',45,'Eyes forward · quiet foot','ti-activity'),
  (4,3,'Single-Leg Romanian Deadlift',3,'8 each','14',75,'Hips square · slow and steady','ti-activity'),
  (4,4,'Rowing Intervals',6,'300 m','—',90,'Steady split · drive with the legs','ti-heart'),
  (4,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (4,6,'Hip Flexor Stretch',1,'5 min','—',0,'Tuck the pelvis · breathe','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Glíma Foundation (Glíma · beginner)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Glíma Foundation','Glíma','beginner',3,12,'Build the hips, grip and balance that Icelandic wrestling asks for','ti-karate',false
  where not exists (select 1 from programs where name='Glíma Foundation') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Hips & Legs','Legs · Hinge',50),(2,'Grip & Pulling','Back · Grip',45),(3,'Balance & Conditioning','Balance · Endurance',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · shoulders · light sprawls','ti-stretching'),
  (1,2,'Goblet Squat',4,'10','20',90,'Heels down · knees out','ti-barbell'),
  (1,3,'Romanian Deadlift',3,'10','40',90,'Hinge back · long hamstrings','ti-barbell'),
  (1,4,'Glute Bridge',3,'12','—',60,'Squeeze at the top · ribs down','ti-arrow-up'),
  (1,5,'Reverse Lunge',3,'8 each','10',75,'Drop straight down · tall chest','ti-walk'),
  (1,6,'Dead Bug',3,'10 each','—',45,'Low back flat · slow tempo','ti-activity'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band work · scap pull-ups','ti-stretching'),
  (2,2,'Inverted Row',4,'10','—',75,'Body straight · pull to the chest','ti-activity'),
  (2,3,'Lat Pulldown',3,'10','35',75,'Shoulders down · control the way up','ti-barbell'),
  (2,4,'Dead Hang',4,'20 s','—',75,'Relax · breathe · build the grip','ti-hand-move'),
  (2,5,'Farmer Carry',3,'30 m','20',75,'Tall posture · brace','ti-barbell'),
  (2,6,'Face Pull',3,'15','15',45,'Elbows high · pull apart','ti-activity'),
  (3,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (3,2,'Single-Leg Balance',3,'30 s each','—',45,'Eyes forward · quiet foot','ti-activity'),
  (3,3,'Kettlebell Swing',4,'12','16',60,'Hip snap · float the bell','ti-flame'),
  (3,4,'Bear Crawl',3,'15 m','—',60,'Knees low · quiet hands','ti-activity'),
  (3,5,'Plank',3,'40 s','—',45,'Straight line · brace hard','ti-activity'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Golf Development (Golf · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Golf Development','Golf','intermediate',3,12,'Rotational speed, hip and thoracic mobility, and a stable base','ti-golf',false
  where not exists (select 1 from programs where name='Golf Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Rotational Power','Speed · Rotation',50),(2,'Strength & Stability','Legs · Core',55),(3,'Mobility & Conditioning','Mobility · Engine',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Mobility Flow',1,'8 min','—',30,'Thoracic rotation · hip openers','ti-stretching'),
  (1,2,'Rotational MB Throw',5,'5 each','4kg',90,'Drive from the hip · whip through','ti-rotate'),
  (1,3,'Cable Woodchop',4,'10 each','25',75,'Rotate from the trunk · control back','ti-activity'),
  (1,4,'Landmine Rotation',3,'8 each','25',75,'Control the arc · brace','ti-rotate'),
  (1,5,'Band Speed Swings',4,'10 each','—',60,'Fast through the ball · stay balanced','ti-bolt'),
  (1,6,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (2,1,'Warm-up',1,'8 min','—',30,'Hips · shoulders · light squats','ti-stretching'),
  (2,2,'Trap Bar Deadlift',4,'6','80',120,'Push the floor away · neutral spine','ti-barbell'),
  (2,3,'Split Squat',3,'8 each','18',90,'Long stance · vertical torso','ti-walk'),
  (2,4,'Single-Arm Row',3,'10 each','24',75,'Pull to the hip · no twist','ti-barbell'),
  (2,5,'Dumbbell Overhead Press',3,'8','18',90,'Ribs down · press tall','ti-barbell'),
  (2,6,'Suitcase Carry',3,'30 m each','24',75,'Do not lean · stay square','ti-barbell'),
  (3,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (3,2,'Thoracic Rotation Drill',3,'10 each','—',45,'Rotate from the ribs · hips still','ti-rotate'),
  (3,3,'90/90 Hip Switch',3,'10 each','—',45,'Move slowly · keep the chest tall','ti-stretching'),
  (3,4,'Bike Intervals',8,'45s on/75s off','—',30,'Steady hard efforts · nasal breathing back','ti-heart'),
  (3,5,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (3,6,'Cooldown Stretch',1,'5 min','—',0,'Hips · shoulders · breathe','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Gymnastics Development (Gymnastics · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Gymnastics Development','Gymnastics','intermediate',4,12,'Straight-arm strength, handstand work and the mobility to hold shapes','ti-stretching',false
  where not exists (select 1 from programs where name='Gymnastics Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Pull & Levers','Back · Straight arm',55),(2,'Push & Handstand','Shoulders · Balance',55),(3,'Legs & Jumps','Legs · Power',50),(4,'Flexibility & Core','Mobility · Core',50)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Joint Prep',1,'8 min','—',30,'Wrists · shoulders · hips','ti-stretching'),
  (1,2,'Pull-up',5,'6','—',120,'Full hang · lead with the chest','ti-arrow-up'),
  (1,3,'Front Lever Tuck Hold',5,'15 s','—',105,'Straight arms · hollow body','ti-activity'),
  (1,4,'Ring Row',4,'10','—',90,'Body straight · pull to the chest','ti-activity'),
  (1,5,'Skin the Cat',3,'4','—',90,'Slow through the range · stay tight','ti-rotate'),
  (1,6,'Weighted Dead Hang',3,'30 s','10',75,'Shoulders packed · breathe','ti-hand-move'),
  (2,1,'Wrist & Shoulder Prep',1,'8 min','—',30,'Wrist rocks · band dislocates','ti-stretching'),
  (2,2,'Freestanding Handstand Practice',6,'40 s','—',90,'Fingertip corrections · stay stacked','ti-arrow-up'),
  (2,3,'Handstand Push-up Negative',4,'5','—',105,'Slow lower · head to the floor','ti-arrow-down'),
  (2,4,'Ring Dip',4,'6','—',105,'Turn the rings out at lockout','ti-activity'),
  (2,5,'L-Sit Hold',4,'20 s','—',75,'Push the floor away · legs locked','ti-square'),
  (2,6,'Pseudo Planche Push-up',3,'8','—',75,'Lean forward · protract the shoulders','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'8 min','—',30,'Leg swings · hip circles · pogos','ti-stretching'),
  (3,2,'Back Squat',4,'6','60',150,'Heels down · knees out · brace','ti-barbell'),
  (3,3,'Box Jump',4,'5','—',105,'Land quiet · step back down','ti-arrow-up'),
  (3,4,'Split Squat',3,'8 each','16',90,'Long stance · vertical torso','ti-walk'),
  (3,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (3,6,'Pogo Hops',4,'20','—',60,'Stiff ankles · minimal ground time','ti-bolt'),
  (4,1,'Mobility Flow',1,'8 min','—',30,'Shoulders · hips · spine','ti-stretching'),
  (4,2,'Pancake Stretch',4,'60 s','—',30,'Long spine · breathe into it','ti-stretching'),
  (4,3,'Pike Stretch',4,'60 s','—',30,'Hinge from the hips · relax','ti-stretching'),
  (4,4,'Bridge Hold',4,'30 s','—',60,'Push the shoulders open · breathe','ti-arrow-up'),
  (4,5,'Hollow Body Rock',4,'30 s','—',60,'Low back pressed down · rock as one','ti-activity'),
  (4,6,'Arch Body Hold',4,'30 s','—',60,'Squeeze the glutes · lift the chest','ti-activity')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Handball Development (Handball · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Handball Development','Handball','intermediate',4,12,'Jump power, throwing velocity and repeat-sprint ability','ti-hand-grab',false
  where not exists (select 1 from programs where name='Handball Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Power','Legs · Jump',55),(2,'Throwing Power','Shoulders · Rotation',50),(3,'Speed & Agility','Speed · Cutting',45),(4,'Conditioning & Core','RSA · Core',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · A-skips','ti-stretching'),
  (1,2,'Back Squat',4,'5','85',150,'Brace · sit between the hips · drive','ti-barbell'),
  (1,3,'Hang Power Clean',4,'3','55',150,'Triple extension · catch tall','ti-barbell'),
  (1,4,'Single Leg Box Jump',4,'4 each','—',105,'Stick the landing · explosive drive','ti-arrow-up'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Lateral Bound',3,'5 each','—',75,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
  (2,2,'Bench Press',4,'5','70',150,'Tuck the elbows · drive the feet','ti-barbell'),
  (2,3,'Med Ball Rotational Throw',4,'5 each','5kg',90,'Drive from the hip · whip through','ti-bolt'),
  (2,4,'Weighted Pull-up',4,'6','8',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,5,'Landmine Press',3,'8 each','22',75,'Brace the core · press up and across','ti-barbell'),
  (2,6,'Band External Rotation',3,'15 each','—',45,'Elbow pinned · slow return','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups · openers','ti-stretching'),
  (3,2,'Acceleration Sprints',6,'20 m','—',105,'Hard push · low heel recovery','ti-run'),
  (3,3,'5-10-5 Pro Agility',5,'1 rep','—',90,'Low hips · plant hard · explode','ti-target-arrow'),
  (3,4,'Reactive Lateral Shuffle',4,'20 s','—',75,'Stay low · quick feet · react','ti-bolt'),
  (3,5,'Single-Leg Hop',3,'6 each','—',60,'Soft landings · stable knee','ti-bolt'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Repeated Sprint Intervals',10,'15s on/45s off','—',30,'Repeat max efforts · hold the quality','ti-heart'),
  (4,3,'Kettlebell Swing',4,'15','28',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (4,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Hockey Development (Ice Hockey · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Hockey Development','Ice Hockey','intermediate',4,12,'Skating stride power, lateral strength and shift-length conditioning','ti-skating',false
  where not exists (select 1 from programs where name='Hockey Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Power','Legs · Stride',55),(2,'Upper & Core','Upper body · Core',50),(3,'Skating Speed','Lateral · Agility',45),(4,'Shift Conditioning','Anaerobic · Engine',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · adductors · A-skips','ti-stretching'),
  (1,2,'Back Squat',4,'5','85',150,'Brace · sit between the hips · drive','ti-barbell'),
  (1,3,'Trap Bar Deadlift',4,'5','110',150,'Push the floor away · neutral spine','ti-barbell'),
  (1,4,'Lateral Lunge',3,'8 each','20',90,'Push the hips back · stay low','ti-arrows-left-right'),
  (1,5,'Copenhagen Plank',3,'20 s each','—',75,'Adductor tight · hips level','ti-activity'),
  (1,6,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band work · scap pull-ups','ti-stretching'),
  (2,2,'Bench Press',4,'6','70',120,'Tuck the elbows · drive the feet','ti-barbell'),
  (2,3,'Weighted Pull-up',4,'6','10',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,4,'Landmine Press',3,'8 each','25',75,'Brace the core · press up and across','ti-barbell'),
  (2,5,'Cable Woodchop',3,'10 each','25',60,'Rotate from the trunk · control back','ti-activity'),
  (2,6,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Side shuffles · carioca · build-ups','ti-run'),
  (3,2,'Lateral Bound',5,'5 each','—',105,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (3,3,'Skater Jump',4,'10 each','—',90,'Land soft · hold for a beat','ti-bolt'),
  (3,4,'Acceleration Sprints',6,'15 m','—',90,'Hard push · low heel recovery','ti-run'),
  (3,5,'Single-Leg Hop',3,'6 each','—',75,'Soft landings · stable knee','ti-bolt'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Bike Sprint Intervals',8,'45s on/90s off','—',30,'Shift length · empty the tank','ti-heart'),
  (4,3,'Kettlebell Swing',4,'15','32',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Sled Push',6,'20 m','60',75,'Low angle · relentless steps','ti-run'),
  (4,5,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- MMA Foundation (MMA · beginner)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'MMA Foundation','MMA','beginner',3,12,'General strength, power and conditioning base for combat sport','ti-karate',false
  where not exists (select 1 from programs where name='MMA Foundation') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Full Body Strength','Strength · Base',50),(2,'Power & Rotation','Power · Rotation',45),(3,'Conditioning & Core','Endurance · Core',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · shoulders · shadow movement','ti-stretching'),
  (1,2,'Goblet Squat',4,'10','18',90,'Heels down · knees out','ti-barbell'),
  (1,3,'Push-up',3,'10','—',60,'Straight line · full lockout','ti-activity'),
  (1,4,'Inverted Row',3,'10','—',75,'Body straight · pull to the chest','ti-activity'),
  (1,5,'Romanian Deadlift',3,'10','40',90,'Hinge back · long hamstrings','ti-barbell'),
  (1,6,'Plank',3,'40 s','—',45,'Straight line · brace hard','ti-activity'),
  (2,1,'Mobility Flow',1,'6 min','—',30,'Thoracic rotation · hip openers','ti-stretching'),
  (2,2,'Medicine Ball Slam',4,'8','4kg',75,'Full extension · slam hard','ti-bolt'),
  (2,3,'Rotational MB Throw',3,'6 each','4kg',75,'Drive from the hip · whip through','ti-rotate'),
  (2,4,'Dumbbell Push Press',3,'8','14',90,'Dip · drive · lock out overhead','ti-barbell'),
  (2,5,'Pallof Press',3,'10 each','15',60,'Resist the rotation · ribs down','ti-activity'),
  (2,6,'Hanging Knee Raise',3,'10','—',60,'No swing · curl the pelvis','ti-activity'),
  (3,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (3,2,'Bike Intervals',8,'30s on/90s off','—',30,'Hard efforts · hold the quality','ti-heart'),
  (3,3,'Kettlebell Swing',4,'15','20',60,'Hip snap · float the bell','ti-flame'),
  (3,4,'Burpee',4,'8','—',60,'Hips to the floor · pop straight up','ti-flame'),
  (3,5,'Side Plank',3,'30 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (3,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Powerlifting Foundation (Powerlifting · beginner)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Powerlifting Foundation','Powerlifting','beginner',3,12,'Learn squat, bench and deadlift technique on a linear progression','ti-barbell',false
  where not exists (select 1 from programs where name='Powerlifting Foundation') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Squat Day','Squat · Legs',55),(2,'Bench Day','Bench · Upper',50),(3,'Deadlift Day','Deadlift · Back',55)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Warm-up',1,'8 min','—',30,'Bike · hips · empty bar squats','ti-stretching'),
  (1,2,'Back Squat',5,'5','60',180,'Brace · sit between the hips · drive','ti-barbell'),
  (1,3,'Romanian Deadlift',3,'8','50',105,'Hinge back · long hamstrings','ti-barbell'),
  (1,4,'Leg Press',3,'10','80',90,'Full range · no bouncing','ti-barbell'),
  (1,5,'Plank',3,'40 s','—',45,'Straight line · brace hard','ti-activity'),
  (1,6,'Standing Calf Raise',3,'15','30',45,'Pause at the top','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band work · empty bar presses','ti-stretching'),
  (2,2,'Bench Press',5,'5','45',180,'Tuck the elbows · drive the feet','ti-barbell'),
  (2,3,'Dumbbell Overhead Press',3,'8','14',90,'Ribs down · press tall','ti-barbell'),
  (2,4,'Barbell Row',4,'8','40',90,'Flat back · pull to the navel','ti-barbell'),
  (2,5,'Face Pull',3,'15','15',45,'Elbows high · pull apart','ti-activity'),
  (2,6,'Triceps Pushdown',3,'12','20',60,'Elbows pinned · full lockout','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Hips · hamstrings · light hinges','ti-stretching'),
  (3,2,'Deadlift',4,'5','80',180,'Push the floor away · lats tight','ti-barbell'),
  (3,3,'Front Squat',3,'6','40',120,'Elbows high · stay upright','ti-barbell'),
  (3,4,'Lat Pulldown',3,'10','40',75,'Shoulders down · control the way up','ti-barbell'),
  (3,5,'Back Extension',3,'12','—',75,'Squeeze the glutes at the top','ti-activity'),
  (3,6,'Hanging Knee Raise',3,'10','—',60,'No swing · curl the pelvis','ti-activity')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Runner Development (Running · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Runner Development','Running','intermediate',4,12,'Interval work, hill power and the strength that keeps form late in a race','ti-run',false
  where not exists (select 1 from programs where name='Runner Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Strength','Legs · Gym',55),(2,'Interval Session','VO2 · Speed',50),(3,'Hills & Plyometrics','Power · Elasticity',45),(4,'Long Run','Aerobic base',80)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Warm-up',1,'8 min','—',30,'Easy jog · hips · leg swings','ti-stretching'),
  (1,2,'Back Squat',4,'6','65',120,'Heels down · knees out · brace','ti-barbell'),
  (1,3,'Romanian Deadlift',4,'8','60',105,'Hinge back · long hamstrings','ti-barbell'),
  (1,4,'Bulgarian Split Squat',3,'8 each','16',90,'Long stance · knee tracks the toes','ti-walk'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Single-Leg Calf Raise',3,'15 each','—',60,'Full range · pause at the top','ti-arrow-bar-up'),
  (2,1,'Warm-up Jog',1,'12 min','—',0,'Easy build · strides at the end','ti-run'),
  (2,2,'400 m Intervals',8,'400 m','—',120,'Hold the same split every rep','ti-run'),
  (2,3,'Strides',4,'80 m','—',90,'Relaxed and fast · not a sprint','ti-run'),
  (2,4,'Cooldown Jog',1,'10 min','—',0,'Very easy · let the breathing settle','ti-run'),
  (2,5,'Hip Flexor Stretch',1,'4 min','—',0,'Tuck the pelvis · breathe','ti-stretching'),
  (2,6,'Calf Stretch',1,'4 min','—',0,'Straight and bent knee · both sides','ti-stretching'),
  (3,1,'Warm-up Jog',1,'10 min','—',0,'Easy build · drills','ti-run'),
  (3,2,'Hill Repeats',8,'45 s','—',120,'Strong drive · jog back down','ti-mountain'),
  (3,3,'Bounding',4,'20 m','—',90,'Long strides · drive the knee','ti-bolt'),
  (3,4,'Pogo Hops',4,'20','—',60,'Stiff ankles · minimal ground time','ti-bolt'),
  (3,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (3,6,'Cooldown Jog',1,'8 min','—',0,'Very easy · settle the breathing','ti-run'),
  (4,1,'Easy Start',1,'10 min','—',0,'Start slower than feels right','ti-run'),
  (4,2,'Long Run',1,'60 min','—',0,'Conversational pace throughout','ti-run'),
  (4,3,'Finishing Strides',4,'100 m','—',60,'Relaxed and quick · good form','ti-run'),
  (4,4,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk'),
  (4,5,'Hamstring Stretch',1,'4 min','—',0,'Long spine · breathe into it','ti-stretching'),
  (4,6,'Foam Roll Quads',1,'4 min','—',0,'Slow passes · breathe out the tension','ti-activity')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Soccer Development (Soccer · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Soccer Development','Soccer','intermediate',4,12,'Sprint speed, hamstring resilience and repeat-effort conditioning','ti-ball-football',false
  where not exists (select 1 from programs where name='Soccer Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Power','Legs · Sprint',55),(2,'Upper & Core','Upper body · Core',45),(3,'Speed & Agility','Speed · Cutting',45),(4,'Conditioning','RSA · Engine',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · adductors · A-skips','ti-stretching'),
  (1,2,'Back Squat',4,'5','80',150,'Brace · sit between the hips · drive','ti-barbell'),
  (1,3,'Trap Bar Deadlift',4,'5','100',150,'Push the floor away · neutral spine','ti-barbell'),
  (1,4,'Nordic Hamstring Curl',4,'6','—',105,'Resist the fall · hips long','ti-activity'),
  (1,5,'Bulgarian Split Squat',3,'8 each','20',90,'Long stance · knee tracks the toes','ti-walk'),
  (1,6,'Copenhagen Plank',3,'20 s each','—',60,'Adductor tight · hips level','ti-activity'),
  (2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band work · scap pull-ups','ti-stretching'),
  (2,2,'Bench Press',4,'6','60',120,'Tuck the elbows · drive the feet','ti-barbell'),
  (2,3,'Weighted Pull-up',4,'6','8',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,4,'Dumbbell Overhead Press',3,'8','18',90,'Ribs down · press tall','ti-barbell'),
  (2,5,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (2,6,'Hanging Leg Raise',3,'12','—',60,'No swing · curl the pelvis','ti-activity'),
  (3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups · openers','ti-stretching'),
  (3,2,'Acceleration Sprints',6,'20 m','—',120,'Hard push · low heel recovery','ti-run'),
  (3,3,'Flying Sprints',4,'30 m','—',150,'Build in · relax at top speed','ti-run'),
  (3,4,'5-10-5 Pro Agility',5,'1 rep','—',90,'Low hips · plant hard · explode','ti-target-arrow'),
  (3,5,'Lateral Bound',3,'5 each','—',75,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Repeated Sprint Intervals',12,'20s on/40s off','—',30,'Repeat max efforts · hold the quality','ti-heart'),
  (4,3,'Shuttle Runs',6,'120 m','—',90,'Turn tight · accelerate out','ti-run'),
  (4,4,'Kettlebell Swing',4,'15','28',60,'Hip snap · float the bell','ti-flame'),
  (4,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Strongman Foundation (Strongman · beginner)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Strongman Foundation','Strongman','beginner',3,12,'Barbell base plus light carries before touching the real events','ti-barbell',false
  where not exists (select 1 from programs where name='Strongman Foundation') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Strength','Squat · Hinge',55),(2,'Press & Upper','Shoulders · Back',50),(3,'Carries & Conditioning','Carries · Engine',50)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Warm-up',1,'8 min','—',30,'Bike · hips · light squats','ti-stretching'),
  (1,2,'Back Squat',4,'6','70',150,'Brace hard · sit between the hips','ti-barbell'),
  (1,3,'Trap Bar Deadlift',4,'6','90',150,'Push the floor away · neutral spine','ti-barbell'),
  (1,4,'Reverse Lunge',3,'8 each','16',90,'Drop straight down · tall chest','ti-walk'),
  (1,5,'Back Extension',3,'12','—',75,'Squeeze the glutes at the top','ti-activity'),
  (1,6,'Standing Calf Raise',3,'15','40',45,'Pause at the top','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band work · empty bar presses','ti-stretching'),
  (2,2,'Overhead Press',4,'6','35',120,'Ribs down · press tall · lock out','ti-barbell'),
  (2,3,'Dumbbell Bench Press',3,'10','22',90,'Control down · press together','ti-barbell'),
  (2,4,'Barbell Row',4,'8','50',90,'Flat back · pull to the navel','ti-barbell'),
  (2,5,'Dead Hang',3,'30 s','—',60,'Crush the bar · shoulders packed','ti-hand-move'),
  (2,6,'Face Pull',3,'15','15',45,'Elbows high · pull apart','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Full body · rehearse the carries','ti-activity'),
  (3,2,'Farmer Carry',5,'20 m','30',120,'Tall posture · crush the handles','ti-barbell'),
  (3,3,'Sandbag Carry',4,'20 m','30',105,'Hug it high · brace and breathe','ti-activity'),
  (3,4,'Sled Push',6,'15 m','40',90,'Low angle · relentless steps','ti-run'),
  (3,5,'Kettlebell Swing',4,'15','24',60,'Hip snap · float the bell','ti-flame'),
  (3,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Swimmer Development (Swimming · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Swimmer Development','Swimming','intermediate',4,12,'Dryland pulling power, shoulder health and a strong streamline','ti-pool',false
  where not exists (select 1 from programs where name='Swimmer Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Pull Strength','Back · Lats',50),(2,'Start & Push-off Power','Legs · Explosiveness',50),(3,'Core & Streamline','Core · Position',45),(4,'Shoulder Health & Engine','Shoulders · Aerobic',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Shoulder Warm-up',1,'8 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
  (1,2,'Weighted Pull-up',4,'6','10',120,'Full hang · lead with the chest','ti-arrow-up'),
  (1,3,'Straight-Arm Pulldown',4,'12','30',75,'Lats do the work · arms stay long','ti-barbell'),
  (1,4,'Barbell Row',4,'8','55',90,'Flat back · pull to the navel','ti-barbell'),
  (1,5,'Cable Swim Pull',3,'12 each','15',60,'Mimic the catch · high elbow','ti-activity'),
  (1,6,'Face Pull',3,'15','18',60,'Elbows high · pull apart','ti-activity'),
  (2,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · pogo hops','ti-stretching'),
  (2,2,'Back Squat',4,'5','75',150,'Brace · sit between the hips · drive','ti-barbell'),
  (2,3,'Box Jump',5,'4','—',120,'Land quiet · step back down','ti-arrow-up'),
  (2,4,'Broad Jump',4,'4','—',105,'Reach out · stick the landing','ti-bolt'),
  (2,5,'Romanian Deadlift',3,'8','60',90,'Hinge back · long hamstrings','ti-barbell'),
  (2,6,'Standing Calf Raise',3,'15','40',45,'Full range · pause at the top','ti-arrow-bar-up'),
  (3,1,'Mobility Flow',1,'6 min','—',30,'Shoulders · thoracic spine','ti-stretching'),
  (3,2,'Hollow Body Hold',4,'30 s','—',60,'Low back pressed down · arms long','ti-activity'),
  (3,3,'Streamline Wall Hold',4,'40 s','—',60,'Arms squeezed behind the ears','ti-arrow-up'),
  (3,4,'Flutter Kick',4,'30 s','—',45,'Small fast kicks · legs long','ti-activity'),
  (3,5,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (3,6,'Side Plank',3,'40 s each','—',45,'Hips high · shoulder stacked','ti-activity'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Band External Rotation',4,'15 each','—',45,'Elbow pinned · slow return','ti-activity'),
  (4,3,'Scapular Push-up',3,'12','—',45,'Protract and retract · arms straight','ti-activity'),
  (4,4,'Rowing Intervals',8,'250 m','—',75,'Steady split · drive with the legs','ti-heart'),
  (4,5,'Prone Y-T-W',3,'8 each','2',60,'Thumbs up · lift from the mid-back','ti-activity'),
  (4,6,'Lat Stretch',1,'5 min','—',0,'Long side body · breathe','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Tennis Development (Tennis · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Tennis Development','Tennis','intermediate',4,12,'Serve power, split-step speed and the shoulder work to survive a season','ti-trophy',false
  where not exists (select 1 from programs where name='Tennis Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Lower Power','Legs · Plyometrics',55),(2,'Serve Power','Shoulders · Rotation',50),(3,'Court Speed','Footwork · Reaction',45),(4,'Rotation & Endurance','Core · Engine',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · split steps','ti-stretching'),
  (1,2,'Back Squat',4,'5','75',150,'Brace · sit between the hips · drive','ti-barbell'),
  (1,3,'Lateral Lunge',4,'8 each','20',90,'Push the hips back · stay low','ti-arrows-left-right'),
  (1,4,'Lateral Bound',4,'5 each','—',90,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (1,6,'Calf Raise',3,'15','50',45,'Pause at the top','ti-arrow-bar-up'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
  (2,2,'Push Press',4,'5','50',120,'Dip · drive · lock out overhead','ti-barbell'),
  (2,3,'Medicine Ball Overhead Throw',4,'6','4kg',90,'Full extension · throw through it','ti-bolt'),
  (2,4,'Weighted Pull-up',3,'6','8',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,5,'Landmine Press',3,'8 each','22',75,'Brace the core · press up and across','ti-barbell'),
  (2,6,'Band External Rotation',3,'15 each','—',45,'Elbow pinned · slow return','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Side shuffles · carioca · split steps','ti-run'),
  (3,2,'Spider Drill',5,'1 rep','—',105,'Low hips · recover to centre','ti-target-arrow'),
  (3,3,'Cone Reaction Drill',5,'20 s','—',75,'Split step · react · explode','ti-target-arrow'),
  (3,4,'Acceleration Sprints',6,'10 m','—',75,'First two steps decide the point','ti-run'),
  (3,5,'Depth Jump',3,'4','—',120,'Drop · minimal contact · explode up','ti-arrow-up'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Rotational MB Throw',4,'5 each','5kg',90,'Drive from the hip · whip through','ti-rotate'),
  (4,3,'Cable Woodchop',3,'12 each','25',60,'Rotate from the trunk · control back','ti-activity'),
  (4,4,'Bike Intervals',10,'30s on/60s off','—',30,'Match a rally · repeat the quality','ti-heart'),
  (4,5,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (4,6,'Cooldown Stretch',1,'5 min','—',0,'Shoulders · hips · breathe','ti-stretching')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;

-- Volleyball Development (Volleyball · intermediate)
with np as (
  insert into programs (name,sport,level,days_per_week,duration_weeks,description,icon,is_custom)
  select 'Volleyball Development','Volleyball','intermediate',4,12,'Approach jump height, shoulder durability and landing mechanics','ti-ball-volleyball',false
  where not exists (select 1 from programs where name='Volleyball Development') returning id
), w as (
  insert into program_workouts (program_id,day_number,title,focus,estimated_min)
  select np.id,v.d,v.t,v.f,v.m from np,(values (1,'Vertical Power','Legs · Jump',55),(2,'Shoulder & Attack','Shoulders · Hitting',50),(3,'Agility & Landing','Movement · Landing',45),(4,'Conditioning & Core','Engine · Core',45)) as v(d,t,f,m) returning id,day_number
), x(d,o,n,s,r,tw,rest,c,i) as (values
  (1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · pogo hops','ti-stretching'),
  (1,2,'Back Squat',4,'5','80',150,'Brace · sit between the hips · drive','ti-barbell'),
  (1,3,'Hang Power Clean',4,'3','55',150,'Triple extension · catch tall','ti-barbell'),
  (1,4,'Approach Jump',5,'3','—',120,'Full run-up · reach high · land soft','ti-arrow-up'),
  (1,5,'Depth Jump',4,'4','—',120,'Drop · minimal contact · explode up','ti-arrow-up'),
  (1,6,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
  (2,1,'Shoulder Warm-up',1,'8 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
  (2,2,'Dumbbell Overhead Press',4,'8','20',105,'Ribs down · press tall','ti-barbell'),
  (2,3,'Medicine Ball Overhead Throw',4,'6','4kg',90,'Full extension · throw through it','ti-bolt'),
  (2,4,'Weighted Pull-up',4,'6','8',105,'Full hang · lead with the chest','ti-arrow-up'),
  (2,5,'Prone Y-T-W',3,'8 each','2',60,'Thumbs up · lift from the mid-back','ti-activity'),
  (2,6,'Band External Rotation',3,'15 each','—',45,'Elbow pinned · slow return','ti-activity'),
  (3,1,'Warm-up',1,'8 min','—',30,'Side shuffles · carioca · build-ups','ti-run'),
  (3,2,'Lateral Bound',4,'5 each','—',90,'Push off the outside leg · stick it','ti-arrows-left-right'),
  (3,3,'Single-Leg Landing Drill',4,'6 each','—',75,'Absorb quietly · knee over the foot','ti-activity'),
  (3,4,'Cone Reaction Drill',4,'20 s','—',75,'Split step · react · explode','ti-target-arrow'),
  (3,5,'Block Jump Series',4,'5','—',90,'Fast off the floor · hands high','ti-arrow-up'),
  (3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe','ti-stretching'),
  (4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
  (4,2,'Repeated Sprint Intervals',10,'15s on/45s off','—',30,'Repeat max efforts · hold the quality','ti-heart'),
  (4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · float the bell','ti-flame'),
  (4,4,'Pallof Press',3,'10 each','20',60,'Resist the rotation · ribs down','ti-activity'),
  (4,5,'Hanging Leg Raise',3,'12','—',60,'No swing · curl the pelvis','ti-activity'),
  (4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk')
)
insert into program_exercises (workout_id,order_idx,exercise_name,sets,reps,target_weight,rest_seconds,cues,icon)
select w.id,x.o,x.n,x.s,x.r,x.tw,x.rest,x.c,x.i from x join w on w.day_number=x.d;
