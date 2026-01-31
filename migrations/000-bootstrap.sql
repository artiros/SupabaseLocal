-- Supabase Bootstrap (Universal Compatibility Version)
-- This script sets up the core Supabase environment.

-- 1. EXTENSIONS
CREATE SCHEMA IF NOT EXISTS extensions;
DO $$ BEGIN CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA extensions; EXCEPTION WHEN OTHERS THEN NULL; END $$;
DO $$ BEGIN CREATE EXTENSION IF NOT EXISTS "vector" SCHEMA extensions; EXCEPTION WHEN OTHERS THEN NULL; END $$;

-- 2. ROLES
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN CREATE ROLE anon NOLOGIN NOINHERIT; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN CREATE ROLE authenticated NOLOGIN NOINHERIT; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN CREATE ROLE supabase_admin LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_auth_admin') THEN CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_storage_admin') THEN CREATE ROLE supabase_storage_admin NOINHERIT LOGIN; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') THEN CREATE ROLE authenticator NOINHERIT LOGIN; END IF;
END $$;

-- 3. PASSWORDS (The deployment script will replace the placeholder below)
ALTER ROLE supabase_admin WITH PASSWORD 'DB_PASSWORD_PLACEHOLDER';
ALTER ROLE supabase_auth_admin WITH PASSWORD 'DB_PASSWORD_PLACEHOLDER';
ALTER ROLE supabase_storage_admin WITH PASSWORD 'DB_PASSWORD_PLACEHOLDER';
ALTER ROLE authenticator WITH PASSWORD 'DB_PASSWORD_PLACEHOLDER';

-- 4. MEMBERSHIPS
GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;
GRANT supabase_admin TO authenticator;

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

-- 7. PERMISSIONS
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;
GRANT ALL ON SCHEMA public TO supabase_admin;
GRANT ALL ON SCHEMA auth TO supabase_admin, supabase_auth_admin;
GRANT ALL ON SCHEMA storage TO supabase_admin, supabase_storage_admin;
