-- IslandFit v16 - coach memory fields
-- Lets the AI coach remember injuries + freeform notes across every session (otherwise it
-- re-meets you each time). 'injuries' is auto-filled by AI onboarding; 'coach_notes' is the
-- editable "anything your coach should know" field in Settings. Both are fed into every AI call.
-- Pure ASCII, idempotent. Run in Supabase SQL Editor anytime.
alter table profiles add column if not exists injuries text;
alter table profiles add column if not exists coach_notes text;
