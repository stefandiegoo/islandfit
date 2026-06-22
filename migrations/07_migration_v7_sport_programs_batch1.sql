-- ÍslandFit v7 — Sport-specific programs, batch 1 (advanced tier)
-- Evidence-INFORMED designs matched to each sport's documented demands (energy systems,
-- biomotor priorities, the four pillars). These are ORIGINAL programs built on public
-- S&C principles — not transcribed studies and not copies of any commercial program.
-- Added at level 'advanced' so they do not collide with the v5 beginner/intermediate programs.
-- Run in Supabase SQL Editor AFTER migration_v5_iceland_sports.sql. Safe to re-run (guarded per program).

-- ════════════════════════════════════════════════════════════
-- HANDBALL — demands: explosive throwing & jumping (alactic power),
-- repeated sprints/jumps, rotational core, lateral agility, shoulder durability
-- ════════════════════════════════════════════════════════════
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Handball Elite' and sport='Handball') then raise notice 'Handball Elite exists — skip'; return; end if;
  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p, 'Handball Elite', 'Handball', 'advanced', 4, 12, 'Explosive power · throwing velocity · lateral agility · repeated-sprint engine', 'ti-hand-grab');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p, 1, 'Lower Body Power', 'Strength · Explosiveness', 60),
    (w2, p, 2, 'Throwing Power',   'Strength · Rotation',      55),
    (w3, p, 3, 'Speed & Agility',  'Speed',                    45),
    (w4, p, 4, 'Conditioning & Core','Endurance · RSA',        45);
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · A-skips','ti-stretching'),
    (w1,2,'Back Squat',5,'4','90',180,'Brace · sit between hips · drive','ti-barbell'),
    (w1,3,'Hang Power Clean',5,'3','60',150,'Triple extension · catch tall','ti-barbell'),
    (w1,4,'Depth Jump',4,'4','—',120,'Drop · minimal contact · explode up','ti-arrow-up'),
    (w1,5,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · hips long','ti-activity'),
    (w1,6,'Lateral Bound',3,'5 each','—',75,'Push off outside leg · stick landing','ti-bolt');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band pull-aparts · cuff activation','ti-stretching'),
    (w2,2,'Bench Press',4,'5','75',150,'Tuck elbows · drive the feet','ti-barbell'),
    (w2,3,'Med Ball Rotational Throw',4,'4 each','—',90,'Drive from the hip · whip through','ti-bolt'),
    (w2,4,'Weighted Pull-up',4,'5','10',120,'Full hang · lead with the chest','ti-arrow-up'),
    (w2,5,'Landmine Press',3,'8 each','25',75,'Brace core · press up and across','ti-barbell'),
    (w2,6,'Cable Woodchop',3,'10 each','20',60,'Rotate from the trunk · control return','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups · openers','ti-stretching'),
    (w3,2,'Acceleration Sprints',6,'20 m','—',120,'Hard push · low heel recovery','ti-run'),
    (w3,3,'5-10-5 Pro Agility',5,'1 rep','—',90,'Low hips · plant hard · explode','ti-target-arrow'),
    (w3,4,'Reactive Lateral Shuffle',4,'20 s','—',75,'Stay low · quick feet · react','ti-bolt'),
    (w3,5,'Single-Leg Hop',3,'6 each','—',60,'Soft landings · stable knee','ti-bolt'),
    (w3,6,'Hip Mobility Flow',1,'5 min','—',0,'Open the hips · breathe · cool down','ti-stretching');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build to a sweat','ti-activity'),
    (w4,2,'Repeated Sprint Intervals',10,'15s on/45s off','—',30,'Repeat max efforts · hold quality','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','28',60,'Hip snap · brace · float the bell','ti-flame'),
    (w4,4,'Pallof Press',3,'10 each','20',45,'Resist rotation · ribs down','ti-activity'),
    (w4,5,'Plank',3,'45 s','—',45,'Straight line · brace hard','ti-activity'),
    (w4,6,'Cooldown Walk',1,'5 min','—',0,'Settle the heart · breathe','ti-walk');
  raise notice 'Added Handball Elite';
end $$;

-- ════════════════════════════════════════════════════════════
-- BASKETBALL — demands: vertical power, acceleration & deceleration,
-- repeated sprints, landing mechanics, ankle/knee robustness
-- ════════════════════════════════════════════════════════════
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Basketball Elite' and sport='Basketball') then raise notice 'Basketball Elite exists — skip'; return; end if;
  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p, 'Basketball Elite', 'Basketball', 'advanced', 4, 12, 'Vertical power · acceleration & deceleration · reactive jumps · court conditioning', 'ti-ball-basketball');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p, 1, 'Lower Power & Jump', 'Strength · Explosiveness', 60),
    (w2, p, 2, 'Upper & Core',       'Strength · Power',         50),
    (w3, p, 3, 'Speed & Decel',      'Speed · Agility',          45),
    (w4, p, 4, 'Conditioning & Core','Endurance · RSA',          45);
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · ankles · skips','ti-stretching'),
    (w1,2,'Trap Bar Deadlift',5,'4','100',180,'Flat back · push the floor away','ti-barbell'),
    (w1,3,'Squat Jump',5,'3','—',120,'Explode up · land soft','ti-arrow-up'),
    (w1,4,'Depth Jump',4,'4','—',120,'Quick contact · max height','ti-arrow-up'),
    (w1,5,'Bulgarian Split Squat',3,'6 each','24',90,'Tall torso · controlled depth','ti-walk'),
    (w1,6,'Pogo Hops',3,'20','—',45,'Stiff ankles · fast contacts','ti-bolt');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2,1,'Shoulder Warm-up',1,'6 min','—',30,'Band work · cuff','ti-stretching'),
    (w2,2,'Bench Press',4,'5','70',150,'Tuck elbows · drive feet','ti-barbell'),
    (w2,3,'Push Press',4,'3','50',120,'Dip-drive · punch overhead','ti-arrow-up'),
    (w2,4,'Weighted Pull-up',4,'6','8',120,'Full hang · lead with the chest','ti-arrow-up'),
    (w2,5,'Dumbbell Row',3,'10 each','30',60,'Flat back · pull to the hip','ti-barbell'),
    (w2,6,'Hanging Leg Raise',3,'12','—',45,'Control the swing · brace','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups','ti-stretching'),
    (w3,2,'Acceleration Sprints',6,'15 m','—',120,'Aggressive push · stay low','ti-run'),
    (w3,3,'Deceleration Drill',4,'15 m','—',90,'Sink the hips · absorb · control','ti-target-arrow'),
    (w3,4,'Lateral Bound',4,'5 each','—',75,'Push outside leg · stick','ti-bolt'),
    (w3,5,'Reactive COD Drill',4,'20 s','—',75,'React · plant · change','ti-bolt'),
    (w3,6,'Ankle Mobility',1,'5 min','—',0,'Dorsiflexion · calves','ti-stretching');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4,1,'Warm-up',1,'5 min','—',30,'Easy build','ti-activity'),
    (w4,2,'Shuttle Intervals',8,'30s on/30s off','—',30,'Court-pace efforts','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Copenhagen Plank',3,'20 s each','—',45,'Adductor strength · hold the line','ti-activity'),
    (w4,5,'Pallof Press',3,'10 each','20',45,'Anti-rotation · ribs down','ti-activity'),
    (w4,6,'Cooldown Walk',1,'5 min','—',0,'Settle · breathe','ti-walk');
  raise notice 'Added Basketball Elite';
