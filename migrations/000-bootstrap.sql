-- Supabase Unified Bootstrap Script (Atomic Version)
-- This script handles Roles, Schemas, Extensions, and Core Functions.
-- Transactional integrity is broken into fragments for maximum resilience.

-- 1. EXTENSIONS
CREATE SCHEMA IF NOT EXISTS extensions;
SET search_path TO public, auth, storage, extensions;

-- Enable extensions (idempotent)
DO $$ BEGIN CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA extensions; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN CREATE EXTENSION IF NOT EXISTS "vector" SCHEMA extensions; EXCEPTION WHEN OTHERS THEN NULL; END $$;

-- 2. ROLES (Atomic creation blocks)
DO $$ BEGIN CREATE ROLE anon NOLOGIN NOINHERIT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE authenticated NOLOGIN NOINHERIT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE supabase_admin LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE supabase_storage_admin NOINHERIT LOGIN; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE authenticator NOINHERIT LOGIN; EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 3. ROLE PASSWORDS (Atomic update blocks)
DO $$ BEGIN EXECUTE format('ALTER ROLE supabase_admin WITH PASSWORD %L', :'db_pass'); EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN EXECUTE format('ALTER ROLE supabase_auth_admin WITH PASSWORD %L', :'db_pass'); EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN EXECUTE format('ALTER ROLE supabase_storage_admin WITH PASSWORD %L', :'db_pass'); EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN EXECUTE format('ALTER ROLE authenticator WITH PASSWORD %L', :'db_pass'); EXCEPTION WHEN OTHERS THEN NULL; END $$;

-- 4. MEMBERSHIPS
DO $$ BEGIN GRANT anon TO authenticator; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN GRANT authenticated TO authenticator; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN GRANT service_role TO authenticator; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN GRANT supabase_admin TO authenticator; EXCEPTION WHEN OTHERS THEN NULL; END $$;

-- 5. SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS _supabase;
CREATE SCHEMA IF NOT EXISTS _analytics;
CREATE SCHEMA IF NOT EXISTS _realtime;

-- 6. AUTH FUNCTIONS
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.role() RETURNS text AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.role', true), '')::text;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.email() RETURNS text AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.email', true), '')::text;
$$ LANGUAGE sql STABLE;

-- 7. CORE TABLES (Minimal definitions to satisfy foreign keys)
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid NOT NULL PRIMARY KEY,
  email text UNIQUE,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS storage.buckets (
  id text NOT NULL PRIMARY KEY,
  name text NOT NULL,
  owner uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  public boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS storage.objects (
  id uuid NOT NULL DEFAULT extensions.gen_random_uuid() PRIMARY KEY,
  bucket_id text REFERENCES storage.buckets(id),
  name text,
  owner uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_accessed_at timestamptz DEFAULT now(),
  metadata jsonb,
  path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED
);

-- 8. PERMISSIONS (Safe Grant Pattern)
DO $$
BEGIN
    -- Only grant if the role exists to avoid stopping the script
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
        GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
        GRANT ALL ON SCHEMA public TO supabase_admin;
        GRANT ALL ON SCHEMA auth TO supabase_admin, supabase_auth_admin;
        GRANT ALL ON SCHEMA storage TO supabase_admin, supabase_storage_admin;
        GRANT ALL ON ALL TABLES IN SCHEMA auth TO supabase_admin, supabase_auth_admin;
        GRANT ALL ON ALL TABLES IN SCHEMA storage TO supabase_admin, supabase_storage_admin;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Some permissions could not be granted: %', SQLERRM;
END
$$;
