-- Add threshold_hr to profiles
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS threshold_hr INTEGER;

-- Add heart rate fields to activities
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS average_heartrate FLOAT,
ADD COLUMN IF NOT EXISTS max_heartrate FLOAT;
