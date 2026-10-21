DROP POLICY IF EXISTS "Admins can read all programs" ON public.programs;
CREATE POLICY "Admins can read all programs"
ON public.programs FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND lower(p.role) IN ('admin', 'administrateur')
  )
);
