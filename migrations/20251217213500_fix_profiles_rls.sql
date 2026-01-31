-- Migration: Fix profiles RLS for authenticated users
-- The profiles table only had policies for 'anon' role, not 'authenticated'
-- This caused authenticated users to not be able to read their own profile (including is_admin)

-- Add policy for authenticated users to read their own profile
DO $$ BEGIN
  CREATE POLICY "authenticated users read own profile" 
    ON public.profiles 
    FOR SELECT 
    TO authenticated 
    USING (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Add policy for authenticated users to update their own profile
DO $$ BEGIN
  CREATE POLICY "authenticated users update own profile" 
    ON public.profiles 
    FOR UPDATE 
    TO authenticated 
    USING (user_id = auth.uid()) 
    WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Add policy for authenticated users to insert their own profile
DO $$ BEGIN
  CREATE POLICY "authenticated users insert own profile" 
    ON public.profiles 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
