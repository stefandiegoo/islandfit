-- ÍslandFit — Þjálfunaráætlanir & Æfingar
-- Keyrðu þetta í SQL Editor á supabase.com (eftir fyrri setup.sql)

-- ═══════════════════════════════════════════════════════════
-- 1. NÝJAR TÖFLUR
-- ═══════════════════════════════════════════════════════════

-- Þjálfunaráætlanir (Programs)
create table if not exists programs (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  sport text not null,
  level text not null check (level in ('beginner','intermediate','advanced')),
  days_per_week int default 4,
  duration_weeks int default 12,
  description text,
  icon text default 'ti-barbell',
  created_at timestamp with time zone default now()
);

-- Þjálfanir innan áætlunar (hver dagur)
create table if not exists program_workouts (
  id uuid default gen_random_uuid() primary key,
  program_id uuid references programs(id) on delete cascade,
  day_number int not null,         -- 1, 2, 3, 4 (training day 1-4 each week)
  title text not null,             -- "Styrkur + Sprengikraftur"
  focus text,                      -- "Neðri líkami", "Hraði", etc.
  estimated_min int default 55,
  created_at timestamp with time zone default now(),
  unique(program_id, day_number)
);

-- Æfingar í hverri þjálfun
create table if not exists program_exercises (
  id uuid default gen_random_uuid() primary key,
  workout_id uuid references program_workouts(id) on delete cascade,
  order_idx int not null,
  exercise_name text not null,
  sets int default 3,
  reps text default '8',
  target_weight text default '—',
  rest_seconds int default 90,
  cues text,
  icon text default 'ti-barbell',
  video_url text,
  created_at timestamp with time zone default now()
);

-- ═══════════════════════════════════════════════════════════
-- 2. UPPFÆRA PROFILES (bæta við dálkum)
-- ═══════════════════════════════════════════════════════════

alter table profiles add column if not exists program_id uuid references programs(id);
alter table profiles add column if not exists current_week int default 1;
alter table profiles add column if not exists current_day int default 1;
alter table profiles add column if not exists experience_level text default 'beginner';

-- ═══════════════════════════════════════════════════════════
-- 3. ROW LEVEL SECURITY (allir mega lesa þjálfunaráætlanir)
-- ═══════════════════════════════════════════════════════════

alter table programs enable row level security;
alter table program_workouts enable row level security;
alter table program_exercises enable row level security;

drop policy if exists "Anyone reads programs" on programs;
drop policy if exists "Anyone reads workouts" on program_workouts;
drop policy if exists "Anyone reads exercises" on program_exercises;

create policy "Anyone reads programs" on programs for select using (true);
create policy "Anyone reads workouts" on program_workouts for select using (true);
create policy "Anyone reads exercises" on program_exercises for select using (true);

-- ═══════════════════════════════════════════════════════════
-- 4. SÁNINGARGÖGN — 4 ÞJÁLFUNARÁÆTLANIR
-- ═══════════════════════════════════════════════════════════

do $$
declare
  -- Áætlanir
  p_basketball uuid := gen_random_uuid();
  p_soccer uuid := gen_random_uuid();
  p_strength uuid := gen_random_uuid();
  p_crossfit uuid := gen_random_uuid();
  -- Workouts (æfinga-dagar)
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

-- Hreinsa fyrri sáningargögn ef til
delete from program_exercises;
delete from program_workouts;
delete from programs;

-- ────────────────────────────────────────────────────────
-- ÁÆTLUN 1: KÖRFUBOLTI BYRJANDI
-- ────────────────────────────────────────────────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_basketball, 'Körfubolti Grunnur', 'Körfubolti', 'beginner', 4, 12,
   'Styrkur, sprengikraftur og hraði fyrir körfuboltamenn', 'ti-ball-basketball');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_bb_1, p_basketball, 1, 'Neðri líkami styrkur', 'Fætur · Sprengikraftur', 55),
  (w_bb_2, p_basketball, 2, 'Efri líkami styrkur', 'Brjóst · Bak · Axlir', 50),
  (w_bb_3, p_basketball, 3, 'Hraði & Plyometrics', 'Lóðrétt stökk · Hraði', 45),
  (w_bb_4, p_basketball, 4, 'Heild & Kjarni', 'Almenn · Mobility', 60);

