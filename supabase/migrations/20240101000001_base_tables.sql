-- Database Foundation (Universal Base Tables)
-- This script creates all core tables linked to standard Supabase schemas.

-- 1. PROFILES (Soft Link to Auth to avoid boot-order errors)
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id uuid PRIMARY KEY, -- Will be linked via FK in a later migration
  email text UNIQUE,
  name text,
  dob text,
  weight numeric,
  strava_enabled boolean DEFAULT false,
  strava_access_token text,
  strava_refresh_token text,
  strava_token_expiry bigint,
  is_admin boolean DEFAULT false,
  onboarding_complete boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 2. ACTIVITIES
CREATE TABLE IF NOT EXISTS public.activities (
  id text PRIMARY KEY,
  user_id uuid,
  name text,
  type text,
  start_date timestamptz,
  distance numeric,
  moving_time integer,
  elapsed_time integer,
  total_elevation_gain numeric,
  average_speed numeric,
  max_speed numeric,
  average_heartrate numeric,
  max_heartrate numeric,
  strava_id bigint,
  external_id text
);

ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own activities" ON public.activities FOR ALL USING (auth.uid() = user_id);

-- 3. PLANNED ACTIVITIES
CREATE TABLE IF NOT EXISTS public.planned_activities (
  id uuid DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  user_id uuid,
  name text,
  type text,
  planned_date date,
  distance numeric,
  duration numeric,
  description text,
  completed boolean DEFAULT false
);

ALTER TABLE public.planned_activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own planned activities" ON public.planned_activities FOR ALL USING (auth.uid() = user_id);

-- 4. GOALS
CREATE TABLE IF NOT EXISTS public.goals (
  id uuid DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  user_id uuid,
  name text,
  type text,
  target_value numeric,
  current_value numeric DEFAULT 0,
  start_date date,
  end_date date,
  status text DEFAULT 'active'
);

ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own goals" ON public.goals FOR ALL USING (auth.uid() = user_id);

-- 5. RACES
CREATE TABLE IF NOT EXISTS public.races (
  id uuid DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  user_id uuid,
  name text,
  date date,
  type text,
  distance numeric,
  target_time text,
  notes text
);

ALTER TABLE public.races ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own races" ON public.races FOR ALL USING (auth.uid() = user_id);

-- 6. TRAINING PLANS
CREATE TABLE IF NOT EXISTS public.training_plans (
  user_id uuid PRIMARY KEY,
  info_text text,
  constraints_json jsonb,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.training_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own plans" ON public.training_plans FOR ALL USING (auth.uid() = user_id);

-- 7. TRAINING PLAN SESSIONS
CREATE TABLE IF NOT EXISTS public.training_plan_sessions (
  id text PRIMARY KEY,
  user_id uuid,
  day_index integer,
  week_offset integer,
  type text,
  description text,
  minutes integer,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.training_plan_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own sessions" ON public.training_plan_sessions FOR ALL USING (auth.uid() = user_id);

-- 8. SYSTEM SETTINGS
CREATE TABLE IF NOT EXISTS public.system_settings (
  key text PRIMARY KEY,
  value jsonb NOT NULL,
  updated_at timestamptz DEFAULT now(),
  updated_by uuid
);

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Read access for authenticated" ON public.system_settings FOR SELECT USING (auth.role() = 'authenticated');

-- 9. DOCUMENTS (Vector)
CREATE TABLE IF NOT EXISTS public.documents (
  id bigserial PRIMARY KEY,
  content text,
  metadata jsonb,
  embedding vector(384),
  user_id uuid
);

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view all documents" ON public.documents FOR SELECT USING (true);
CREATE POLICY "Users can insert own documents" ON public.documents FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 10. INDEXES
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON public.activities(user_id);
CREATE INDEX IF NOT EXISTS idx_planned_activities_user_id ON public.planned_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON public.goals(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.training_plan_sessions(user_id);

-- 11. BASE PERMISSIONS
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;
