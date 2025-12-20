-- Supabase internal database setup
-- Creates the _supabase database for analytics and internal services

BEGIN;

-- Create _supabase schema for internal use
CREATE SCHEMA IF NOT EXISTS _supabase;

-- Grant permissions to supabase_admin
GRANT ALL ON SCHEMA _supabase TO supabase_admin;

-- Create _analytics schema for logflare
CREATE SCHEMA IF NOT EXISTS _analytics;

-- Grant permissions
GRANT ALL ON SCHEMA _analytics TO supabase_admin;
GRANT USAGE ON SCHEMA _analytics TO postgres;

COMMIT;
