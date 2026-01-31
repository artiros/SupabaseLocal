-- Migration: Global Admin Settings
-- 1. Add is_admin to profiles
-- 2. Create system_settings table
-- 3. Setup RLS for system_settings

-- 1. Add is_admin to profiles
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_admin') THEN
    ALTER TABLE public.profiles ADD COLUMN is_admin boolean DEFAULT false;
  END IF;
END $$;

-- 2. Create system_settings table
CREATE TABLE IF NOT EXISTS public.system_settings (
    key text PRIMARY KEY,
    value jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_by uuid REFERENCES public.profiles(user_id)
);

-- 3. Enable RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read settings (needed for app to function)
CREATE POLICY "Enable read access for all users" ON public.system_settings
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Policy: Only admins can insert/update/delete
CREATE POLICY "Enable write access for admins only" ON public.system_settings
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.user_id = auth.uid()
            AND profiles.is_admin = true
        )
    );

-- Grant access to authenticated users
GRANT SELECT ON public.system_settings TO authenticated;
GRANT ALL ON public.system_settings TO service_role;
