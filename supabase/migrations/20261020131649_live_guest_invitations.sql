create table if not exists public.live_guest_invitations (
  id uuid primary key default gen_random_uuid(),
  invited_by uuid not null references auth.users(id) on delete cascade,
  invited_email text not null,
  invited_name text not null,
  invite_code text not null unique,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  accepted_by uuid references auth.users(id) on delete set null,
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.live_guest_invitations enable row level security;

drop policy if exists "Staff can create live guest invitations" on public.live_guest_invitations;
create policy "Staff can create live guest invitations"
on public.live_guest_invitations
for insert
to authenticated
with check (
  invited_by = auth.uid()
  and exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and lower(coalesce(p.role, '')) in ('admin', 'administrateur', 'animateur')
  )
);

drop policy if exists "Staff can view live guest invitations" on public.live_guest_invitations;
create policy "Staff can view live guest invitations"
on public.live_guest_invitations
for select
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and lower(coalesce(p.role, '')) in ('admin', 'administrateur', 'animateur')
  )
);

revoke all on public.live_guest_invitations from anon;
grant select, insert on public.live_guest_invitations to authenticated;

create or replace function public.consume_live_guest_invitation(
  p_invite_code text,
  p_participant_id uuid,
  p_participant_email text
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  invitation public.live_guest_invitations%rowtype;
begin
  if auth.uid() is null or auth.uid() <> p_participant_id then
    return false;
  end if;

  select *
  into invitation
  from public.live_guest_invitations
  where invite_code = p_invite_code
    and lower(invited_email) = lower(coalesce(p_participant_email, ''))
    and expires_at > now()
  limit 1;

  if not found then
    return false;
  end if;

  if invitation.accepted_by is not null
     and invitation.accepted_by <> p_participant_id then
    return false;
  end if;

  update public.live_guest_invitations
  set accepted_by = p_participant_id,
      accepted_at = coalesce(accepted_at, now())
  where id = invitation.id;

  return true;
end;
$$;

revoke all on function public.consume_live_guest_invitation(text, uuid, text) from public;
grant execute on function public.consume_live_guest_invitation(text, uuid, text) to authenticated;
