-- Migration: add profiles table for user data and Strava tokens
-- Safe to run multiple times due to IF NOT EXISTS

CREATE TABLE IF NOT EXISTS public.profiles (
  email text PRIMARY KEY,
  name text,
  dob text,
  weight numeric,
  strava_enabled boolean DEFAULT false,
  strava_access_token text,
  strava_refresh_token text,
  strava_token_expiry bigint,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  EXECUTE 'DROP POLICY IF EXISTS "anon can read profiles" ON public.profiles';
  EXECUTE 'DROP POLICY IF EXISTS "anon can upsert profiles" ON public.profiles';
  EXECUTE 'DROP POLICY IF EXISTS "anon can update profiles" ON public.profiles';
EXCEPTION WHEN others THEN NULL; END $$;

-- Keep policies idempotent
DO $$ BEGIN
  CREATE POLICY "anon can read profiles" ON public.profiles FOR SELECT TO anon USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "anon can upsert profiles" ON public.profiles FOR INSERT TO anon WITH CHECK (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "anon can update profiles" ON public.profiles FOR UPDATE TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN others THEN NULL; END $$;
