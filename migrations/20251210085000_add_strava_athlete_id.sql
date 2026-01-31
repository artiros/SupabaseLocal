-- Migration: Add strava_athlete_id to profiles for webhook mapping
-- Date: 2025-12-10

DO $$ BEGIN
    ALTER TABLE public.profiles ADD COLUMN strava_athlete_id text;
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_profiles_strava_athlete_id ON public.profiles(strava_athlete_id);
