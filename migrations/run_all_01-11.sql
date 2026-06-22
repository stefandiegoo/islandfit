-- ÍslandFit — keyrðu 01→11 Í RÖÐ, EINU SINNI.
-- (00_supabase_setup er þegar keyrt → ekki haft með.)
-- Límdu ALLA þessa skrá í Supabase → SQL Editor → Run.
-- ⚠️ EKKI endurkeyra eftir fyrstu vel-heppnuðu keyrslu: 02/03 þurrka prógram-gögn, 05 tvöfaldar.


-- ============================================================
-- 01_migration_v2.sql
-- ============================================================

-- ÍslandFit v2 — Auto-regulation & framfarir
-- Keyrðu þetta í SQL Editor (eftir fyrri migrations)

-- Bæta RPE dálki við workout_sets fyrir auto-regulation
alter table workout_sets add column if not exists rpe numeric;

-- Index fyrir hraðari lookup á síðustu frammistöðu
create index if not exists idx_workout_sets_user_exercise 
  on workout_sets(user_id, exercise_name, logged_at desc);

-- View sem sýnir vikulega heildarþyngd (volume)
create or replace view weekly_volume as
select 
  user_id,
  date_trunc('week', logged_at) as week,
  sum(weight_kg * reps) as total_volume_kg
from workout_sets
where weight_kg is not null
group by user_id, date_trunc('week', logged_at)
order by week;

-- View fyrir framfarir á hverri æfingu
create or replace view exercise_progression as
select 
  user_id,
  exercise_name,
  date_trunc('week', logged_at) as week,
  max(weight_kg) as max_weight,
  avg(weight_kg) as avg_weight,
  avg(rpe) as avg_rpe
from workout_sets
where weight_kg is not null
group by user_id, exercise_name, date_trunc('week', logged_at)
order by week;

-- Búið!


-- ============================================================
-- 02_programs_migration.sql
-- ============================================================

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


-- ============================================================
-- 03_migration_v3_english.sql
-- ============================================================

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


-- ============================================================
-- 04_migration_v4.sql
-- ============================================================

-- ÍslandFit v4 — Extended onboarding fields
-- Run in Supabase SQL Editor

alter table profiles add column if not exists position text;
alter table profiles add column if not exists primary_goal text;
alter table profiles add column if not exists equipment text default 'full_gym';
alter table profiles add column if not exists days_available int default 4;
alter table profiles add column if not exists session_length int default 60;
alter table profiles add column if not exists age int;
alter table profiles add column if not exists bodyweight_kg numeric;

-- Done!


-- ============================================================
-- 05_migration_v5_iceland_sports.sql
-- ============================================================

-- ÍslandFit v5 — All major Icelandic sports
-- Adds programs for sports popular in Iceland
-- Run in Supabase SQL Editor AFTER migration_v3_english.sql

do $$
declare
  -- New sport programs
  p_handball uuid := gen_random_uuid();
  p_athletics uuid := gen_random_uuid();
  p_golf uuid := gen_random_uuid();
  p_swimming uuid := gen_random_uuid();
  p_volleyball uuid := gen_random_uuid();
  p_skiing uuid := gen_random_uuid();
  p_icehockey uuid := gen_random_uuid();
  p_tennis uuid := gen_random_uuid();
  p_gymnastics uuid := gen_random_uuid();
  p_climbing uuid := gen_random_uuid();
  p_horseriding uuid := gen_random_uuid();
  p_strongman uuid := gen_random_uuid();
  p_powerlifting uuid := gen_random_uuid();
  p_glima uuid := gen_random_uuid();
  p_mma uuid := gen_random_uuid();
  p_running uuid := gen_random_uuid();
  p_cycling uuid := gen_random_uuid();
  p_badminton uuid := gen_random_uuid();
  -- Workout UUIDs (one per program, kept simple — 4 days each)
  w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin

