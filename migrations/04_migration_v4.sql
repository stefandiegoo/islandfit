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
