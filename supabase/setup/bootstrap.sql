-- Supabase Unified Bootstrap Script (Lightweight Version)
-- This script handles the essential Roles and Schemas required for the services to connect.

-- 1. EXTENSIONS SCHEMA
CREATE SCHEMA IF NOT EXISTS extensions;
-- Let Postgres/Supabase handle the schema for these by default to avoid friction
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";
ALTER DATABASE postgres SET search_path TO public, extensions, auth;

-- 2. ROLES (Atomic creation blocks)
DO $$ BEGIN CREATE ROLE anon NOLOGIN NOINHERIT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE authenticated NOLOGIN NOINHERIT; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE supabase_admin LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE supabase_storage_admin NOINHERIT LOGIN; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE ROLE authenticator NOINHERIT LOGIN; EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 3. ROLE PASSWORDS
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

-- 6. FUNCTIONS (Directly used by RLS)
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION auth.role() RETURNS text LANGUAGE sql STABLE AS $$
  select nullif(current_setting('request.jwt.claim.role', true), '')::text;
$$;

-- 7. PERMISSIONS
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;
GRANT ALL ON SCHEMA public TO supabase_admin;
GRANT ALL ON SCHEMA auth TO supabase_admin, supabase_auth_admin;
GRANT ALL ON SCHEMA storage TO supabase_admin, supabase_storage_admin;

GRANT EXECUTE ON FUNCTION auth.uid() TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION auth.role() TO anon, authenticated, service_role;
