create policy "Admins can read all programs"
on public.programs for select to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and lower(p.role) in ('admin', 'administrateur')
  )
);