CREATE EXTENSION IF NOT EXISTS btree_gist;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'programs_no_overlapping_published_slots'
      AND conrelid = 'public.programs'::regclass
  ) THEN
    ALTER TABLE public.programs
      ADD CONSTRAINT programs_no_overlapping_published_slots
      EXCLUDE USING gist (
        tstzrange(starts_at, ends_at, '[)') WITH &&
      )
      WHERE (is_published = true AND ends_at IS NOT NULL);
  END IF;
END $$;