-- ════════════════════════════════════════
-- HANDBALL (Iceland's most popular sport)
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_handball, 'Handball Performance', 'Handball', 'beginner', 4, 12,
   'Explosive power, shoulder strength, and lateral movement for handball', 'ti-hand-grab');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_handball, 1, 'Lower Body Power', 'Legs · Explosive Jump', 55),
  (w2, p_handball, 2, 'Throwing Power', 'Shoulders · Core · Rotation', 50),
  (w3, p_handball, 3, 'Lateral Speed', 'Agility · Cutting', 45),
  (w4, p_handball, 4, 'Conditioning & Core', 'Endurance · Anti-rotation', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Dynamic Warm-up', 1, '8 min', '—', 30, 'Hip openers · ankle mobility · A-skips', 'ti-stretching'),
  (w1, 2, 'Back Squat', 4, '5', '80', 120, 'Deep · explosive concentric', 'ti-barbell'),
  (w1, 3, 'Trap Bar Deadlift', 4, '5', '90', 120, 'Push floor away · neutral spine', 'ti-barbell'),
  (w1, 4, 'Single Leg Box Jump', 4, '4 each', '24in', 90, 'Stick the landing · explosive drive', 'ti-arrow-up'),
  (w1, 5, 'Reverse Lunge', 3, '8 each', '20', 75, 'Step long · drop straight down', 'ti-walk'),
  (w1, 6, 'Calf Raise', 3, '15', '40', 60, 'Pause at top · controlled descent', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Shoulder Warm-up', 1, '8 min', '—', 30, 'Band pull-aparts · YTW · rotations', 'ti-stretching'),
  (w2, 2, 'Push Press', 4, '5', '50', 120, 'Dip and drive · lockout overhead', 'ti-arrow-up'),
  (w2, 3, 'Medicine Ball Slam', 4, '6', '6kg', 90, 'Full body extension · slam hard', 'ti-bolt'),
  (w2, 4, 'Rotational MB Throw', 3, '5 each', '5kg', 90, 'Rotate from hips · explosive release', 'ti-rotate'),
  (w2, 5, 'Cable Wood Chop', 3, '10 each', '20', 60, 'High to low rotation · brace core', 'ti-arrow-down'),
  (w2, 6, 'Plank', 3, '45s', '—', 60, 'Hips level · braced throughout', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Side shuffles · carioca · skips', 'ti-run'),
  (w3, 2, 'Lateral Bound', 4, '5 each', '—', 90, 'Stick single leg landing · pause', 'ti-arrows-left-right'),
  (w3, 3, '5-10-5 Pro Agility', 5, '1', '—', 90, 'Plant low · explode out of cut', 'ti-arrows-cross'),
  (w3, 4, 'Cone Reaction Drill', 4, '20 sec', '—', 75, 'Quick feet · stay athletic', 'ti-grid-dots'),
  (w3, 5, 'Lateral Sled Drag', 3, '20m each', '40', 90, 'Hips low · short choppy steps', 'ti-arrow-right'),
  (w3, 6, 'Cool Down', 1, '5 min', '—', 0, 'Light jog · stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '5 min', '—', 30, 'Light cardio · band work', 'ti-stretching'),
  (w4, 2, 'Pull-ups', 4, '6-8', '—', 90, 'Full hang · chest to bar', 'ti-arrow-up'),
  (w4, 3, 'Sled Push', 5, '20m', '60', 90, 'Drive through legs · low body angle', 'ti-arrow-right'),
  (w4, 4, 'Pallof Press', 3, '10 each', '15', 60, 'Resist rotation · breathe out', 'ti-square'),
  (w4, 5, 'Farmers Carry', 3, '30m', '25 each', 90, 'Tall posture · short fast steps', 'ti-grip'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Deep hip and shoulder stretches', 'ti-stretching');

-- ════════════════════════════════════════
-- ATHLETICS (Track & Field)
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_athletics, 'Athletics Foundation', 'Athletics', 'beginner', 4, 12,
   'Sprint speed, power development, and conditioning for track & field', 'ti-run');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_athletics, 1, 'Sprint Development', 'Acceleration · Top Speed', 60),
  (w2, p_athletics, 2, 'Lower Body Strength', 'Legs · Posterior Chain', 55),
  (w3, p_athletics, 3, 'Plyometrics & Power', 'Jump · Bound · Explode', 50),
  (w4, p_athletics, 4, 'Tempo & Core', 'Aerobic · Stability', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Sprint Warm-up', 1, '12 min', '—', 30, 'A-skips · B-skips · build-up runs', 'ti-run'),
  (w1, 2, '10m Acceleration', 6, '10m', '—', 90, 'Drive low · push the ground', 'ti-bolt'),
  (w1, 3, '30m Flying Sprint', 5, '30m', '—', 150, 'Smooth acceleration · max speed', 'ti-bolt'),
  (w1, 4, '60m Sprint', 4, '60m', '—', 180, 'Full effort · tall posture at top', 'ti-flame'),
  (w1, 5, 'Cool Down', 1, '8 min', '—', 0, 'Easy jog · static stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Mobility drills', 'ti-stretching'),
  (w2, 2, 'Back Squat', 4, '5', '85', 150, 'Heavy · drive up explosively', 'ti-barbell'),
  (w2, 3, 'Romanian Deadlift', 4, '6', '70', 120, 'Push hips back · hamstrings load', 'ti-stretching'),
  (w2, 4, 'Bulgarian Split Squat', 3, '8 each', '25', 90, 'Rear foot elevated · drop straight', 'ti-walk'),
  (w2, 5, 'Glute Bridge', 3, '10', '60', 75, 'Squeeze glutes at top · 2 sec hold', 'ti-arrow-up'),
  (w2, 6, 'Hip Flexor Stretch', 1, '5 min', '—', 0, 'Open up hips · 30 sec holds', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '10 min', '—', 30, 'Dynamic mobility', 'ti-stretching'),
  (w3, 2, 'Broad Jump', 5, '3', '—', 120, 'Arm swing · jump for distance', 'ti-arrow-right'),
  (w3, 3, 'Box Jump', 4, '5', '24in', 90, 'Land soft · stand tall', 'ti-arrow-up'),
  (w3, 4, 'Bounding', 4, '20m', '—', 120, 'Long strides · arm drive · float', 'ti-walk'),
  (w3, 5, 'Single Leg Hop', 3, '5 each', '—', 90, 'Stick each landing · stay balanced', 'ti-arrow-up'),
  (w3, 6, 'Cool Down', 1, '5 min', '—', 0, 'Easy stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Easy jog · drills', 'ti-run'),
  (w4, 2, 'Tempo Run', 6, '200m', '—', 60, '70-75% effort · relaxed form', 'ti-run'),
  (w4, 3, 'Plank Variations', 3, '45s', '—', 45, 'Front · side · side · breathe', 'ti-square'),
  (w4, 4, 'Dead Bug', 3, '10 each', '—', 60, 'Press low back to floor · slow', 'ti-arrows-left-right'),
  (w4, 5, 'Hanging Leg Raise', 3, '10', '—', 60, 'No swing · 90° hip flexion', 'ti-arrow-up'),
  (w4, 6, 'Mobility', 1, '10 min', '—', 0, 'Full body stretches', 'ti-stretching');

-- ════════════════════════════════════════
-- GOLF
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_golf, 'Golf Performance', 'Golf', 'beginner', 3, 12,
   'Rotational power, mobility, and stability for a longer drive', 'ti-golf');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_golf, 1, 'Rotational Power', 'Core · Hips · Swing Speed', 50),
  (w2, p_golf, 2, 'Strength & Stability', 'Legs · Back · Balance', 55),
  (w3, p_golf, 3, 'Mobility & Recovery', 'Thoracic · Hips · Wrists', 40);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Cat-cow · thoracic rotations · hip openers', 'ti-stretching'),
  (w1, 2, 'Medicine Ball Rotational Throw', 4, '6 each', '4kg', 75, 'Hips lead · release at impact', 'ti-rotate'),
  (w1, 3, 'Landmine Rotation', 3, '8 each', '15', 75, 'Rotate through hips · stable feet', 'ti-rotate'),
  (w1, 4, 'Cable Wood Chop', 3, '10 each', '20', 60, 'High to low · core engaged', 'ti-arrow-down'),
  (w1, 5, 'Pallof Press', 3, '10 each', '15', 60, 'Anti-rotation · hold 2 sec', 'ti-square'),
  (w1, 6, 'Stretch', 1, '5 min', '—', 0, 'Spine and hip stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Glute activation · band walks', 'ti-stretching'),
  (w2, 2, 'Goblet Squat', 4, '10', '24', 75, 'Upright torso · deep range', 'ti-barbell'),
  (w2, 3, 'Single Leg RDL', 3, '8 each', '15', 75, 'Hip hinge · stable balance', 'ti-stretching'),
  (w2, 4, 'Dumbbell Row', 3, '10 each', '17', 60, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w2, 5, 'Push-up', 3, '10', '—', 60, 'Solid plank · full range', 'ti-arrow-up'),
  (w2, 6, 'Side Plank', 3, '30s each', '—', 45, 'Hip up · body in line', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Foam Roll', 1, '8 min', '—', 30, 'Upper back · glutes · quads', 'ti-stretching'),
  (w3, 2, 'Thoracic Spine Rotations', 3, '8 each', '—', 30, 'Slow controlled rotation', 'ti-rotate'),
  (w3, 3, 'Hip 90/90 Stretch', 3, '30s each', '—', 30, 'Sit tall · breathe deep', 'ti-stretching'),
  (w3, 4, 'Wrist Mobility', 2, '8 each direction', '—', 20, 'Circles and flexion', 'ti-rotate'),
  (w3, 5, 'World''s Greatest Stretch', 3, '5 each', '—', 30, 'Lunge · rotate · reach', 'ti-stretching'),
  (w3, 6, 'Deep Breathing', 1, '5 min', '—', 0, 'Box breathing 4-4-4-4', 'ti-lungs');

-- ════════════════════════════════════════
-- SWIMMING
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_swimming, 'Swimmer Strength', 'Swimming', 'beginner', 4, 12,
   'Dryland training for swimmers — pull power, core stability, shoulder health', 'ti-pool');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_swimming, 1, 'Pull Power', 'Lats · Back · Pull Strength', 50),
  (w2, p_swimming, 2, 'Lower Body & Kick', 'Glutes · Hamstrings · Calves', 50),
  (w3, p_swimming, 3, 'Core & Stability', 'Anti-rotation · Endurance', 45),
  (w4, p_swimming, 4, 'Shoulder Health', 'Rotator Cuff · Mobility', 40);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder mobility · band work', 'ti-stretching'),
  (w1, 2, 'Pull-ups', 4, '6-8', '—', 90, 'Full hang · pull chest to bar', 'ti-arrow-up'),
  (w1, 3, 'Straight Arm Pulldown', 3, '12', '25', 60, 'Mimic swim pull · lats engaged', 'ti-arrow-down'),
  (w1, 4, 'Single Arm Row', 3, '10 each', '20', 60, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w1, 5, 'Face Pull', 3, '12', '15', 60, 'External rotation · pause', 'ti-arrow-left'),
  (w1, 6, 'Hanging Leg Raise', 3, '10', '—', 60, 'Hollow body position', 'ti-arrow-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Mobility · activation', 'ti-stretching'),
  (w2, 2, 'Romanian Deadlift', 4, '8', '60', 90, 'Push hips back · long hamstrings', 'ti-stretching'),
  (w2, 3, 'Bulgarian Split Squat', 3, '10 each', '15', 75, 'Rear foot elevated', 'ti-walk'),
  (w2, 4, 'Hip Thrust', 3, '10', '50', 75, 'Drive hips up · squeeze glutes', 'ti-arrow-up'),
  (w2, 5, 'Standing Calf Raise', 3, '15', '40', 60, 'Full range · pause at top', 'ti-arrow-bar-up'),
  (w2, 6, 'Glute Bridge Hold', 3, '30s', '—', 45, 'Squeeze glutes throughout', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w3, 2, 'Hollow Body Hold', 4, '30s', '—', 60, 'Lower back pressed down', 'ti-square'),
  (w3, 3, 'Plank', 3, '60s', '—', 60, 'Tight body · breathe', 'ti-square'),
  (w3, 4, 'Side Plank with Reach', 3, '8 each', '—', 60, 'Hip up · reach under and through', 'ti-rotate'),
  (w3, 5, 'Pallof Press', 3, '10 each', '15', 60, 'Anti-rotation', 'ti-square'),
  (w3, 6, 'Dead Bug', 3, '10 each', '—', 60, 'Slow controlled · low back flat', 'ti-arrows-left-right');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Foam Roll', 1, '5 min', '—', 30, 'Upper back · lats · pecs', 'ti-stretching'),
  (w4, 2, 'YTW Raises', 3, '8 each', '3', 60, 'Light weight · perfect form', 'ti-arrows-up-down'),
  (w4, 3, 'External Rotation', 3, '12 each', '5', 60, 'Elbow tucked · slow', 'ti-rotate'),
  (w4, 4, 'Scapular Pull-up', 3, '8', '—', 60, 'Hang · pull shoulder blades down', 'ti-arrow-up'),
  (w4, 5, 'Thoracic Mobility', 3, '8 each', '—', 30, 'Open chest · rotate', 'ti-rotate'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Full body · deep breathing', 'ti-stretching');

-- ════════════════════════════════════════
-- VOLLEYBALL
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_volleyball, 'Volleyball Power', 'Volleyball', 'beginner', 4, 12,
   'Vertical jump, shoulder power, and lateral quickness', 'ti-ball-volleyball');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_volleyball, 1, 'Vertical Jump', 'Plyometrics · Power', 50),
  (w2, p_volleyball, 2, 'Upper Body Power', 'Shoulders · Hitting Strength', 50),
  (w3, p_volleyball, 3, 'Lower Body Strength', 'Legs · Glutes', 55),
  (w4, p_volleyball, 4, 'Agility & Core', 'Lateral · Stability', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Dynamic · jump prep', 'ti-stretching'),
  (w1, 2, 'Box Jump', 5, '5', '24in', 90, 'Explosive · soft landing', 'ti-arrow-up'),
  (w1, 3, 'Approach Jump', 4, '5', '—', 90, 'Practice your spike approach', 'ti-arrow-up'),
  (w1, 4, 'Depth Jump', 3, '4', '18in', 120, 'Step off · jump immediately', 'ti-arrow-up'),
  (w1, 5, 'Squat Jump', 3, '6', '—', 90, 'Bodyweight · max height', 'ti-arrow-up'),
  (w1, 6, 'Cool Down', 1, '5 min', '—', 0, 'Light stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder prep', 'ti-stretching'),
  (w2, 2, 'Overhead Press', 4, '6', '45', 90, 'Press straight up · lockout', 'ti-arrow-up'),
  (w2, 3, 'Medicine Ball Overhead Slam', 4, '6', '5kg', 90, 'Full extension · slam down', 'ti-bolt'),
  (w2, 4, 'Pull-ups', 4, '6-8', '—', 90, 'Full range · controlled', 'ti-arrow-up'),
  (w2, 5, 'Dumbbell Push Press', 3, '8', '15', 75, 'Use legs to drive', 'ti-arrow-up'),
  (w2, 6, 'Face Pull', 3, '12', '15', 60, 'Shoulder health', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Glute activation', 'ti-stretching'),
  (w3, 2, 'Back Squat', 4, '5', '75', 120, 'Heavy · drive up', 'ti-barbell'),
  (w3, 3, 'Trap Bar Deadlift', 4, '5', '85', 120, 'Push floor away', 'ti-barbell'),
  (w3, 4, 'Walking Lunge', 3, '10 each', '20', 75, 'Long stride · drop knee', 'ti-walk'),
  (w3, 5, 'Romanian Deadlift', 3, '8', '60', 75, 'Hamstrings load', 'ti-stretching'),
  (w3, 6, 'Calf Raise', 3, '12', '40', 60, 'Slow eccentric', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Dynamic movement', 'ti-run'),
  (w4, 2, 'Lateral Bound', 4, '5 each', '—', 75, 'Stick the landing', 'ti-arrows-left-right'),
  (w4, 3, 'Cone Shuffle Drill', 4, '20 sec', '—', 75, 'Stay low · quick feet', 'ti-grid-dots'),
  (w4, 4, 'Plank', 3, '60s', '—', 60, 'Tight body', 'ti-square'),
  (w4, 5, 'Russian Twist', 3, '20', '8', 60, 'Rotate through core', 'ti-rotate'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Full body cool down', 'ti-stretching');

-- ════════════════════════════════════════
-- POWERLIFTING
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_powerlifting, 'Powerlifting Strength', 'Powerlifting', 'intermediate', 4, 12,
   'Build max strength in squat, bench, and deadlift', 'ti-barbell');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_powerlifting, 1, 'Squat Day', 'Max Squat · Accessories', 75),
  (w2, p_powerlifting, 2, 'Bench Day', 'Max Bench · Accessories', 70),
  (w3, p_powerlifting, 3, 'Deadlift Day', 'Max Deadlift · Accessories', 75),
  (w4, p_powerlifting, 4, 'Light Volume Day', 'Pump · Recovery · Form', 60);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hips · ankles · empty bar sets', 'ti-stretching'),
  (w1, 2, 'Back Squat', 5, '3', '90', 180, 'Tight setup · controlled descent · drive', 'ti-barbell'),
  (w1, 3, 'Front Squat', 3, '5', '60', 120, 'Upright torso · elbows high', 'ti-barbell'),
  (w1, 4, 'Bulgarian Split Squat', 3, '8 each', '20', 90, 'Quad emphasis', 'ti-walk'),
  (w1, 5, 'Leg Curl', 3, '10', '30', 75, 'Slow eccentric', 'ti-arrow-down'),
  (w1, 6, 'Plank', 3, '60s', '—', 60, 'Bracing practice', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '10 min', '—', 30, 'Shoulder mobility · empty bar', 'ti-stretching'),
  (w2, 2, 'Bench Press', 5, '3', '80', 180, 'Tight setup · pause on chest · drive', 'ti-barbell'),
  (w2, 3, 'Close Grip Bench', 4, '6', '60', 120, 'Elbows tucked', 'ti-barbell'),
  (w2, 4, 'Dumbbell Row', 4, '10 each', '25', 75, 'Flat back · pull to hip', 'ti-arrow-down'),
  (w2, 5, 'Overhead Press', 3, '8', '40', 90, 'Strict press · core tight', 'ti-arrow-up'),
  (w2, 6, 'Face Pull', 3, '15', '15', 60, 'Rear delt health', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hip openers · empty bar pulls', 'ti-stretching'),
  (w3, 2, 'Conventional Deadlift', 5, '3', '110', 180, 'Tight back · push the floor', 'ti-barbell'),
  (w3, 3, 'Romanian Deadlift', 4, '6', '80', 120, 'Hamstring focus · push hips back', 'ti-stretching'),
  (w3, 4, 'Pull-ups', 4, '6-8', '—', 90, 'Wide grip · full range', 'ti-arrow-up'),
  (w3, 5, 'Barbell Row', 3, '8', '60', 90, 'Pendlay style', 'ti-arrow-down'),
  (w3, 6, 'Back Extension', 3, '10', '—', 60, 'Squeeze glutes at top', 'ti-arrow-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Full body mobility', 'ti-stretching'),
  (w4, 2, 'Goblet Squat', 4, '10', '24', 60, 'Light · perfect form', 'ti-barbell'),
  (w4, 3, 'Push-up', 4, '12', '—', 60, 'Strict form', 'ti-arrow-up'),
  (w4, 4, 'Single Leg RDL', 3, '8 each', '12', 60, 'Balance work', 'ti-stretching'),
  (w4, 5, 'Curl & Press', 3, '10', '12', 60, 'Bicep + shoulder pump', 'ti-rotate'),
  (w4, 6, 'Stretch', 1, '10 min', '—', 0, 'Recovery focus', 'ti-stretching');

-- ════════════════════════════════════════
-- ICE HOCKEY
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_icehockey, 'Hockey Performance', 'Ice Hockey', 'beginner', 4, 12,
   'Skating power, rotational strength, and conditioning', 'ti-skating');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_icehockey, 1, 'Skating Power', 'Hips · Glutes · Lateral', 55),
  (w2, p_icehockey, 2, 'Upper Body & Shot Power', 'Chest · Back · Core Rotation', 50),
  (w3, p_icehockey, 3, 'Conditioning', 'Anaerobic · Sprint Intervals', 45),
  (w4, p_icehockey, 4, 'Core & Stability', 'Anti-rotation · Endurance', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hip mobility · skater drills', 'ti-stretching'),
  (w1, 2, 'Front Squat', 4, '5', '60', 120, 'Upright posture · deep range', 'ti-barbell'),
  (w1, 3, 'Lateral Lunge', 3, '8 each', '20', 90, 'Push hip back · stay low', 'ti-arrows-left-right'),
  (w1, 4, 'Skater Hop', 4, '6 each', '—', 75, 'Side bound · stick landing', 'ti-arrows-left-right'),
  (w1, 5, 'Single Leg RDL', 3, '8 each', '15', 75, 'Balance · hamstrings', 'ti-stretching'),
  (w1, 6, 'Copenhagen Plank', 3, '20s each', '—', 60, 'Inner thigh strength', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder prep · band work', 'ti-stretching'),
  (w2, 2, 'Bench Press', 4, '6', '60', 90, 'Solid base · controlled', 'ti-barbell'),
  (w2, 3, 'Pull-ups', 4, '6-8', '—', 90, 'Full range · pause at top', 'ti-arrow-up'),
  (w2, 4, 'Cable Wood Chop', 4, '8 each', '20', 75, 'Mimic shot motion · explosive', 'ti-arrow-down'),
  (w2, 5, 'Medicine Ball Rotational Throw', 3, '6 each', '5kg', 75, 'Hips lead · release at peak', 'ti-rotate'),
  (w2, 6, 'Plank', 3, '60s', '—', 60, 'Strong core base', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Easy jog · dynamic', 'ti-run'),
  (w3, 2, 'Bike Sprints', 8, '30s', '—', 60, 'All out 30s · 60s rest', 'ti-bike'),
  (w3, 3, '40-yard Sprint', 6, '40 yd', '—', 90, 'Max effort', 'ti-bolt'),
  (w3, 4, 'Shuttle Run', 4, '5x20m', '—', 90, 'Turn fast · drive out', 'ti-arrows-left-right'),
  (w3, 5, 'Cool Down', 1, '5 min', '—', 0, 'Easy jog · stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w4, 2, 'Pallof Press', 4, '10 each', '15', 60, 'Resist rotation · breathe', 'ti-square'),
  (w4, 3, 'Side Plank', 3, '45s each', '—', 60, 'Hip up · solid line', 'ti-square'),
  (w4, 4, 'Dead Bug', 3, '10 each', '—', 60, 'Low back pressed down', 'ti-arrows-left-right'),
  (w4, 5, 'Bird Dog', 3, '8 each', '—', 45, 'Opposite arm/leg · controlled', 'ti-stretching'),
  (w4, 6, 'Stretch', 1, '8 min', '—', 0, 'Recovery focus', 'ti-stretching');

-- ════════════════════════════════════════
-- TENNIS
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_tennis, 'Tennis Performance', 'Tennis', 'beginner', 3, 12,
   'Rotational power, agility, and shoulder strength', 'ti-trophy');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_tennis, 1, 'Power & Rotation', 'Hips · Core · Serve Power', 55),
  (w2, p_tennis, 2, 'Lower Body & Speed', 'Legs · Footwork', 55),
  (w3, p_tennis, 3, 'Upper Body & Shoulder', 'Stability · Strength', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Dynamic · thoracic mobility', 'ti-stretching'),
  (w1, 2, 'Medicine Ball Rotational Throw', 4, '6 each', '5kg', 75, 'Hips lead · explosive', 'ti-rotate'),
  (w1, 3, 'Landmine Rotation', 3, '8 each', '20', 75, 'Stable feet · drive through core', 'ti-rotate'),
  (w1, 4, 'Cable Wood Chop', 3, '10 each', '20', 60, 'High to low · controlled', 'ti-arrow-down'),
  (w1, 5, 'Plank with Rotation', 3, '8 each', '—', 60, 'Anti-rotation challenge', 'ti-rotate'),
  (w1, 6, 'Russian Twist', 3, '20', '8', 60, 'Side to side', 'ti-rotate');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '10 min', '—', 30, 'Footwork drills · ladder', 'ti-run'),
  (w2, 2, 'Back Squat', 4, '6', '70', 90, 'Deep · controlled', 'ti-barbell'),
  (w2, 3, 'Lateral Bound', 4, '5 each', '—', 75, 'Single leg landing', 'ti-arrows-left-right'),
  (w2, 4, 'Ladder Drills', 4, '3 patterns', '—', 60, 'Quick feet · light contacts', 'ti-grid-dots'),
  (w2, 5, 'Cone Sprint', 4, '20m', '—', 75, 'Decel and reaccel', 'ti-bolt'),
  (w2, 6, 'Calf Raise', 3, '12', '40', 60, 'Slow eccentric', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Shoulder prep · YTW', 'ti-stretching'),
  (w3, 2, 'Overhead Press', 4, '6', '40', 90, 'Strict press · core braced', 'ti-arrow-up'),
  (w3, 3, 'Pull-ups', 4, '6-8', '—', 90, 'Full hang · chest to bar', 'ti-arrow-up'),
  (w3, 4, 'Dumbbell Row', 3, '10 each', '20', 60, 'Back focus', 'ti-arrow-down'),
  (w3, 5, 'External Rotation', 3, '12 each', '5', 60, 'Cuff strength', 'ti-rotate'),
  (w3, 6, 'Face Pull', 3, '15', '15', 60, 'Posture · rear delt', 'ti-arrow-left');

-- ════════════════════════════════════════
-- RUNNING (Distance / Road Running)
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_running, 'Runner Strength', 'Running', 'beginner', 3, 12,
   'Strength and stability work for runners — injury prevention + performance', 'ti-run');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_running, 1, 'Lower Body Strength', 'Glutes · Hamstrings · Calves', 50),
  (w2, p_running, 2, 'Core & Hip Stability', 'Anti-rotation · Glute Med', 45),
  (w3, p_running, 3, 'Upper Body & Form', 'Posture · Arm Drive', 45);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '8 min', '—', 30, 'Glute activation · ankle mobility', 'ti-stretching'),
  (w1, 2, 'Single Leg RDL', 4, '8 each', '15', 75, 'Hip hinge · balance', 'ti-stretching'),
  (w1, 3, 'Bulgarian Split Squat', 3, '10 each', '15', 75, 'Quad and glute focus', 'ti-walk'),
  (w1, 4, 'Calf Raise', 4, '15', '40', 60, 'Full range · single leg variation', 'ti-arrow-bar-up'),
  (w1, 5, 'Glute Bridge', 3, '12', '40', 60, 'Squeeze at top', 'ti-arrow-up'),
  (w1, 6, 'Nordic Hamstring', 3, '6', '—', 75, 'Slow eccentric · 3 sec', 'ti-arrow-down');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w2, 2, 'Plank', 4, '60s', '—', 60, 'Tight body', 'ti-square'),
  (w2, 3, 'Side Plank', 3, '45s each', '—', 60, 'Hip up · stable line', 'ti-square'),
  (w2, 4, 'Dead Bug', 3, '10 each', '—', 60, 'Slow controlled', 'ti-arrows-left-right'),
  (w2, 5, 'Clamshell', 3, '15 each', '—', 45, 'Glute med activation', 'ti-arrow-right'),
  (w2, 6, 'Bird Dog', 3, '10 each', '—', 45, 'Opposite limbs', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Upper body mobility', 'ti-stretching'),
  (w3, 2, 'Push-up', 4, '10', '—', 60, 'Full body tension', 'ti-arrow-up'),
  (w3, 3, 'Inverted Row', 3, '10', '—', 60, 'Pull chest to bar', 'ti-arrow-down'),
  (w3, 4, 'Dumbbell Row', 3, '10 each', '15', 60, 'Posture focus', 'ti-arrow-down'),
  (w3, 5, 'Face Pull', 3, '12', '12', 60, 'Counteract running posture', 'ti-arrow-left'),
  (w3, 6, 'Stretch', 1, '10 min', '—', 0, 'Hips · hamstrings · calves', 'ti-stretching');

-- ════════════════════════════════════════
-- CYCLING
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_cycling, 'Cyclist Strength', 'Cycling', 'beginner', 3, 12,
   'Build leg strength and core stability for cycling power', 'ti-bike');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_cycling, 1, 'Leg Power', 'Quads · Glutes · Hamstrings', 55),
  (w2, p_cycling, 2, 'Core & Back', 'Riding Posture · Stability', 45),
  (w3, p_cycling, 3, 'Single Leg & Balance', 'Imbalance Correction', 50);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Hip and knee mobility', 'ti-stretching'),
  (w1, 2, 'Back Squat', 4, '6', '70', 120, 'Deep · explosive', 'ti-barbell'),
  (w1, 3, 'Leg Press', 4, '8', '120', 90, 'Full range', 'ti-arrow-up'),
  (w1, 4, 'Walking Lunge', 3, '12 each', '20', 75, 'Long stride', 'ti-walk'),
  (w1, 5, 'Leg Curl', 3, '10', '30', 60, 'Slow eccentric', 'ti-arrow-down'),
  (w1, 6, 'Calf Raise', 3, '15', '40', 60, 'Full range', 'ti-arrow-bar-up');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '5 min', '—', 30, 'Core activation', 'ti-stretching'),
  (w2, 2, 'Plank', 4, '60s', '—', 60, 'Solid line', 'ti-square'),
  (w2, 3, 'Side Plank', 3, '45s each', '—', 60, 'Hip up', 'ti-square'),
  (w2, 4, 'Superman Hold', 3, '20s', '—', 60, 'Back extension', 'ti-arrow-up'),
  (w2, 5, 'Cable Row', 3, '10', '40', 60, 'Posture support', 'ti-arrow-down'),
  (w2, 6, 'Face Pull', 3, '12', '12', 60, 'Counter cycling posture', 'ti-arrow-left');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '8 min', '—', 30, 'Single leg mobility', 'ti-stretching'),
  (w3, 2, 'Single Leg Squat', 3, '6 each', '—', 90, 'Balance · controlled', 'ti-walk'),
  (w3, 3, 'Bulgarian Split Squat', 3, '10 each', '15', 75, 'Rear foot elevated', 'ti-walk'),
  (w3, 4, 'Single Leg RDL', 3, '8 each', '15', 75, 'Hip hinge balance', 'ti-stretching'),
  (w3, 5, 'Single Leg Glute Bridge', 3, '10 each', '—', 60, 'Squeeze glute', 'ti-arrow-up'),
  (w3, 6, 'Stretch', 1, '10 min', '—', 0, 'Hip flexors · quads · calves', 'ti-stretching');

