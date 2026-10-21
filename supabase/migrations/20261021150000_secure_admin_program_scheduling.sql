DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'programs_valid_slot'
      AND conrelid = 'public.programs'::regclass
  ) THEN
    ALTER TABLE public.programs
      ADD CONSTRAINT programs_valid_slot
      CHECK (ends_at IS NULL OR ends_at > starts_at);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS programs_published_schedule_idx
  ON public.programs (starts_at, ends_at)
  WHERE is_published = true;

DROP POLICY IF EXISTS "Admins can insert programs" ON public.programs;
CREATE POLICY "Admins can insert programs"
ON public.programs FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND lower(p.role) IN ('admin', 'administrateur')
  )
);

DROP POLICY IF EXISTS "Admins can update programs" ON public.programs;
CREATE POLICY "Admins can update programs"
ON public.programs FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND lower(p.role) IN ('admin', 'administrateur')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND lower(p.role) IN ('admin', 'administrateur')
  )
);

DROP POLICY IF EXISTS "Admins can delete programs" ON public.programs;
CREATE POLICY "Admins can delete programs"
ON public.programs FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND lower(p.role) IN ('admin', 'administrateur')
  )
);