-- Dagur 1: Neðri líkami
insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_1, 1, 'Upphitun & Mobility', 1, '8 mín', '—', 30, 'Léttar hreyfingar · undirbúa mjaðmir og hné', 'ti-stretching'),
  (w_bb_1, 2, 'Olympic Squat', 4, '5', '80', 120, 'Fætur á öxlarvídd · hnén yfir tánum · brjóstið uppi', 'ti-barbell'),
  (w_bb_1, 3, 'Bulgarian Split Squat', 3, '8', '20', 90, 'Aftur fót á bekk · niður beint · spenntur kjarni', 'ti-walk'),
  (w_bb_1, 4, 'Box Jump', 4, '5', '60cm', 90, 'Sveifla höndum · sprengja frá mjöðmum · mjúk lending', 'ti-arrow-up'),
  (w_bb_1, 5, 'Romanian Deadlift', 3, '8', '60', 90, 'Bakið beint · stangir nálægt fótum · pressa með rasskinnum', 'ti-stretching'),
  (w_bb_1, 6, 'Calf Raise', 3, '15', '—', 60, 'Full hreyfing · halda í 1 sek á toppi', 'ti-arrow-bar-up');

-- Dagur 2: Efri líkami
insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_2, 1, 'Upphitun', 1, '5 mín', '—', 30, 'Bandalengingar fyrir axlir og bak', 'ti-stretching'),
  (w_bb_2, 2, 'Bench Press', 4, '6', '60', 120, 'Bakið svolítið kúpt · stangirnar í línu við brjóst', 'ti-barbell'),
  (w_bb_2, 3, 'Pull-ups', 4, '6-8', '—', 90, 'Full hreyfing · brjóstið upp að stönginni', 'ti-arrow-up'),
  (w_bb_2, 4, 'Dumbbell Shoulder Press', 3, '8', '15', 90, 'Sitja beint · ölbogarnir undir úlnliðum', 'ti-barbell'),
  (w_bb_2, 5, 'Bent Over Row', 3, '8', '50', 90, 'Bakið beint · togaðu að nafla · ölbogarnir nálægt líkamanum', 'ti-arrow-down'),
  (w_bb_2, 6, 'Face Pull', 3, '12', '15', 60, 'Bandalega · togaðu að augum · útþanin axla', 'ti-arrow-left');

-- Dagur 3: Hraði & Plyometrics
insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_3, 1, 'Upphitun & A-skips', 2, '20m', '—', 30, 'Hátt hné · línutilfinning', 'ti-run'),
  (w_bb_3, 2, 'Sprint 20m', 6, '20m', '—', 90, 'Allt í þessu · 90% kraftur · fullir hvíld', 'ti-flame'),
  (w_bb_3, 3, 'Broad Jump', 4, '5', '—', 90, 'Sveifla armum · stökkva sem lengst · mjúk lending', 'ti-arrow-right'),
  (w_bb_3, 4, 'Lateral Bound', 3, '6 hvor', '—', 75, 'Hliðarstökk · halda jafnvægi á einum fót', 'ti-arrows-left-right'),
  (w_bb_3, 5, 'Pogo Hops', 4, '20', '—', 60, 'Lágt stökk · háir fætur · sneið hraði', 'ti-arrow-up-bar'),
  (w_bb_3, 6, 'Cool Down', 1, '5 mín', '—', 0, 'Hægur jogger · stretches', 'ti-stretching');

-- Dagur 4: Heild & Kjarni
insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_bb_4, 1, 'Foam Roll', 1, '5 mín', '—', 0, 'Hægur · djúpur þrýstingur', 'ti-stretching'),
  (w_bb_4, 2, 'Goblet Squat', 3, '12', '24', 60, 'Hala loðu fyrir framan · djúp niður · bakið beint', 'ti-barbell'),
  (w_bb_4, 3, 'Push-up', 3, '12-15', '—', 60, 'Líkami beinn · niður að brjóstið snerti gólfið', 'ti-arrow-up'),
  (w_bb_4, 4, 'Plank', 3, '60s', '—', 60, 'Mjaðmir í línu · spenna kviðinn · djúpur andardráttur', 'ti-square'),
  (w_bb_4, 5, 'Side Plank', 3, '30s hvor', '—', 45, 'Líkami í línu · mjöðmin upp · andaðu eðlilega', 'ti-square'),
  (w_bb_4, 6, 'Hanging Leg Raise', 3, '10', '—', 60, 'Hangir á stöng · fætur upp í 90°', 'ti-arrow-up'),
  (w_bb_4, 7, 'Stretch & Mobility', 1, '10 mín', '—', 0, 'Djúpar stretches · halda 30 sek', 'ti-stretching');

