-- Allow pre-login connectivity checks and public programme discovery.
-- RLS still restricts these rows to explicitly published content.
grant select on public.programs, public.replay_items to anon;

drop policy if exists "Published programs are publicly readable" on public.programs;
create policy "Published programs are publicly readable"
  on public.programs for select to anon
  using (is_published = true);

drop policy if exists "Published replays are publicly readable" on public.replay_items;
create policy "Published replays are publicly readable"
  on public.replay_items for select to anon
  using (is_published = true);