end $$;

-- ════════════════════════════════════════════════════════════
-- SOCCER — demands: repeated-sprint ability, aerobic base, change of direction,
-- eccentric hamstring strength (Nordic — strong injury-prevention evidence), adductor robustness
-- ════════════════════════════════════════════════════════════
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Soccer Elite' and sport='Soccer') then raise notice 'Soccer Elite exists — skip'; return; end if;
  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p, 'Soccer Elite', 'Soccer', 'advanced', 4, 12, 'Repeated-sprint engine · change of direction · eccentric hamstring & adductor durability', 'ti-ball-football');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p, 1, 'Lower Strength & Hamstring', 'Strength · Durability', 55),
    (w2, p, 2, 'Power & Upper',              'Strength · Explosiveness',50),
    (w3, p, 3, 'Speed & RSA',                'Speed',                  45),
    (w4, p, 4, 'Aerobic & Conditioning',     'Endurance',              45);
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1,1,'Dynamic Warm-up',1,'8 min','—',30,'Hips · groin · skips','ti-stretching'),
    (w1,2,'Back Squat',4,'5','85',150,'Brace · drive · full depth','ti-barbell'),
    (w1,3,'Romanian Deadlift',4,'6','80',120,'Hinge · long hamstrings · flat back','ti-barbell'),
    (w1,4,'Nordic Hamstring Curl',3,'6','—',90,'Resist the fall · evidence-based prevention','ti-activity'),
    (w1,5,'Walking Lunge',3,'8 each','20',75,'Long stride · tall torso','ti-walk'),
    (w1,6,'Copenhagen Plank',3,'20 s each','—',60,'Adductor robustness · straight line','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Band work · openers','ti-stretching'),
    (w2,2,'Hang Power Clean',5,'3','55',150,'Triple extension · catch tall','ti-barbell'),
    (w2,3,'Bench Press',4,'6','65',120,'Tuck elbows · drive','ti-barbell'),
    (w2,4,'Pull-up',4,'8','—',90,'Full hang · chest to bar','ti-arrow-up'),
    (w2,5,'Med Ball Slam',4,'6','—',60,'Overhead · slam hard · reset','ti-bolt'),
    (w2,6,'Pallof Press',3,'10 each','20',45,'Anti-rotation · brace','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3,1,'Dynamic Warm-up',1,'8 min','—',30,'Skips · build-ups','ti-stretching'),
    (w3,2,'Acceleration Sprints',6,'20 m','—',120,'Hard push · drive the arms','ti-run'),
    (w3,3,'Repeated Sprint Sets',6,'30 m','—',60,'Hold sprint quality · short rest','ti-run'),
    (w3,4,'COD Agility Drill',5,'1 rep','—',90,'Plant hard · explode out','ti-target-arrow'),
    (w3,5,'Lateral Bound',3,'5 each','—',60,'Push outside · stick','ti-bolt'),
    (w3,6,'Mobility Flow',1,'5 min','—',0,'Hips · groin · cool down','ti-stretching');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4,1,'Warm-up Jog',1,'8 min','—',30,'Easy aerobic build','ti-run'),
    (w4,2,'Tempo Intervals',5,'3min on/90s off','—',30,'Threshold pace · controlled','ti-heart'),
    (w4,3,'Kettlebell Swing',4,'15','24',60,'Hip snap · brace','ti-flame'),
    (w4,4,'Plank Circuit',3,'45 s','—',45,'Front and sides · brace','ti-activity'),
    (w4,5,'Calf Raise',3,'15','40',45,'Pause at the top · control down','ti-activity'),
    (w4,6,'Cooldown Walk',1,'5 min','—',0,'Settle · breathe','ti-walk');
  raise notice 'Added Soccer Elite';
