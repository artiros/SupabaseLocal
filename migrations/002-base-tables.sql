-- Complete schema for TriathlonHelper
-- Run this on a fresh database

-- Activities table
CREATE TABLE IF NOT EXISTS public.activities (
  id bigint PRIMARY KEY,
  user_id uuid NOT NULL,
  user_email text,
  name text NOT NULL,
  type text NOT NULL DEFAULT 'Other',
  distance integer DEFAULT 0,
  moving_time integer DEFAULT 0,
  start_date timestamptz NOT NULL,
  max_watts integer,
  average_watts integer,
  weighted_average_watts integer,
  max_watts_1min integer,
  max_watts_5min integer,
  max_watts_20min integer,
  watts_over_time jsonb,
  velocity_over_time jsonb,
  average_heartrate integer,
  max_heartrate integer,
  speed_over_time jsonb,
  pr_tags text DEFAULT '[]',
  training_load integer,
  intensity_factor numeric,
  variability_index numeric,
  zone_distribution jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own activities" ON public.activities;
CREATE POLICY "Users can view own activities" ON public.activities FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own activities" ON public.activities;
CREATE POLICY "Users can insert own activities" ON public.activities FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own activities" ON public.activities;
CREATE POLICY "Users can update own activities" ON public.activities FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own activities" ON public.activities;
CREATE POLICY "Users can delete own activities" ON public.activities FOR DELETE USING (auth.uid() = user_id);

-- Planned Activities table
CREATE TABLE IF NOT EXISTS public.planned_activities (
  id bigint PRIMARY KEY,
  user_id uuid NOT NULL,
  user_email text,
  name text NOT NULL,
  type text NOT NULL DEFAULT 'Other',
  planned_distance integer,
  planned_moving_time integer,
  planned_date date NOT NULL,
  notes text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.planned_activities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own planned_activities" ON public.planned_activities;
CREATE POLICY "Users can view own planned_activities" ON public.planned_activities FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own planned_activities" ON public.planned_activities;
CREATE POLICY "Users can insert own planned_activities" ON public.planned_activities FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own planned_activities" ON public.planned_activities;
CREATE POLICY "Users can update own planned_activities" ON public.planned_activities FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own planned_activities" ON public.planned_activities;
CREATE POLICY "Users can delete own planned_activities" ON public.planned_activities FOR DELETE USING (auth.uid() = user_id);

-- Goals table
CREATE TABLE IF NOT EXISTS public.goals (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL,
  user_email text,
  title text NOT NULL,
  category text NOT NULL,
  sport text NOT NULL,
  target_date date NOT NULL,
  race_id text,
  target_distance integer,
  target_time_seconds integer,
  notes text,
  swim_distance_m integer,
  bike_distance_m integer,
  run_distance_m integer,
  priority text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own goals" ON public.goals;
CREATE POLICY "Users can view own goals" ON public.goals FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own goals" ON public.goals;
CREATE POLICY "Users can insert own goals" ON public.goals FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own goals" ON public.goals;
CREATE POLICY "Users can update own goals" ON public.goals FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own goals" ON public.goals;
CREATE POLICY "Users can delete own goals" ON public.goals FOR DELETE USING (auth.uid() = user_id);

-- Goals Milestones table
CREATE TABLE IF NOT EXISTS public.goals_milestones (
  id bigserial PRIMARY KEY,
  user_id uuid NOT NULL,
  user_email text,
  goal_id bigint NOT NULL REFERENCES public.goals(id) ON DELETE CASCADE,
  label text NOT NULL,
  target_date date NOT NULL,
  target_distance integer,
  target_time_seconds integer,
  completed_at timestamptz,
  notes text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.goals_milestones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own milestones" ON public.goals_milestones;
CREATE POLICY "Users can view own milestones" ON public.goals_milestones FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own milestones" ON public.goals_milestones;
CREATE POLICY "Users can insert own milestones" ON public.goals_milestones FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own milestones" ON public.goals_milestones;
CREATE POLICY "Users can update own milestones" ON public.goals_milestones FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own milestones" ON public.goals_milestones;
CREATE POLICY "Users can delete own milestones" ON public.goals_milestones FOR DELETE USING (auth.uid() = user_id);

-- Races table (public)
CREATE TABLE IF NOT EXISTS public.races (
  source text NOT NULL,
  year integer NOT NULL,
  id text NOT NULL,
  name text NOT NULL,
  sport text NOT NULL,
  date date NOT NULL,
  distance_m integer,
  region text,
  raw jsonb,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (source, year, id)
);

ALTER TABLE public.races ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view races" ON public.races;
CREATE POLICY "Anyone can view races" ON public.races FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated can insert races" ON public.races;
CREATE POLICY "Authenticated can insert races" ON public.races FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated can update races" ON public.races;
CREATE POLICY "Authenticated can update races" ON public.races FOR UPDATE USING (true);

-- Training Plans table
CREATE TABLE IF NOT EXISTS public.training_plans (
  user_id uuid REFERENCES auth.users(id) NOT NULL PRIMARY KEY,
  info_text text,
  constraints_json jsonb,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.training_plans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can all on training_plans" ON public.training_plans;
CREATE POLICY "Users can all on training_plans" ON public.training_plans FOR ALL USING (auth.uid() = user_id);

-- Training Plan Sessions table
CREATE TABLE IF NOT EXISTS public.training_plan_sessions (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  day_index integer,
  week_offset integer,
  type text,
  description text,
  minutes integer,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.training_plan_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can all on training_plan_sessions" ON public.training_plan_sessions;
CREATE POLICY "Users can all on training_plan_sessions" ON public.training_plan_sessions FOR ALL USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_training_plan_sessions_user_id ON public.training_plan_sessions(user_id);

-- System Settings table
CREATE TABLE IF NOT EXISTS public.system_settings (
    key text PRIMARY KEY,
    value jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_by uuid REFERENCES auth.users(id)
);

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON public.system_settings;
CREATE POLICY "Enable read access for all users" ON public.system_settings FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Enable write access for admins only" ON public.system_settings;
CREATE POLICY "Enable write access for admins only" ON public.system_settings FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true));

-- Documents table (Vector enabled)
CREATE TABLE IF NOT EXISTS public.documents (
  id bigserial PRIMARY KEY,
  content text,
  metadata jsonb,
  embedding vector(384),
  user_id uuid REFERENCES auth.users(id)
);

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read all documents" ON public.documents;
CREATE POLICY "Users can read all documents" ON public.documents FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own documents" ON public.documents;
CREATE POLICY "Users can insert their own documents" ON public.documents FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Vector search function
CREATE OR REPLACE FUNCTION public.match_documents (
  query_embedding vector(384),
  match_threshold float,
  match_count int
)
RETURNS TABLE (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT
    documents.id,
    documents.content,
    documents.metadata,
    1 - (documents.embedding <=> query_embedding) AS similarity
  FROM public.documents
  WHERE 1 - (documents.embedding <=> query_embedding) > match_threshold
  ORDER BY documents.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Grant permissions
GRANT ALL ON public.activities TO anon, authenticated;
GRANT ALL ON public.planned_activities TO anon, authenticated;
GRANT ALL ON public.goals TO anon, authenticated;
GRANT ALL ON public.goals_milestones TO anon, authenticated;
GRANT ALL ON public.races TO anon, authenticated;
GRANT ALL ON public.training_plans TO anon, authenticated;
GRANT ALL ON public.training_plan_sessions TO anon, authenticated;
GRANT ALL ON public.system_settings TO authenticated;
GRANT ALL ON public.documents TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