-- ────────────────────────────────────────────────────────
-- ÁÆTLUN 2: KNATTSPYRNA BYRJANDI
-- ────────────────────────────────────────────────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_soccer, 'Knattspyrna Grunnur', 'Knattspyrna', 'beginner', 4, 12,
   'Þol, fótavinna og styrkur fyrir knattspyrnumenn', 'ti-ball-football');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_sc_1, p_soccer, 1, 'Fótstyrkur', 'Fætur · Stöðugleiki', 55),
  (w_sc_2, p_soccer, 2, 'Þol & Hraði', 'Cardio · Sprettir', 50),
  (w_sc_3, p_soccer, 3, 'Efri líkami & Kjarni', 'Heild · Stöðugleiki', 45),
  (w_sc_4, p_soccer, 4, 'Fótavinna', 'Lipur · Cone vinna', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_1, 1, 'Dynamic Upphitun', 1, '10 mín', '—', 0, 'A/B skips · leg swings · lunges', 'ti-run'),
  (w_sc_1, 2, 'Back Squat', 4, '6', '70', 120, 'Djúp · stöðug · sprengja upp', 'ti-barbell'),
  (w_sc_1, 3, 'Single Leg RDL', 3, '8 hvor', '15', 90, 'Bakið beint · ein lína frá höfði í fót', 'ti-stretching'),
  (w_sc_1, 4, 'Walking Lunges', 3, '12 hvor', '20', 90, 'Stór skref · djúp niður · beinn bolur', 'ti-walk'),
  (w_sc_1, 5, 'Nordic Hamstring Curl', 3, '6', '—', 90, 'Hægur niður · halda í 3 sek · pressa upp', 'ti-arrow-down'),
  (w_sc_1, 6, 'Copenhagen Plank', 3, '30s hvor', '—', 60, 'Innri læri · halda í línu', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_2, 1, 'Upphitun', 1, '8 mín', '—', 0, 'Jogg · dynamic stretches', 'ti-run'),
  (w_sc_2, 2, '400m Tempo Hlaup', 6, '400m', '—', 90, '80% kraftur · jafn hraði', 'ti-flame'),
  (w_sc_2, 3, '100m Sprettir', 6, '100m', '—', 60, '90-95% · fullir hvíld á milli', 'ti-bolt'),
  (w_sc_2, 4, 'Shuttle Run', 4, '5x20m', '—', 90, 'Hraði og snúningar · lágur þungi', 'ti-arrows-left-right'),
  (w_sc_2, 5, 'Cool Down Jog', 1, '5 mín', '—', 0, 'Hægur jogger · andardráttur', 'ti-run');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_3, 1, 'Upphitun', 1, '5 mín', '—', 0, 'Léttar hreyfingar · axla hringir', 'ti-stretching'),
  (w_sc_3, 2, 'Push-up', 4, '12', '—', 60, 'Líkami beinn · niður að brjóst snerti gólfið', 'ti-arrow-up'),
  (w_sc_3, 3, 'Pull-up', 4, '6-8', '—', 90, 'Full hreyfing · gripsstaða breytileg', 'ti-arrow-up'),
  (w_sc_3, 4, 'Dumbbell Row', 3, '10 hvor', '20', 75, 'Bakið beint · togaðu að mjöðm', 'ti-arrow-down'),
  (w_sc_3, 5, 'Plank', 3, '45s', '—', 60, 'Mjaðmir í línu · spenntur kjarni', 'ti-square'),
  (w_sc_3, 6, 'Russian Twist', 3, '20', '8', 60, 'Sitja · fætur upp · snúa frá hlið til hliðar', 'ti-rotate');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_sc_4, 1, 'Upphitun', 1, '8 mín', '—', 0, 'Stigvaxandi cardio · ankle mobility', 'ti-run'),
  (w_sc_4, 2, 'Ladder Drills', 4, '6 patterns', '—', 60, 'Fljót fót · létt á tánum · sjónarsvið upp', 'ti-grid-dots'),
  (w_sc_4, 3, 'T-Drill', 4, '1 hringur', '—', 75, 'Allt að 5m fram · 5m hlið · 5m aftur', 'ti-arrows-cross'),
  (w_sc_4, 4, 'Box Drill (5m)', 4, '1 hringur', '—', 75, 'Fram · hlið · aftur · hlið · hraðast', 'ti-square'),
  (w_sc_4, 5, 'Lateral Cone Hops', 3, '20 sek', '—', 60, 'Hliðarstökk yfir keilu · létt á tánum', 'ti-arrows-left-right'),
  (w_sc_4, 6, 'Mobility & Stretch', 1, '10 mín', '—', 0, 'Djúpar stretches á fótum og mjöðmum', 'ti-stretching');

