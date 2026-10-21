alter table public.programs
  add constraint programs_valid_slot
  check (ends_at is null or ends_at > starts_at);

create index if not exists programs_published_schedule_idx
  on public.programs (starts_at, ends_at)
  where is_published = true;

create policy "Admins can insert programs"
on public.programs for insert to authenticated
with check (
  exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and lower(p.role) in ('admin', 'administrateur')
  )
);

create policy "Admins can update programs"
on public.programs for update to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and lower(p.role) in ('admin', 'administrateur')
  )
)
with check (
  exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and lower(p.role) in ('admin', 'administrateur')
  )
);

create policy "Admins can delete programs"
on public.programs for delete to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and lower(p.role) in ('admin', 'administrateur')
  )
);

create policy "Admins can read all programs"
on public.programs for select to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and lower(p.role) in ('admin', 'administrateur')
  )
);
