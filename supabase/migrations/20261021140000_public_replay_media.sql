-- Published replays are public content and must play for visitors without an account.
-- The bucket stays private; Storage issues short-lived signed URLs only for published media.
drop policy if exists "Public can read published replay media" on storage.objects;
create policy "Public can read published replay media"
  on storage.objects for select to anon
  using (
    bucket_id = 'i24h-replays'
    and exists (
      select 1 from public.replay_items r
      where r.media_path = storage.objects.name
        and r.is_published = true
    )
  );
