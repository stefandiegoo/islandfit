-- 25: cancelling what was never accepted, and recalling what was sent.
--
-- Four things could be created but never undone:
--   * A client request sent to the wrong email sat 'pending' forever.
--   * A colleague invitation showed "invite sent" with no way to take it back.
--   * A client invite code could be generated but never revoked — so a code that
--     leaked stayed redeemable for its full 30 days with no way to kill it, and
--     the portal only ever showed the newest one, hiding the older live codes.
--   * An admin could read a coach application and approve or reject it, but not
--     delete it, so a rejected applicant could never get a clean slate.
--
-- RLS already allowed the first three (coach_clients and coach_peers are
-- deletable by either party, coach_invites by the owning coach), so those needed
-- interface rather than schema. Only the admin delete needs a function, because
-- admins deliberately hold SELECT on coach_applications and nothing more.

-- Withdraw a request the client never accepted. Scoped to 'pending' on purpose:
-- a mis-click must not be able to sever a live coaching relationship, which is
-- what the separate disconnect action is for.
create or replace function cancel_client_request(p_client uuid)
returns boolean language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  if auth.uid() is null then raise exception 'Not signed in'; end if;
  with gone as (
    delete from coach_clients
     where coach_id = auth.uid() and client_id = p_client and status = 'pending'
    returning 1)
  select count(*) into v_n from gone;
  return v_n > 0;
end $$;

-- Remove an application outright so the person can apply again from scratch.
-- Refuses on an approved coach: revoking someone's coaching status is a
-- different decision and belongs to the review function, not to a delete.
create or replace function admin_delete_coach_application(p_user uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'Admins only'; end if;
  if (select coach_status from profiles where id = p_user) = 'approved' then
    raise exception 'That coach is approved — reject the application first';
  end if;
  delete from coach_applications where user_id = p_user;
  update profiles set coach_status = null where id = p_user and coach_status <> 'approved';
end $$;

grant execute on function public.cancel_client_request(uuid) to authenticated;
grant execute on function public.admin_delete_coach_application(uuid) to authenticated;
revoke execute on function public.cancel_client_request(uuid) from public, anon;
revoke execute on function public.admin_delete_coach_application(uuid) from public, anon;
