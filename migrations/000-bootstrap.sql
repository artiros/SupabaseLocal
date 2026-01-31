-- Supabase Unified Bootstrap Script
-- This script handles Roles, Schemas, Extensions, and Core Functions in one pass.
-- It is designed to be extremely robust and ignore minor idempotent errors.

-- 1. EXTENSIONS
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "vector" SCHEMA extensions;

-- 2. ROLES (Created independently with error handling)
DO $$ BEGIN
    CREATE ROLE anon NOLOGIN NOINHERIT;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role anon already exists'; END $$;

DO $$ BEGIN
    CREATE ROLE authenticated NOLOGIN NOINHERIT;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role authenticated already exists'; END $$;

DO $$ BEGIN
    CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role service_role already exists'; END $$;

DO $$ BEGIN
    CREATE ROLE supabase_admin LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role supabase_admin already exists'; END $$;

DO $$ BEGIN
    CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role supabase_auth_admin already exists'; END $$;

DO $$ BEGIN
    CREATE ROLE supabase_storage_admin NOINHERIT LOGIN;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role supabase_storage_admin already exists'; END $$;

DO $$ BEGIN
    CREATE ROLE authenticator NOINHERIT LOGIN;
EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'role authenticator already exists'; END $$;

-- 3. ROLE PASSWORDS & MEMBERSHIPS (Linear execution)
-- These use the password injected by the deployment script
ALTER ROLE supabase_admin WITH PASSWORD 'REPLACE_ME_PASSWORD';
ALTER ROLE supabase_auth_admin WITH PASSWORD 'REPLACE_ME_PASSWORD';
ALTER ROLE supabase_storage_admin WITH PASSWORD 'REPLACE_ME_PASSWORD';
ALTER ROLE authenticator WITH PASSWORD 'REPLACE_ME_PASSWORD';

GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;
GRANT supabase_admin TO authenticator;

-- 4. SCHEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS _supabase;
CREATE SCHEMA IF NOT EXISTS _analytics;
CREATE SCHEMA IF NOT EXISTS _realtime;

-- 5. SEARCH PATH
SET search_path TO public, auth, storage, extensions;

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

-- 8. PERMISSIONS
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;

GRANT ALL ON SCHEMA public TO supabase_admin;
GRANT ALL ON SCHEMA auth TO supabase_admin, supabase_auth_admin;
GRANT ALL ON SCHEMA storage TO supabase_admin, supabase_storage_admin;

GRANT ALL ON ALL TABLES IN SCHEMA auth TO supabase_admin, supabase_auth_admin;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO supabase_admin, supabase_storage_admin;
