-- JWT configuration for Supabase
-- Sets up app.settings for JWT validation in PostgREST

BEGIN;

-- Set application settings for JWT
DO $$
DECLARE
    jwt_secret TEXT := current_setting('app.settings.jwt_secret', true);
    jwt_exp TEXT := current_setting('app.settings.jwt_exp', true);
BEGIN
    -- These will be set by environment variables at runtime
    -- This file ensures the settings exist
    IF jwt_secret IS NULL THEN
        PERFORM set_config('app.settings.jwt_secret', 'your-jwt-secret', false);
    END IF;
    
    IF jwt_exp IS NULL THEN
        PERFORM set_config('app.settings.jwt_exp', '3600', false);
    END IF;
END
$$;

COMMIT;
