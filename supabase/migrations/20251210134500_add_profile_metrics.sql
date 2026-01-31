ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS ftp_value INTEGER DEFAULT 200,
ADD COLUMN IF NOT EXISTS threshold_pace INTEGER, -- Seconds per km
ADD COLUMN IF NOT EXISTS manual_override BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS last_estimated_date TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN profiles.ftp_value IS 'Functional Threshold Power in Watts';
COMMENT ON COLUMN profiles.threshold_pace IS 'Threshold running pace in seconds per kilometer';