end $$;

-- ════════════════════════════════════════════════════════════
-- POWERLIFTING — demands: maximal force on squat/bench/deadlift,
-- high intensity with submaximal volume, minimal conditioning (GPP only)
-- ════════════════════════════════════════════════════════════
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Powerlifting Peak' and sport='Powerlifting') then raise notice 'Powerlifting Peak exists — skip'; return; end if;
  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p, 'Powerlifting Peak', 'Powerlifting', 'advanced', 4, 12, 'Maximal strength on the squat / bench / deadlift with submaximal volume and light GPP', 'ti-barbell');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p, 1, 'Squat Focus',        'Max Strength',         70),
    (w2, p, 2, 'Bench Focus',        'Max Strength',         65),
    (w3, p, 3, 'Deadlift Focus',     'Max Strength',         70),
    (w4, p, 4, 'Hypertrophy & GPP',  'Volume · Engine',      55);
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Hips · ankles · ramp sets','ti-stretching'),
    (w1,2,'Back Squat',5,'3','140',210,'Max intent · brace hard · full depth','ti-barbell'),
    (w1,3,'Pause Squat',3,'3','115',180,'Three count pause · stay tight','ti-barbell'),
    (w1,4,'Romanian Deadlift',3,'6','100',120,'Hinge · hamstring tension','ti-barbell'),
    (w1,5,'Leg Press',3,'10','—',90,'Controlled · full range','ti-activity'),
    (w1,6,'Weighted Plank',3,'45 s','—',60,'Brace · neutral spine','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Cuff · band · ramp','ti-stretching'),
    (w2,2,'Bench Press',5,'3','105',210,'Max intent · leg drive · stay tight','ti-barbell'),
    (w2,3,'Close-Grip Bench',3,'5','85',150,'Tuck elbows · triceps drive','ti-barbell'),
    (w2,4,'Overhead Press',3,'6','55',120,'Brace · press tall','ti-barbell'),
    (w2,5,'Barbell Row',4,'8','80',90,'Flat back · pull to sternum','ti-barbell'),
    (w2,6,'Triceps Extension',3,'12','—',60,'Control · full lockout','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3,1,'Warm-up',1,'8 min','—',30,'Hips · hamstrings · ramp','ti-stretching'),
    (w3,2,'Deadlift',5,'2','170',240,'Max intent · push and pull · brace','ti-barbell'),
    (w3,3,'Deficit Deadlift',3,'3','140',180,'Extra range · stay tight','ti-barbell'),
    (w3,4,'Front Squat',3,'5','90',150,'Tall chest · elbows up','ti-barbell'),
    (w3,5,'Back Extension',3,'12','—',75,'Hinge · squeeze the glutes','ti-activity'),
    (w3,6,'Hanging Leg Raise',3,'12','—',60,'Control · brace','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4,1,'Warm-up',1,'6 min','—',30,'Mobility · ramp','ti-stretching'),
    (w4,2,'Tempo Squat',4,'8','100',120,'Three sec down · controlled','ti-barbell'),
    (w4,3,'Incline Bench',4,'8','60',90,'Controlled · full range','ti-barbell'),
    (w4,4,'Dumbbell Row',3,'12 each','32',60,'Pull to the hip · squeeze','ti-barbell'),
    (w4,5,'Sled Push',3,'40 m','—',75,'Hard effort · build the engine','ti-flame'),
    (w4,6,'Biceps & Triceps',3,'12','—',45,'Control both directions','ti-activity');
  raise notice 'Added Powerlifting Peak';
end $$;

-- ════════════════════════════════════════════════════════════
-- DISTANCE RUNNING — demands: aerobic base, lactate threshold, VO2, running economy
-- (heavy strength + plyometrics improve economy — well supported), durability.
-- Concurrent model: strength supports the running, which stays the priority.
-- ════════════════════════════════════════════════════════════
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='Distance Runner Elite' and sport='Running') then raise notice 'Distance Runner Elite exists — skip'; return; end if;
  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p, 'Distance Runner Elite', 'Running', 'advanced', 4, 12, 'Aerobic base · threshold & VO2 work · strength for running economy · durability', 'ti-run');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p, 1, 'Strength for Economy', 'Strength · Power', 45),
    (w2, p, 2, 'Easy Aerobic Run',     'Endurance · Base', 50),
    (w3, p, 3, 'Threshold & VO2',      'Endurance · Engine',55),
    (w4, p, 4, 'Long Run',             'Endurance · Base', 80);
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Mobility · skips · build-ups','ti-stretching'),
    (w1,2,'Back Squat',4,'5','80',150,'Heavy strength improves running economy','ti-barbell'),
    (w1,3,'Romanian Deadlift',3,'6','70',120,'Hinge · posterior chain','ti-barbell'),
    (w1,4,'Single-Leg Calf Raise',4,'12 each','—',60,'Full range · tendon stiffness','ti-activity'),
    (w1,5,'Pogo Hops',3,'20','—',45,'Stiff ankles · elastic return','ti-bolt'),
    (w1,6,'Core Circuit',3,'45 s','—',45,'Plank · side plank · dead bug','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2,1,'Easy Run',1,'40 min','—',0,'Zone 2 · conversational pace · nasal breathing','ti-run'),
    (w2,2,'Mobility Cooldown',1,'8 min','—',0,'Hips · calves · breathe','ti-stretching');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3,1,'Warm-up Jog',1,'12 min','—',30,'Easy build · strides','ti-run'),
    (w3,2,'Threshold Intervals',5,'5min on/90s off','—',30,'Comfortably hard · controlled','ti-heart'),
    (w3,3,'VO2 Intervals',5,'3min on/2min off','—',30,'Hard · 95 percent effort','ti-heart'),
    (w3,4,'Cooldown Jog',1,'10 min','—',0,'Easy · flush the legs','ti-run');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4,1,'Long Run',1,'70 min','—',0,'Steady aerobic · build endurance','ti-run'),
    (w4,2,'Hip & Calf Mobility',1,'10 min','—',0,'Open hips · calves · cool down','ti-stretching');
  raise notice 'Added Distance Runner Elite';
