-- Supabase Core Setup Migration
-- This script ensures schemas, roles, and auth functions exist.
-- It is designed to be idempotent (safe to run multiple times).

BEGIN;

-- 1. Create essential Supabase schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE SCHEMA IF NOT EXISTS _supabase;
CREATE SCHEMA IF NOT EXISTS _analytics;
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Enable common extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA extensions;

-- Set search path to include extensions
ALTER DATABASE postgres SET search_path TO public, auth, storage, extensions;
SET search_path TO public, auth, storage, extensions;

-- 2. Create standard Supabase roles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN NOINHERIT;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN NOINHERIT;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_storage_admin') THEN
        CREATE ROLE supabase_storage_admin NOINHERIT LOGIN;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator NOINHERIT LOGIN;
    END IF;
END
$$;

-- 3. Setup core Auth functions (needed for RLS policies)
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.role() RETURNS text AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.role', true), '')::text;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.email() RETURNS text AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.email', true), '')::text;
$$ LANGUAGE sql STABLE;

-- 4. Create essential auth and storage tables (if they don't exist)
-- This satisfies foreign keys and inserts in upcoming migrations
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

-- 5. Grant base permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;

GRANT ALL ON SCHEMA public TO supabase_admin;
GRANT ALL ON SCHEMA auth TO supabase_admin, supabase_auth_admin;
GRANT ALL ON SCHEMA storage TO supabase_admin, supabase_storage_admin;

GRANT ALL ON ALL TABLES IN SCHEMA auth TO supabase_admin, supabase_auth_admin;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO supabase_admin, supabase_storage_admin;

COMMIT;
