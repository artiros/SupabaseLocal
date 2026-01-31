-- Add ai_analysis column to activities table
ALTER TABLE activities ADD COLUMN IF NOT EXISTS ai_analysis TEXT;
