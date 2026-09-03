-- 21: target_weight must hold a LOAD or an em dash — nothing else.
--
-- Found by running a real workout end to end: a Single Leg Box Jump produced a
-- personal record of "20 kg × 4". The column held '24in', and finishWorkout()
-- does parseFloat(target_weight), which happily returns 24 — so a box HEIGHT was
-- stored as a load, counted toward volume, and fed into the e1RM history that
-- getPrescription() uses to pick future weights.
--
-- The '% 1RM' rows were worse and were my own: migration 18 wrote '85% 1RM' into
-- Advanced Strength & Power, which parseFloat reads as 85, so the app prescribed
-- a flat 85 kg instead of 85 percent of the athlete's max.
--
-- Both meanings belong in cues. With target_weight = '—' the app falls back to
-- its own NSCA + phase %1RM model, which is exactly what those rows intended.

update program_exercises e
   set cues = regexp_replace(e.target_weight, '\s*1RM$', '') || ' of your 1RM · ' || e.cues,
       target_weight = '—'
 where e.target_weight ~ '1RM$';

update program_exercises e
   set cues = e.cues || ' · ' || e.target_weight || ' box',
       target_weight = '—'
 where e.target_weight ~ '^[0-9]+in$';

-- Left alone deliberately: '4kg'/'5kg' medicine balls really are that load, and
-- '25 each' on a farmer's carry is 25 kg per hand, which parses correctly.