end $$;

-- ════════════════════════════════════════════════════════════
-- MMA — demands: alactic power (strikes/takedowns), anaerobic capacity (scrambles),
-- aerobic base (round recovery), grip & neck robustness, max strength base
-- ════════════════════════════════════════════════════════════
do $$
declare p uuid:=gen_random_uuid(); w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  if exists (select 1 from programs where name='MMA Performance' and sport='MMA') then raise notice 'MMA Performance exists — skip'; return; end if;
  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p, 'MMA Performance', 'MMA', 'advanced', 4, 12, 'Max strength · explosive power · round-based anaerobic conditioning · aerobic base · grip', 'ti-karate');
  w1:=gen_random_uuid(); w2:=gen_random_uuid(); w3:=gen_random_uuid(); w4:=gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p, 1, 'Max Strength',          'Strength',            60),
    (w2, p, 2, 'Explosive Power',       'Explosiveness',       50),
    (w3, p, 3, 'Round Conditioning',    'Anaerobic · Engine',  45),
    (w4, p, 4, 'Aerobic Base & Recovery','Endurance · Recovery',40);
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1,1,'Warm-up',1,'8 min','—',30,'Mobility · ramp · activation','ti-stretching'),
    (w1,2,'Back Squat',5,'4','100',180,'Brace · drive · full depth','ti-barbell'),
    (w1,3,'Bench Press',4,'5','80',150,'Tuck elbows · drive the feet','ti-barbell'),
    (w1,4,'Weighted Pull-up',4,'5','12',120,'Full hang · chest to bar','ti-arrow-up'),
    (w1,5,'Trap Bar Deadlift',3,'5','120',150,'Flat back · push the floor','ti-barbell'),
    (w1,6,'Farmer Carry',3,'40 m','30',75,'Tall posture · crush grip','ti-flame');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2,1,'Warm-up',1,'6 min','—',30,'Skips · openers','ti-stretching'),
    (w2,2,'Hang Power Clean',5,'3','60',150,'Triple extension · catch tall','ti-barbell'),
    (w2,3,'Push Press',4,'3','55',120,'Dip-drive · punch overhead','ti-arrow-up'),
    (w2,4,'Med Ball Slam',5,'5','—',75,'Overhead · slam hard','ti-bolt'),
    (w2,5,'Box Jump',4,'4','—',90,'Explode · land soft','ti-arrow-up'),
    (w2,6,'Rotational Med Ball Throw',3,'5 each','—',60,'Hip drive · whip through','ti-bolt');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3,1,'Warm-up',1,'6 min','—',30,'Build to a sweat','ti-activity'),
    (w3,2,'Round Circuit',5,'3min on/1min off','—',60,'Mimic round demands · sustain output','ti-heart'),
    (w3,3,'Kettlebell Swing',5,'20','28',45,'Hip snap · brace · breathe','ti-flame'),
    (w3,4,'Battle Rope',4,'30 s','—',45,'Continuous output · stay loose','ti-flame'),
    (w3,5,'Neck Iso Hold',3,'30 s','—',45,'Brace the neck · all directions','ti-activity'),
    (w3,6,'Grip Hold',3,'30 s','—',45,'Crush hold · build grip endurance','ti-activity');
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4,1,'Zone 2 Conditioning',1,'30 min','—',0,'Easy bike or row or run · build aerobic base','ti-heart'),
    (w4,2,'Core Stability',3,'45 s','—',45,'Anti-rotation · brace','ti-activity'),
    (w4,3,'Mobility Flow',1,'10 min','—',0,'Hips · shoulders · breathe','ti-stretching');
  raise notice 'Added MMA Performance';
end $$;
