-- 27: coach comments that point at a specific exercise.
--
-- A coach reading a client's session wants to say something about ONE lift, not
-- the workout as a whole. coach_workout_notes already covers the private
-- per-session note; this is the opposite — a message the athlete actually
-- receives, in the thread they already read, that still knows what it is about.
--
-- Rather than a second messaging table, a message simply carries an optional
-- reference. Threads stay one list, and a client with no reference renders
-- exactly as before.

alter table coach_messages add column if not exists ref_type  text
  check (ref_type is null or ref_type in ('exercise','workout'));
alter table coach_messages add column if not exists ref_id    uuid;
alter table coach_messages add column if not exists ref_label text;

create index if not exists coach_messages_ref_idx
  on coach_messages (client_id, ref_type) where ref_type is not null;

-- Post a comment about one exercise. The coach must actually coach this client;
-- coach_can_edit() is the same gate used everywhere else, so a read-only
-- co-coach cannot post.
create or replace function coach_comment_exercise(
  p_client uuid, p_body text, p_exercise text, p_workout uuid default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if not public.coach_can_edit(p_client) then
    raise exception 'You do not coach this athlete';
  end if;
  if coalesce(trim(p_body),'') = '' then raise exception 'The comment is empty'; end if;
  if coalesce(trim(p_exercise),'') = '' then raise exception 'Which exercise?'; end if;
  insert into coach_messages (coach_id, client_id, sender_id, body, ref_type, ref_id, ref_label)
    values (auth.uid(), p_client, auth.uid(), trim(p_body), 'exercise', p_workout, trim(p_exercise))
    returning id into v_id;
  return v_id;
end $$;

grant execute on function public.coach_comment_exercise(uuid,text,text,uuid) to authenticated;
revoke execute on function public.coach_comment_exercise(uuid,text,text,uuid) from public, anon;
