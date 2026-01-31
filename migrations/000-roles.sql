-- Supabase roles configuration
-- Creates all required PostgreSQL roles for Supabase services

-- Create extension for passwords
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create roles
DO $$
BEGIN
    -- anon role for unauthenticated access
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN NOINHERIT;
    END IF;

    -- authenticated role for logged-in users
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN NOINHERIT;
    END IF;

    -- service_role for server-side operations
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
    END IF;

    -- supabase_admin for admin operations
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin LOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
    END IF;

    -- supabase_auth_admin for auth service
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN PASSWORD 'CHANGE_ME';
    END IF;

    -- supabase_storage_admin for storage service
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_storage_admin') THEN
        CREATE ROLE supabase_storage_admin NOINHERIT LOGIN PASSWORD 'CHANGE_ME';
    END IF;

    -- authenticator role for PostgREST
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'CHANGE_ME';
    END IF;
END
$$;

-- Set passwords (use POSTGRES_PASSWORD from env)
ALTER ROLE supabase_admin WITH PASSWORD 'REPLACE_ME_PASSWORD';
ALTER ROLE supabase_auth_admin WITH PASSWORD 'REPLACE_ME_PASSWORD';
ALTER ROLE supabase_storage_admin WITH PASSWORD 'REPLACE_ME_PASSWORD';
ALTER ROLE authenticator WITH PASSWORD 'REPLACE_ME_PASSWORD';

-- Grant role memberships
GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;
GRANT supabase_admin TO authenticator;

-- Grant permissions on public schema
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

-- Set default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO anon, authenticated, service_role;

-- Grant to service accounts
GRANT ALL ON SCHEMA public TO supabase_admin, supabase_auth_admin, supabase_storage_admin;