-- ────────────────────────────────────────────────────────
-- ÁÆTLUN 3: ALMENN STYRKÞJÁLFUN (3 dagar/viku)
-- ────────────────────────────────────────────────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_strength, 'Almennur Styrkur', 'Almennt', 'beginner', 3, 12,
   'Heildarstyrkur fyrir alla — full líkamsþjálfun 3x/viku', 'ti-barbell');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_st_1, p_strength, 1, 'Push (Brjóst & Axlir)', 'Brjóst · Axlir · Triceps', 50),
  (w_st_2, p_strength, 2, 'Pull (Bak & Biceps)', 'Bak · Biceps · Aftan axla', 50),
  (w_st_3, p_strength, 3, 'Legs (Fætur & Kjarni)', 'Fætur · Rasskinnar · Kjarni', 55);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_st_1, 1, 'Upphitun', 1, '5 mín', '—', 0, 'Axlir og brjóst · band-pull aparts', 'ti-stretching'),
  (w_st_1, 2, 'Bench Press', 4, '8', '60', 120, 'Bakið svolítið kúpt · stangirnar í línu við brjóst', 'ti-barbell'),
  (w_st_1, 3, 'Overhead Press', 3, '8', '40', 90, 'Spenntur kjarni · pressa beint upp', 'ti-arrow-up'),
  (w_st_1, 4, 'Dumbbell Incline Press', 3, '10', '17', 90, 'Bekkur á 30° · pressa upp og inn', 'ti-barbell'),
  (w_st_1, 5, 'Tricep Dips', 3, '10-12', '—', 60, 'Ölbogarnir inn að líkamanum · djúp niður', 'ti-arrow-down'),
  (w_st_1, 6, 'Lateral Raise', 3, '12', '7', 60, 'Hægur · ölbogarnir lægra en úlnliðir · upp í 90°', 'ti-arrows-left-right');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_st_2, 1, 'Upphitun', 1, '5 mín', '—', 0, 'Léttar pull-ups · band rows', 'ti-stretching'),
  (w_st_2, 2, 'Pull-ups', 4, '6-8', '—', 90, 'Full hreyfing · brjóstið upp að stönginni', 'ti-arrow-up'),
  (w_st_2, 3, 'Barbell Row', 4, '8', '50', 90, 'Bakið beint · togaðu að nafla', 'ti-arrow-down'),
  (w_st_2, 4, 'Lat Pulldown', 3, '10', '40', 75, 'Bakið beint · togaðu að bringu · ölbogarnir niður', 'ti-arrow-down'),
  (w_st_2, 5, 'Dumbbell Curl', 3, '10 hvor', '12', 60, 'Ölbogi fastur · full hreyfing', 'ti-rotate'),
  (w_st_2, 6, 'Face Pull', 3, '12', '15', 60, 'Bandalega · togaðu að augum', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_st_3, 1, 'Upphitun', 1, '8 mín', '—', 0, 'Hip mobility · band squats', 'ti-stretching'),
  (w_st_3, 2, 'Back Squat', 4, '8', '70', 120, 'Djúp · stöðug · sprengja upp', 'ti-barbell'),
  (w_st_3, 3, 'Romanian Deadlift', 4, '8', '60', 90, 'Bakið beint · stangir nálægt fótum', 'ti-stretching'),
  (w_st_3, 4, 'Bulgarian Split Squat', 3, '10 hvor', '20', 75, 'Aftur fót á bekk · niður beint', 'ti-walk'),
  (w_st_3, 5, 'Leg Curl', 3, '12', '30', 60, 'Hægur · full hreyfing', 'ti-arrow-down'),
  (w_st_3, 6, 'Plank', 3, '60s', '—', 60, 'Mjaðmir í línu · spenna kviðinn', 'ti-square'),
  (w_st_3, 7, 'Hanging Leg Raise', 3, '10', '—', 60, 'Hangir á stöng · fætur upp í 90°', 'ti-arrow-up');

