-- Webhooks configuration for Supabase
-- Sets up database webhooks functionality

BEGIN;

-- Create the supabase_functions schema for webhooks
CREATE SCHEMA IF NOT EXISTS supabase_functions;

-- Create http extension if it doesn't exist (for webhooks)
CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA extensions;

-- Create pg_net extension for async HTTP requests
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Grant permissions
GRANT USAGE ON SCHEMA supabase_functions TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA supabase_functions TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA supabase_functions TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA supabase_functions TO postgres, anon, authenticated, service_role;

COMMIT;
