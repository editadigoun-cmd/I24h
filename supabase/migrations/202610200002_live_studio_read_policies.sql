-- Permit authenticated live staff to review prayer requests in the studio.
-- Donations remain restricted to administrators for financial privacy.
drop policy if exists "Live staff can read prayer intentions" on public.prayer_intentions;
create policy "Live staff can read prayer intentions"
  on public.prayer_intentions for select to authenticated
  using (
    exists (
      select 1 from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'animateur')
    )
  );

drop policy if exists "Administrators can read donation records" on public.donations;
create policy "Administrators can read donation records"
  on public.donations for select to authenticated
  using (
    exists (
      select 1 from public.profiles p
      where p.id = (select auth.uid())
        and p.role = 'admin'
    )
  );
