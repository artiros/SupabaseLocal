-- Post-Boot Setup: Storage Buckets and Policies
-- Run this AFTER all Supabase services are healthy (Auth, Storage, etc.)
-- This script creates storage buckets and policies that depend on storage.buckets/objects tables

-- 1. AVATARS BUCKET
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 2. AVATAR STORAGE POLICIES
DO $$ BEGIN
  CREATE POLICY "Public Avatar Access"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Users can upload avatars"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Users can update avatars"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Users can delete avatars"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
