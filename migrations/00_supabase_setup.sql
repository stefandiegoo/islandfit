-- ÍslandFit — Supabase töflur
-- Keyrðu þetta í SQL Editor á supabase.com

-- 1. Notendaupplýsingar (profiles)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  sport text default 'Körfubolti',
  equipment text default 'Full gym',
  frequency int default 4,
  streak int default 0,
  created_at timestamp with time zone default now()
);

-- 2. Þjálfanir (workouts)
create table workouts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  title text not null,
  sport text,
  duration_min int,
  calories int,
  completed_at timestamp with time zone default now()
);

-- 3. Sett og þyngdartaka (sets)
create table workout_sets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  workout_id uuid references workouts(id) on delete cascade,
  exercise_name text not null,
  set_number int,
  reps int,
  weight_kg numeric,
  logged_at timestamp with time zone default now()
);

-- 4. Persónulegar metið (personal records)
create table personal_records (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) on delete cascade,
  exercise_name text not null,
  weight_kg numeric,
  reps int,
  achieved_at timestamp with time zone default now(),
  unique(user_id, exercise_name)
);

-- Leyfa notendum að lesa/skrifa eigin gögn (Row Level Security)
alter table profiles enable row level security;
alter table workouts enable row level security;
alter table workout_sets enable row level security;
alter table personal_records enable row level security;

create policy "Notendur sjá eigin profile" on profiles
  for all using (auth.uid() = id);

create policy "Notendur sjá eigin þjálfanir" on workouts
  for all using (auth.uid() = user_id);

create policy "Notendur sjá eigin sett" on workout_sets
  for all using (auth.uid() = user_id);

create policy "Notendur sjá eigin met" on personal_records
  for all using (auth.uid() = user_id);

-- Búa til profile sjálfkrafa þegar notandi skráir sig
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, name)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();