-- ════════════════════════════════════════
-- MMA / COMBAT SPORTS
-- ════════════════════════════════════════
insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
  (p_mma, 'MMA Strength', 'MMA', 'intermediate', 4, 12,
   'Strength, power, and conditioning for combat athletes', 'ti-karate');

w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
  (w1, p_mma, 1, 'Strength Day', 'Compound Lifts · Power', 60),
  (w2, p_mma, 2, 'Conditioning', 'Anaerobic · HIIT', 45),
  (w3, p_mma, 3, 'Power & Speed', 'Plyo · Explosive', 50),
  (w4, p_mma, 4, 'Grappling Strength', 'Grip · Core · Pull', 55);

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w1, 1, 'Warm-up', 1, '10 min', '—', 30, 'Full body dynamic', 'ti-stretching'),
  (w1, 2, 'Trap Bar Deadlift', 4, '5', '90', 120, 'Tight back · push the floor', 'ti-barbell'),
  (w1, 3, 'Front Squat', 4, '5', '70', 120, 'Upright torso', 'ti-barbell'),
  (w1, 4, 'Overhead Press', 3, '6', '45', 90, 'Strict press', 'ti-arrow-up'),
  (w1, 5, 'Pull-ups', 3, '6-8', '—', 90, 'Full range', 'ti-arrow-up'),
  (w1, 6, 'Plank', 3, '60s', '—', 60, 'Bracing', 'ti-square');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w2, 1, 'Warm-up', 1, '8 min', '—', 30, 'Dynamic mobility', 'ti-run'),
  (w2, 2, 'Burpee', 5, '10', '—', 60, 'Full extension · explosive', 'ti-arrow-up'),
  (w2, 3, 'Battle Ropes', 5, '30s', '—', 60, 'Max intensity', 'ti-arrows-left-right'),
  (w2, 4, 'Box Jump', 5, '5', '24in', 60, 'Explosive · soft landing', 'ti-arrow-up'),
  (w2, 5, 'Bike Sprint', 6, '30s', '—', 60, 'All out 30/60', 'ti-bike'),
  (w2, 6, 'Cool Down', 1, '5 min', '—', 0, 'Stretches', 'ti-stretching');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w3, 1, 'Warm-up', 1, '10 min', '—', 30, 'Explosive prep', 'ti-stretching'),
  (w3, 2, 'Power Clean', 5, '3', '60', 120, 'Explosive triple extension', 'ti-bolt'),
  (w3, 3, 'Medicine Ball Slam', 4, '6', '8kg', 75, 'Full power · slam hard', 'ti-bolt'),
  (w3, 4, 'Broad Jump', 4, '5', '—', 90, 'Max distance', 'ti-arrow-right'),
  (w3, 5, 'Push-up Clap', 3, '6', '—', 75, 'Explosive push', 'ti-arrow-up'),
  (w3, 6, 'Plyo Lunge', 3, '8', '—', 75, 'Switch in air', 'ti-walk');

insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
  (w4, 1, 'Warm-up', 1, '8 min', '—', 30, 'Pull prep · grip', 'ti-stretching'),
  (w4, 2, 'Pull-ups', 5, '6-8', '—', 90, 'Mixed grip', 'ti-arrow-up'),
  (w4, 3, 'Farmers Walk', 4, '30m', '30 each', 90, 'Grip · core · posture', 'ti-grip'),
  (w4, 4, 'Dumbbell Row', 4, '8 each', '25', 75, 'Heavy · controlled', 'ti-arrow-down'),
  (w4, 5, 'Towel Hang', 3, '30s', '—', 75, 'Grip endurance', 'ti-grip'),
  (w4, 6, 'Hanging Leg Raise', 3, '10', '—', 60, 'Strict form', 'ti-arrow-up');

end $$;

-- Add the remaining sports as simpler programs (1 default workout each for now — can be expanded)
-- This way users can still select them in onboarding even if programs are minimal

insert into programs (name, sport, level, days_per_week, duration_weeks, description, icon) values
  ('Gymnastics Foundation', 'Gymnastics', 'beginner', 3, 12, 'Strength, flexibility, and body control', 'ti-stretching'),
  ('Rock Climbing Strength', 'Rock Climbing', 'beginner', 3, 12, 'Grip, pulling power, and finger strength', 'ti-mountain'),
  ('Equestrian Performance', 'Equestrian', 'beginner', 3, 12, 'Core stability, balance, and leg strength for riding', 'ti-horse-toy'),
  ('Strongman Training', 'Strongman', 'intermediate', 4, 12, 'Maximal strength and event-specific power', 'ti-barbell'),
  ('Glíma Wrestling', 'Glíma', 'intermediate', 4, 12, 'Grip, hip mobility, and rotational strength for Icelandic wrestling', 'ti-karate'),
  ('Badminton Performance', 'Badminton', 'beginner', 3, 12, 'Lateral quickness, shoulder power, and footwork', 'ti-trophy'),
  ('Skiing & Snowboarding', 'Winter Sports', 'beginner', 3, 12, 'Leg endurance, balance, and core for the slopes', 'ti-ski-jumping');

