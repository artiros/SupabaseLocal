-- Logs configuration for Supabase Analytics
-- Sets up logging tables and functions for Logflare

BEGIN;

-- Ensure _analytics schema exists
CREATE SCHEMA IF NOT EXISTS _analytics;

-- Grant permissions
GRANT ALL ON SCHEMA _analytics TO supabase_admin;
GRANT USAGE ON SCHEMA _analytics TO postgres;

COMMIT;
