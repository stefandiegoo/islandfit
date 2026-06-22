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
