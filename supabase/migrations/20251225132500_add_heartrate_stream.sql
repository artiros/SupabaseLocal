-- Add heartrate_over_time column to activities table
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS heartrate_over_time JSONB DEFAULT NULL;

-- Comment on column
COMMENT ON COLUMN activities.heartrate_over_time IS 'Array of {time, heartrate} objects from Strava stream';
