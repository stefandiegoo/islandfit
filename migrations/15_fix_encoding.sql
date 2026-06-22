-- IslandFit v15 - encoding repair (fixes MacRoman double-encoded mojibake from pasting into Supabase)
-- Reverses 4 sequences: U+201A,U+00C4,U+00EE -> em-dash | U+00AC,U+2211 -> middle-dot | U+00AC,U+221E -> degree | U+221A,U+2260 -> i-acute
-- 100% ASCII source (Postgres U&'\XXXX' unicode escapes) so it is IMMUNE to the same paste corruption.
-- Idempotent: once clean, the mojibake sequences are gone and every replace() is a no-op. Safe to re-run.

update programs set
  name = replace(replace(replace(replace(name,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED'),
  description = replace(replace(replace(replace(description,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED'),
  sport = replace(replace(replace(replace(sport,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED');

update program_workouts set
  title = replace(replace(replace(replace(title,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED'),
  focus = replace(replace(replace(replace(focus,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED');

update program_exercises set
  exercise_name = replace(replace(replace(replace(exercise_name,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED'),
  reps = replace(replace(replace(replace(reps,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED'),
  target_weight = replace(replace(replace(replace(target_weight,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED'),
  cues = replace(replace(replace(replace(cues,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED');

update profiles set
  sport = replace(replace(replace(replace(sport,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED');

update workouts set
  sport = replace(replace(replace(replace(sport,U&'\201A\00C4\00EE',U&'\2014'),U&'\00AC\2211',U&'\00B7'),U&'\00AC\221E',U&'\00B0'),U&'\221A\2260',U&'\00ED');
