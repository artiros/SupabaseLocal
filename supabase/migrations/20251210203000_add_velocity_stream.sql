-- Add velocity and speed stream columns to activities
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS velocity_over_time JSONB,
ADD COLUMN IF NOT EXISTS speed_over_time JSONB;
