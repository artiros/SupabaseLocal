-- Add user location and coaching preferences for Meteo-Coach features
-- This migration adds columns for weather-based training adjustments

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS coaching_tone TEXT DEFAULT 'balanced' CHECK (coaching_tone IN ('supportive', 'balanced', 'data-driven'));

COMMENT ON COLUMN profiles.latitude IS 'User home location latitude for weather lookups';
COMMENT ON COLUMN profiles.longitude IS 'User home location longitude for weather lookups';
COMMENT ON COLUMN profiles.coaching_tone IS 'Preferred coaching tone for AI audio briefings';
