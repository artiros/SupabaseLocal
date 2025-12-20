-- Realtime configuration for Supabase
-- This file sets up the realtime schema and extensions

BEGIN;

-- Create realtime schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Grant permissions
GRANT USAGE ON SCHEMA _realtime TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA _realtime TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA _realtime TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA _realtime TO postgres, anon, authenticated, service_role;

-- Set default privileges
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA _realtime GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA _realtime GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA _realtime GRANT ALL ON ROUTINES TO postgres, anon, authenticated, service_role;

COMMIT;
