-- Recreate training_plan_sessions table to ensure correct schema and policies
DROP TABLE IF EXISTS public.training_plan_sessions CASCADE;

CREATE TABLE public.training_plan_sessions (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users NOT NULL,
  day_index integer,
  week_offset integer,
  type text,
  description text,
  minutes integer,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.training_plan_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can all on training_plan_sessions"
  ON public.training_plan_sessions FOR ALL
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_training_plan_sessions_user_id ON public.training_plan_sessions(user_id);
