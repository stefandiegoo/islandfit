-- 32: account deletion was killed by a platform change.
--
-- delete_my_account() ended with
--
--   delete from storage.objects
--     where bucket_id in ('form-checks','progress-photos') and ...
--
-- Supabase now refuses direct DML on the storage schema:
--
--   403  Direct deletion from storage tables is not allowed.
--        Use the Storage API instead.
--
-- Because that statement sits inside the function, the refusal aborts the whole
-- call and NOTHING is deleted — not the account, not the training history, not
-- the messages. The "Eyða reikningi og öllum gögnum" button in Settings has
-- been dead since the platform changed, and it fails loudly for the user but
-- silently for us: nobody tests deleting their own account twice.
--
-- This is the GDPR right-to-erasure path and privacy.html promises it, so it
-- matters more than its size suggests.
--
-- The fix is a deletion, not an addition: the app ALREADY removes the files
-- through the Storage API before it calls this function (see deleteMyAccount()
-- in islandfit.html, which lists and removes both buckets first). The SQL copy
-- was belt-and-braces that the platform turned into a blocker. Everything else
-- in the function is untouched.
--
-- Found by the account-deletion path refusing to run during a full test pass.

create or replace function delete_my_account()
returns void language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'not signed in'; end if;

  delete from coach_workout_notes where coach_id = uid;
  delete from coach_workout_templates where coach_id = uid;
  delete from group_messages where sender_id = uid;
  delete from nutrition_targets where set_by = uid or client_id = uid;
  update coach_applications set reviewed_by = null where reviewed_by = uid;
  update profiles set program_id = null
    where program_id in (select id from programs where created_by = uid);
  delete from programs where created_by = uid and coalesce(is_custom,false) = true;
  update programs set created_by = null where created_by = uid;

  -- Storage objects are removed by the client through the Storage API before
  -- this is called. Deleting them here is refused by the platform and would
  -- abort the whole erasure.

  delete from auth.users where id = uid;
end $$;

grant execute on function public.delete_my_account() to authenticated;
revoke execute on function public.delete_my_account() from public, anon;