-- Done! 18 sports total now available


-- ============================================================
-- 06_migration_v6_general_athletic.sql
-- ============================================================

-- ÍslandFit v6 — General Athletic Performance (4-pillar balanced)
-- Adds a well-rounded "General" program covering all four athletic pillars:
--   Strength · Explosiveness · Speed · Endurance
-- Run in Supabase SQL Editor AFTER migration_v5_iceland_sports.sql. Safe to re-run (guarded).

do $$
declare
  p_general uuid := gen_random_uuid();
  w1 uuid; w2 uuid; w3 uuid; w4 uuid;
begin
  -- Idempotency guard: do not duplicate on re-run
  if exists (select 1 from programs where name = 'Athletic Performance' and sport = 'General') then
    raise notice 'Athletic Performance (General) already exists — skipping.';
    return;
  end if;

  insert into programs (id, name, sport, level, days_per_week, duration_weeks, description, icon) values
    (p_general, 'Athletic Performance', 'General', 'intermediate', 4, 12,
     'Balanced 4-pillar athletic development — strength, explosiveness, speed, and endurance in one week', 'ti-bolt');

  w1 := gen_random_uuid(); w2 := gen_random_uuid(); w3 := gen_random_uuid(); w4 := gen_random_uuid();
  insert into program_workouts (id, program_id, day_number, title, focus, estimated_min) values
    (w1, p_general, 1, 'Lower Strength & Power', 'Strength · Explosiveness', 55),
    (w2, p_general, 2, 'Upper Strength & Power', 'Strength · Explosiveness', 50),
    (w3, p_general, 3, 'Speed & Agility',        'Speed · Power',            45),
    (w4, p_general, 4, 'Conditioning & Core',    'Endurance · Engine',       40);

  -- DAY 1 — Lower Strength & Power (strength + explosive lower body)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w1, 1, 'Dynamic Warm-up',     1, '8 min',  '—',   30,  'Hips · ankles · A-skips · build-ups',          'ti-stretching'),
    (w1, 2, 'Back Squat',          4, '5',      '80',  150, 'Brace · sit between the hips · drive up',       'ti-barbell'),
    (w1, 3, 'Trap Bar Deadlift',   3, '4',      '100', 150, 'Flat back · push the floor away',              'ti-barbell'),
    (w1, 4, 'Box Jump',            4, '4',      '—',   90,  'Explode up · full hip extension · land soft',   'ti-arrow-up'),
    (w1, 5, 'Walking Lunge',       3, '8 each', '20',  75,  'Long stride · tall torso · knee over toe',      'ti-walk'),
    (w1, 6, 'Pogo Hops',           3, '15',     '—',   45,  'Stiff ankles · minimal ground contact time',    'ti-bolt');

  -- DAY 2 — Upper Strength & Power (strength + explosive upper body)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w2, 1, 'Dynamic Warm-up',     1, '6 min',   '—',  30,  'Band pull-aparts · shoulder circles',          'ti-stretching'),
    (w2, 2, 'Bench Press',         4, '5',       '70', 150, 'Tuck elbows · drive the feet · control down',   'ti-barbell'),
    (w2, 3, 'Push Press',          4, '3',       '50', 120, 'Dip-drive from the legs · punch overhead',      'ti-arrow-up'),
    (w2, 4, 'Weighted Pull-up',    4, '6',       '10', 120, 'Full hang · lead with the chest',              'ti-arrow-up'),
    (w2, 5, 'Med Ball Chest Pass', 4, '5',       '—',  75,  'Explosive throw · full extension',             'ti-bolt'),
    (w2, 6, 'Dumbbell Row',        3, '10 each', '28', 60,  'Flat back · pull to the hip',                  'ti-barbell'),
    (w2, 7, 'Hanging Knee Raise',  3, '12',      '—',  45,  'Control the swing · brace the core',           'ti-activity');

  -- DAY 3 — Speed & Agility (the speed pillar)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w3, 1, 'Dynamic Warm-up',     1, '8 min',  '—', 30,  'Leg swings · A/B skips · progressive build-ups', 'ti-stretching'),
    (w3, 2, 'Sprint Intervals',    6, '30 m',   '—', 120, 'Max effort · full recovery between reps',         'ti-run'),
    (w3, 3, 'A-Skips',             3, '20 m',   '—', 60,  'Tall posture · drive the knee · quick contact',   'ti-run'),
    (w3, 4, 'Lateral Bounds',      4, '6 each', '—', 75,  'Push off the outside leg · stick the landing',    'ti-bolt'),
    (w3, 5, '5-10-5 Pro Agility',  5, '1 rep',  '—', 90,  'Low hips · plant hard · explode out of the cut',  'ti-target-arrow'),
    (w3, 6, 'Single-Leg Hops',     3, '8 each', '—', 60,  'Soft landings · stable knee · rhythmic',          'ti-bolt'),
    (w3, 7, 'Hip Mobility Flow',   1, '5 min',  '—', 0,   'Slow breathing · open the hips · cool down',      'ti-stretching');

  -- DAY 4 — Conditioning & Core (the endurance pillar)
  insert into program_exercises (workout_id, order_idx, exercise_name, sets, reps, target_weight, rest_seconds, cues, icon) values
    (w4, 1, 'Warm-up Row/Bike',     1, '5 min',          '—', 30, 'Easy build until you break a sweat',      'ti-activity'),
    (w4, 2, 'Interval Conditioning',8, '30s on/30s off', '—', 30, 'Row · bike · or run · hard work efforts', 'ti-heart'),
    (w4, 3, 'Kettlebell Swing',     4, '15',             '24',60, 'Hip snap · brace · float the bell',       'ti-flame'),
    (w4, 4, 'Goblet Squat',         3, '12',             '20',45, 'Upright chest · controlled · steady pace','ti-barbell'),
    (w4, 5, 'Push-up',              3, '15',             '—', 45, 'Tight core · full range of motion',       'ti-activity'),
    (w4, 6, 'Plank',                3, '45s',            '—', 45, 'Straight line · brace hard · breathe',    'ti-activity'),
    (w4, 7, 'Cooldown Walk',        1, '5 min',          '—', 0,  'Nasal breathing · let the heart settle',  'ti-walk');

  raise notice 'Added Athletic Performance (General) — 4 balanced days.';
