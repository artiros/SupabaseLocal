-- Add preferences_summary column to training_plans table
-- This replaces the complex constraints_json with a simple text summary
-- that the LLM can interpret directly during plan generation

ALTER TABLE training_plans 
ADD COLUMN IF NOT EXISTS preferences_summary TEXT;

-- Add comment explaining the field
COMMENT ON COLUMN training_plans.preferences_summary IS 'Plain text summary of training preferences (e.g., "5 days/week, swim Saturday, long run Sunday"). LLM interprets this during plan generation.';
