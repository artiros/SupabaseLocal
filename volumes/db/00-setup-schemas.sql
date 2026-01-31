-- Initial setup for Supabase schemas
-- This creates the schemas that Gotrue and Storage expect
BEGIN;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS extensions;

-- Grant permissions to administrative roles
-- These roles are created in roles.sql, which runs as 99-roles.sql
-- We'll also grant them here in case roles exist
DO $$
BEGIN
    -- Grant to supabase_admin
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_admin') THEN
        GRANT ALL ON SCHEMA auth TO supabase_admin;
        GRANT ALL ON SCHEMA storage TO supabase_admin;
        GRANT ALL ON SCHEMA extensions TO supabase_admin;
    END IF;

    -- Grant to auth admin
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
    END IF;

    -- Grant to storage admin
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_storage_admin') THEN
        GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
    END IF;
END
$$;

COMMIT;