-- ────────────────────────────────────────────────────────
-- ÁÆTLUN 4: CROSSFIT / FUNCTIONAL FITNESS
-- ────────────────────────────────────────────────────────
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_crossfit, 'Functional Fitness', 'CrossFit', 'intermediate', 4, 12,
   'High-intensity · Olympic lifts · Conditioning · WODs', 'ti-flame');

insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w_cf_1, p_crossfit, 1, 'Olympic Lifts', 'Snatch · Clean & Jerk', 60),
  (w_cf_2, p_crossfit, 2, 'Strength + WOD', 'Squat + Metcon', 50),
  (w_cf_3, p_crossfit, 3, 'Gymnastics + Cardio', 'Pull-ups · Rowing', 45),
  (w_cf_4, p_crossfit, 4, 'Hero WOD', 'High-intensity full body', 55);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_1, 1, 'Upphitun', 1, '10 mín', '—', 0, 'Mobility · light barbell work', 'ti-stretching'),
  (w_cf_1, 2, 'Power Snatch', 5, '3', '50', 120, 'Sprengja frá mjöðmum · ölbogarnir út · gríptu fast', 'ti-bolt'),
  (w_cf_1, 3, 'Hang Clean', 5, '3', '60', 120, 'Hangandi staða · sprengja upp · catch fullum djúp', 'ti-arrow-up'),
  (w_cf_1, 4, 'Push Jerk', 4, '3', '50', 90, 'Dip og drive · pressa undir stöngina', 'ti-arrow-up-bar'),
  (w_cf_1, 5, 'Overhead Squat', 3, '5', '40', 90, 'Stöng yfir höfði · djúp squat', 'ti-barbell'),
  (w_cf_1, 6, 'Cool Down', 1, '5 mín', '—', 0, 'Mobility · breathing', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_2, 1, 'Upphitun', 1, '8 mín', '—', 0, 'Air squats · light barbell', 'ti-stretching'),
  (w_cf_2, 2, 'Back Squat', 5, '5', '90', 150, 'Tölulegur þungi · djúp · sprengja upp', 'ti-barbell'),
  (w_cf_2, 3, 'WOD: 21-15-9', 1, 'AMRAP', '—', 0, 'Thrusters @ 40kg + Pull-ups · sem hraðast', 'ti-flame'),
  (w_cf_2, 4, 'Cool Down', 1, '5 mín', '—', 0, 'Stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_3, 1, 'Upphitun', 1, '8 mín', '—', 0, 'Kipping practice · band work', 'ti-stretching'),
  (w_cf_3, 2, 'Strict Pull-ups', 5, '5', '—', 90, 'Hægur · full hreyfing · engin sveifla', 'ti-arrow-up'),
  (w_cf_3, 3, 'Handstand Practice', 5, '30s', '—', 60, 'Halda við vegg · spenntur kjarni', 'ti-arrow-up'),
  (w_cf_3, 4, 'Ring Dips', 4, '8', '—', 75, 'Stöðugar hringir · ölbogarnir inn', 'ti-arrow-down'),
  (w_cf_3, 5, 'Row 500m', 4, '500m', '—', 120, 'Allt í þessu · stöðug hraði', 'ti-flame'),
  (w_cf_3, 6, 'Cool Down', 1, '5 mín', '—', 0, 'Light stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w_cf_4, 1, 'Upphitun', 1, '10 mín', '—', 0, 'Full líkami · mobility', 'ti-stretching'),
  (w_cf_4, 2, 'Hero WOD ''Murph''', 1, '1 hringur', '—', 0, '1mile run + 100 pull-ups + 200 push-ups + 300 squats + 1mile run', 'ti-flame'),
  (w_cf_4, 3, 'Cool Down', 1, '10 mín', '—', 0, 'Hægur jogger · djúpar stretches', 'ti-stretching');

end $$;

-- Búið! 4 áætlanir + 14 þjálfunardagar + ~80 æfingar settar inn.
