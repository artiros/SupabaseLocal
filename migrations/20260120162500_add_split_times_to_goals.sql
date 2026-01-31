ALTER TABLE goals
ADD COLUMN IF NOT EXISTS swim_time_seconds integer,
ADD COLUMN IF NOT EXISTS bike_time_seconds integer,
ADD COLUMN IF NOT EXISTS run_time_seconds integer;