end $$;


-- ============================================================
-- 07_migration_v7_sport_programs_batch1.sql
-- ============================================================

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


-- ============================================================
-- 08_migration_v8_sport_programs_batch2.sql
-- ============================================================

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


-- ============================================================
-- 09_migration_v9_sport_programs_batch3.sql
-- ============================================================

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


-- ============================================================
-- 10_migration_v10_sport_programs_batch4.sql
-- ============================================================

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


-- ============================================================
-- 11_fix_crossfit_casing.sql
-- ============================================================

-- ────────────────────────────────────────────────────────
-- 11: NORMALIZE CrossFit CASING (data fix-up)
-- ────────────────────────────────────────────────────────
-- Earlier seed migrations inserted the sport under two spellings:
--   02_programs_migration.sql  → 'Crossfit'  (legacy, now corrected in-place)
--   03 / 09 batches            → 'CrossFit'  (canonical, matches islandfit.html)
-- The onboarding sport list is built from distinct programs.sport values
-- (islandfit.html ~line 1389: [...new Set(allPrograms.map(p => p.sport))]),
-- so two spellings produced two duplicate "CrossFit" tiles.
--
-- This script is idempotent: re-running it is a no-op once rows are normalized.
-- Run it in the Supabase SQL editor against your existing data.

-- Canonical seed-data table (source of the duplicate tiles):
update programs set sport = 'CrossFit' where sport = 'Crossfit';

-- Users who already picked the lowercase tile, plus their logged workouts,
-- so their selected sport keeps matching a real program after normalization:
update profiles set sport = 'CrossFit' where sport = 'Crossfit';
update workouts set sport = 'CrossFit' where sport = 'Crossfit';

-- Verify (optional): should return only 'CrossFit', never 'Crossfit'
-- select distinct sport from programs where sport ilike 'crossfit';
