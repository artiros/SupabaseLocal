-- Add avatar_url column to profiles table
-- NOTE: Storage bucket creation moved to post-boot.sql (runs after Storage service is initialized)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url text;
