-- Ensure activities table has correct RLS policies
ALTER TABLE IF EXISTS public.activities ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_select_own" ON public.activities;
  CREATE POLICY "activities_select_own" ON public.activities FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_insert_own" ON public.activities;
  CREATE POLICY "activities_insert_own" ON public.activities FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_update_own" ON public.activities;
  CREATE POLICY "activities_update_own" ON public.activities FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_delete_own" ON public.activities;
  CREATE POLICY "activities_delete_own" ON public.activities FOR DELETE USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;
