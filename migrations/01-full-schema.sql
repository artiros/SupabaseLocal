-- Migration: add profiles table for user data and Strava tokens
-- Safe to run multiple times due to IF NOT EXISTS

CREATE TABLE IF NOT EXISTS public.profiles (
  email text PRIMARY KEY,
  name text,
  dob text,
  weight numeric,
  strava_enabled boolean DEFAULT false,
  strava_access_token text,
  strava_refresh_token text,
  strava_token_expiry bigint,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  EXECUTE 'DROP POLICY IF EXISTS "anon can read profiles" ON public.profiles';
  EXECUTE 'DROP POLICY IF EXISTS "anon can upsert profiles" ON public.profiles';
  EXECUTE 'DROP POLICY IF EXISTS "anon can update profiles" ON public.profiles';
EXCEPTION WHEN others THEN NULL; END $$;

-- Keep policies idempotent
DO $$ BEGIN
  CREATE POLICY "anon can read profiles" ON public.profiles FOR SELECT TO anon USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "anon can upsert profiles" ON public.profiles FOR INSERT TO anon WITH CHECK (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "anon can update profiles" ON public.profiles FOR UPDATE TO anon USING (true) WITH CHECK (true);
EXCEPTION WHEN others THEN NULL; END $$;
-- Add user_id and RLS to user-owned tables
-- Note: This focuses on tables referenced by the app: activities, planned_activities, goals, goals_milestones.

begin;

-- activities
do $$ begin
  alter table public.activities add column user_id uuid;
exception
  when duplicate_column then null;
end $$;

do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'activities_user_id_fk') then
    alter table public.activities add constraint activities_user_id_fk foreign key (user_id) references auth.users(id) on delete cascade;
  end if;
end $$;
create index if not exists activities_user_id_idx on public.activities(user_id);
alter table if exists public.activities enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'activities' and policyname = 'activities_select_own') then
    create policy activities_select_own on public.activities for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'activities' and policyname = 'activities_insert_own') then
    create policy activities_insert_own on public.activities for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'activities' and policyname = 'activities_update_own') then
    create policy activities_update_own on public.activities for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'activities' and policyname = 'activities_delete_own') then
    create policy activities_delete_own on public.activities for delete using (auth.uid() = user_id);
  end if;
end $$;

-- planned_activities
do $$ begin
  alter table public.planned_activities add column user_id uuid;
exception
  when duplicate_column then null;
end $$;

do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'planned_activities_user_id_fk') then
    alter table public.planned_activities add constraint planned_activities_user_id_fk foreign key (user_id) references auth.users(id) on delete cascade;
  end if;
end $$;
create index if not exists planned_activities_user_id_idx on public.planned_activities(user_id);
alter table if exists public.planned_activities enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'planned_activities' and policyname = 'planned_activities_select_own') then
    create policy planned_activities_select_own on public.planned_activities for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'planned_activities' and policyname = 'planned_activities_insert_own') then
    create policy planned_activities_insert_own on public.planned_activities for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'planned_activities' and policyname = 'planned_activities_update_own') then
    create policy planned_activities_update_own on public.planned_activities for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'planned_activities' and policyname = 'planned_activities_delete_own') then
    create policy planned_activities_delete_own on public.planned_activities for delete using (auth.uid() = user_id);
  end if;
end $$;

-- goals
do $$ begin
  alter table public.goals add column user_id uuid;
exception
  when duplicate_column then null;
end $$;

do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'goals_user_id_fk') then
    alter table public.goals add constraint goals_user_id_fk foreign key (user_id) references auth.users(id) on delete cascade;
  end if;
end $$;
create index if not exists goals_user_id_idx on public.goals(user_id);
alter table if exists public.goals enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals' and policyname = 'goals_select_own') then
    create policy goals_select_own on public.goals for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals' and policyname = 'goals_insert_own') then
    create policy goals_insert_own on public.goals for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals' and policyname = 'goals_update_own') then
    create policy goals_update_own on public.goals for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals' and policyname = 'goals_delete_own') then
    create policy goals_delete_own on public.goals for delete using (auth.uid() = user_id);
  end if;
end $$;

-- goals_milestones
do $$ begin
  alter table public.goals_milestones add column user_id uuid;
exception
  when duplicate_column then null;
end $$;

do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'goals_milestones_user_id_fk') then
    alter table public.goals_milestones add constraint goals_milestones_user_id_fk foreign key (user_id) references auth.users(id) on delete cascade;
  end if;
end $$;
create index if not exists goals_milestones_user_id_idx on public.goals_milestones(user_id);
alter table if exists public.goals_milestones enable row level security;
do $$ begin
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals_milestones' and policyname = 'goals_milestones_select_own') then
    create policy goals_milestones_select_own on public.goals_milestones for select using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals_milestones' and policyname = 'goals_milestones_insert_own') then
    create policy goals_milestones_insert_own on public.goals_milestones for insert with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals_milestones' and policyname = 'goals_milestones_update_own') then
    create policy goals_milestones_update_own on public.goals_milestones for update using (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'goals_milestones' and policyname = 'goals_milestones_delete_own') then
    create policy goals_milestones_delete_own on public.goals_milestones for delete using (auth.uid() = user_id);
  end if;
end $$;

commit;
-- Backfill user_id across user-bound tables and tighten RLS to authenticated users.
-- This migration is idempotent and avoids dropping existing columns/PKs.

-- 1) Profiles: add user_id and backfill from auth.users by email
do $$ begin
  alter table public.profiles add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.profiles p
SET user_id = u.id
FROM auth.users u
WHERE p.user_id IS NULL AND u.email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_user_id_unique ON public.profiles(user_id);

-- Helper: function to drop a policy if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'anon can read activities' AND polrelid = 'public.activities'::regclass) THEN
    EXECUTE 'DROP POLICY "anon can read activities" ON public.activities';
  END IF;
EXCEPTION WHEN undefined_table THEN NULL; END $$;

-- 2) Activities
do $$ begin
  alter table public.activities add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.activities a
SET user_id = p.user_id
FROM public.profiles p
WHERE a.user_id IS NULL AND a.user_email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_activities_id_unique ON public.activities(id);
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  PERFORM 1 FROM pg_policy WHERE polname LIKE 'anon can % activities' AND polrelid = 'public.activities'::regclass;
  IF FOUND THEN
    EXECUTE 'DROP POLICY IF EXISTS "anon can read activities" ON public.activities';
    EXECUTE 'DROP POLICY IF EXISTS "anon can upsert activities" ON public.activities';
    EXECUTE 'DROP POLICY IF EXISTS "anon can update activities" ON public.activities';
  END IF;
END $$;
DO $$ BEGIN
  if not exists (select 1 from pg_policy where polname = 'users read own activities' and polrelid = 'public.activities'::regclass) then
    create policy "users read own activities" on public.activities for select to authenticated using (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users insert own activities' and polrelid = 'public.activities'::regclass) then
    create policy "users insert own activities" on public.activities for insert to authenticated with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users update own activities' and polrelid = 'public.activities'::regclass) then
    create policy "users update own activities" on public.activities for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
  end if;
END $$;

-- 3) Planned activities
do $$ begin
  alter table public.planned_activities add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.planned_activities pa
SET user_id = p.user_id
FROM public.profiles p
WHERE pa.user_id IS NULL AND pa.user_email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_planned_activities_id_unique ON public.planned_activities(id);
ALTER TABLE public.planned_activities ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  PERFORM 1 FROM pg_policy WHERE polname LIKE 'anon can % planned_activities' AND polrelid = 'public.planned_activities'::regclass;
  IF FOUND THEN
    EXECUTE 'DROP POLICY IF EXISTS "anon can read planned_activities" ON public.planned_activities';
    EXECUTE 'DROP POLICY IF EXISTS "anon can upsert planned_activities" ON public.planned_activities';
    EXECUTE 'DROP POLICY IF EXISTS "anon can update planned_activities" ON public.planned_activities';
    EXECUTE 'DROP POLICY IF EXISTS "anon can delete planned_activities" ON public.planned_activities';
  END IF;
END $$;
DO $$ BEGIN
  if not exists (select 1 from pg_policy where polname = 'users read own planned' and polrelid = 'public.planned_activities'::regclass) then
    create policy "users read own planned" on public.planned_activities for select to authenticated using (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users insert own planned' and polrelid = 'public.planned_activities'::regclass) then
    create policy "users insert own planned" on public.planned_activities for insert to authenticated with check (user_id = auth.uid() and planned_date::date >= current_date);
  end if;
  if not exists (select 1 from pg_policy where polname = 'users update own planned' and polrelid = 'public.planned_activities'::regclass) then
    create policy "users update own planned" on public.planned_activities for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid() and planned_date::date >= current_date);
  end if;
  if not exists (select 1 from pg_policy where polname = 'users delete own planned' and polrelid = 'public.planned_activities'::regclass) then
    create policy "users delete own planned" on public.planned_activities for delete to authenticated using (user_id = auth.uid());
  end if;
END $$;

-- 4) Goals
do $$ begin
  alter table public.goals add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.goals g
SET user_id = p.user_id
FROM public.profiles p
WHERE g.user_id IS NULL AND g.user_email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_goals_id_unique ON public.goals(id);
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  PERFORM 1 FROM pg_policy WHERE polname LIKE 'anon can % goals' AND polrelid = 'public.goals'::regclass;
  IF FOUND THEN
    EXECUTE 'DROP POLICY IF EXISTS "anon can read goals" ON public.goals';
    EXECUTE 'DROP POLICY IF EXISTS "anon can upsert goals" ON public.goals';
    EXECUTE 'DROP POLICY IF EXISTS "anon can update goals" ON public.goals';
    EXECUTE 'DROP POLICY IF EXISTS "anon can delete goals" ON public.goals';
  END IF;
END $$;
DO $$ BEGIN
  if not exists (select 1 from pg_policy where polname = 'users read own goals' and polrelid = 'public.goals'::regclass) then
    create policy "users read own goals" on public.goals for select to authenticated using (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users insert own goals' and polrelid = 'public.goals'::regclass) then
    create policy "users insert own goals" on public.goals for insert to authenticated with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users update own goals' and polrelid = 'public.goals'::regclass) then
    create policy "users update own goals" on public.goals for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users delete own goals' and polrelid = 'public.goals'::regclass) then
    create policy "users delete own goals" on public.goals for delete to authenticated using (user_id = auth.uid());
  end if;
END $$;

-- 5) Goal milestones
do $$ begin
  alter table public.goals_milestones add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.goals_milestones gm
SET user_id = p.user_id
FROM public.profiles p
WHERE gm.user_id IS NULL AND gm.user_email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_goals_milestones_id_unique ON public.goals_milestones(id);
ALTER TABLE public.goals_milestones ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  PERFORM 1 FROM pg_policy WHERE polname LIKE 'anon can % goals_milestones' AND polrelid = 'public.goals_milestones'::regclass;
  IF FOUND THEN
    EXECUTE 'DROP POLICY IF EXISTS "anon can read goals_milestones" ON public.goals_milestones';
    EXECUTE 'DROP POLICY IF EXISTS "anon can upsert goals_milestones" ON public.goals_milestones';
    EXECUTE 'DROP POLICY IF EXISTS "anon can update goals_milestones" ON public.goals_milestones';
    EXECUTE 'DROP POLICY IF EXISTS "anon can delete goals_milestones" ON public.goals_milestones';
  END IF;
END $$;
DO $$ BEGIN
  if not exists (select 1 from pg_policy where polname = 'users read own milestones' and polrelid = 'public.goals_milestones'::regclass) then
    create policy "users read own milestones" on public.goals_milestones for select to authenticated using (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users insert own milestones' and polrelid = 'public.goals_milestones'::regclass) then
    create policy "users insert own milestones" on public.goals_milestones for insert to authenticated with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users update own milestones' and polrelid = 'public.goals_milestones'::regclass) then
    create policy "users update own milestones" on public.goals_milestones for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users delete own milestones' and polrelid = 'public.goals_milestones'::regclass) then
    create policy "users delete own milestones" on public.goals_milestones for delete to authenticated using (user_id = auth.uid());
  end if;
END $$;

-- 6) Training plans
do $$ begin
  alter table public.training_plans add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.training_plans t
SET user_id = p.user_id
FROM public.profiles p
WHERE t.user_id IS NULL AND t.user_email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_training_plans_user_id_unique ON public.training_plans(user_id);
ALTER TABLE public.training_plans ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  PERFORM 1 FROM pg_policy WHERE polname LIKE 'anon can % training_plans' AND polrelid = 'public.training_plans'::regclass;
  IF FOUND THEN
    EXECUTE 'DROP POLICY IF EXISTS "anon can read training_plans" ON public.training_plans';
    EXECUTE 'DROP POLICY IF EXISTS "anon can upsert training_plans" ON public.training_plans';
    EXECUTE 'DROP POLICY IF EXISTS "anon can update training_plans" ON public.training_plans';
  END IF;
END $$;
DO $$ BEGIN
  if not exists (select 1 from pg_policy where polname = 'users read own plan' and polrelid = 'public.training_plans'::regclass) then
    create policy "users read own plan" on public.training_plans for select to authenticated using (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users upsert own plan' and polrelid = 'public.training_plans'::regclass) then
    create policy "users upsert own plan" on public.training_plans for insert to authenticated with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users update own plan' and polrelid = 'public.training_plans'::regclass) then
    create policy "users update own plan" on public.training_plans for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
  end if;
END $$;

-- 7) Training plan sessions
do $$ begin
  alter table public.training_plan_sessions add column user_id uuid;
exception when duplicate_column then null;
end $$;

UPDATE public.training_plan_sessions s
SET user_id = p.user_id
FROM public.profiles p
WHERE s.user_id IS NULL AND s.user_email = p.email;
CREATE UNIQUE INDEX IF NOT EXISTS idx_training_plan_sessions_id_unique ON public.training_plan_sessions(id);
ALTER TABLE public.training_plan_sessions ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  PERFORM 1 FROM pg_policy WHERE polname LIKE 'anon can % training_plan_sessions' AND polrelid = 'public.training_plan_sessions'::regclass;
  IF FOUND THEN
    EXECUTE 'DROP POLICY IF EXISTS "anon can read training_plan_sessions" ON public.training_plan_sessions';
    EXECUTE 'DROP POLICY IF EXISTS "anon can upsert training_plan_sessions" ON public.training_plan_sessions';
    EXECUTE 'DROP POLICY IF EXISTS "anon can update training_plan_sessions" ON public.training_plan_sessions';
    EXECUTE 'DROP POLICY IF EXISTS "anon can delete training_plan_sessions" ON public.training_plan_sessions';
  END IF;
END $$;
DO $$ BEGIN
  if not exists (select 1 from pg_policy where polname = 'users read own sessions' and polrelid = 'public.training_plan_sessions'::regclass) then
    create policy "users read own sessions" on public.training_plan_sessions for select to authenticated using (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users insert own sessions' and polrelid = 'public.training_plan_sessions'::regclass) then
    create policy "users insert own sessions" on public.training_plan_sessions for insert to authenticated with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users update own sessions' and polrelid = 'public.training_plan_sessions'::regclass) then
    create policy "users update own sessions" on public.training_plan_sessions for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
  end if;
  if not exists (select 1 from pg_policy where polname = 'users delete own sessions' and polrelid = 'public.training_plan_sessions'::regclass) then
    create policy "users delete own sessions" on public.training_plan_sessions for delete to authenticated using (user_id = auth.uid());
  end if;
END $$;

-- Optional indexes for performance
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON public.activities(user_id);
CREATE INDEX IF NOT EXISTS idx_planned_activities_user_id ON public.planned_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON public.goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_milestones_user_id ON public.goals_milestones(user_id);
CREATE INDEX IF NOT EXISTS idx_training_plan_sessions_user_id ON public.training_plan_sessions(user_id);

-- Note: We intentionally do NOT drop user_email columns or existing PKs in this migration
-- to avoid disruptions. Frontend now uses user_id and the unique(id) constraints support upsert.
-- Add missing columns for triathlon goals
alter table if exists public.goals add column if not exists race_id text;
alter table if exists public.goals add column if not exists swim_distance_m numeric;
alter table if exists public.goals add column if not exists bike_distance_m numeric;
alter table if exists public.goals add column if not exists run_distance_m numeric;
-- Ensure explicit unique constraints exist for 'id' to support ON CONFLICT(id)
-- Using ALTER TABLE ADD CONSTRAINT UNIQUE is more robust for PostgREST than just a unique index.

BEGIN;

-- Activities
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'activities_id_key') THEN
    ALTER TABLE public.activities ADD CONSTRAINT activities_id_key UNIQUE (id);
  END IF;
END $$;

-- Planned Activities
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'planned_activities_id_key') THEN
    ALTER TABLE public.planned_activities ADD CONSTRAINT planned_activities_id_key UNIQUE (id);
  END IF;
END $$;

-- Goals
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'goals_id_key') THEN
    ALTER TABLE public.goals ADD CONSTRAINT goals_id_key UNIQUE (id);
  END IF;
END $$;

-- Goals Milestones
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'goals_milestones_id_key') THEN
    ALTER TABLE public.goals_milestones ADD CONSTRAINT goals_milestones_id_key UNIQUE (id);
  END IF;
END $$;



COMMIT;
-- Force reconstruction of UNIQUE constraints to ensure they exist and match the expectations of ON CONFLICT(id)

BEGIN;

-- Activities
ALTER TABLE public.activities DROP CONSTRAINT IF EXISTS activities_id_key;
ALTER TABLE public.activities ADD CONSTRAINT activities_id_key UNIQUE (id);

-- Planned Activities
ALTER TABLE public.planned_activities DROP CONSTRAINT IF EXISTS planned_activities_id_key;
ALTER TABLE public.planned_activities ADD CONSTRAINT planned_activities_id_key UNIQUE (id);

-- Goals
ALTER TABLE public.goals DROP CONSTRAINT IF EXISTS goals_id_key;
ALTER TABLE public.goals ADD CONSTRAINT goals_id_key UNIQUE (id);

-- Goals Milestones
ALTER TABLE public.goals_milestones DROP CONSTRAINT IF EXISTS goals_milestones_id_key;
ALTER TABLE public.goals_milestones ADD CONSTRAINT goals_milestones_id_key UNIQUE (id);



COMMIT;
-- Final fix for unique constraints to persist across PostgREST schema cache reloads
-- PostgREST needs a clear constraint to target. If dropping and re-adding didn't immediately propagate,
-- we'll try an explicit index-backed unique constraint which is the standard way.

BEGIN;

-- Activities
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'activities_id_key') THEN
    ALTER TABLE public.activities DROP CONSTRAINT activities_id_key;
  END IF;
  ALTER TABLE public.activities ADD CONSTRAINT activities_id_key UNIQUE (id);
END $$;

-- Planned Activities
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'planned_activities_id_key') THEN
    ALTER TABLE public.planned_activities DROP CONSTRAINT planned_activities_id_key;
  END IF;
  ALTER TABLE public.planned_activities ADD CONSTRAINT planned_activities_id_key UNIQUE (id);
END $$;

-- Goals
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'goals_id_key') THEN
    ALTER TABLE public.goals DROP CONSTRAINT goals_id_key;
  END IF;
  ALTER TABLE public.goals ADD CONSTRAINT goals_id_key UNIQUE (id);
END $$;

-- Goals Milestones
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'goals_milestones_id_key') THEN
    ALTER TABLE public.goals_milestones DROP CONSTRAINT goals_milestones_id_key;
  END IF;
  ALTER TABLE public.goals_milestones ADD CONSTRAINT goals_milestones_id_key UNIQUE (id);
END $$;

-- Reload schema cache
NOTIFY pgrst, 'reload config';

COMMIT;
-- Migration skipped to avoid Primary Key dependency issues.
-- The application ensures user_email is provided, so strict constraint is acceptable for now.
-- Proceeding with Training Plans creation.
create table if not exists training_plans (
  user_id uuid references auth.users not null primary key,
  info_text text,
  constraints_json jsonb,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

alter table training_plans enable row level security;

create policy "Users can all on training_plans"
  on training_plans for all
  using (auth.uid() = user_id);

create table if not exists training_plan_sessions (
  id text primary key,
  user_id uuid references auth.users not null,
  day_index integer,
  week_offset integer,
  type text,
  description text,
  minutes integer,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

alter table training_plan_sessions enable row level security;

create policy "Users can all on training_plan_sessions"
  on training_plan_sessions for all
  using (auth.uid() = user_id);

create index if not exists idx_training_plan_sessions_user_id on training_plan_sessions(user_id);
-- Recreate training_plans table to ensure correct schema and columns
DROP TABLE IF EXISTS public.training_plans CASCADE;

CREATE TABLE public.training_plans (
  user_id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  info_text text,
  constraints_json jsonb,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.training_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can all on training_plans"
  ON public.training_plans FOR ALL
  USING (auth.uid() = user_id);
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
-- Ensure activities table has correct RLS policies
ALTER TABLE IF EXISTS public.activities ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_select_own" ON public.activities;
  CREATE POLICY "activities_select_own" ON public.activities FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_insert_own" ON public.activities;
  CREATE POLICY "activities_insert_own" ON public.activities FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_update_own" ON public.activities;
  CREATE POLICY "activities_update_own" ON public.activities FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  DROP POLICY IF EXISTS "activities_delete_own" ON public.activities;
  CREATE POLICY "activities_delete_own" ON public.activities FOR DELETE USING (auth.uid() = user_id);
EXCEPTION WHEN others THEN NULL; END $$;
ALTER TABLE public.training_plan_sessions ADD COLUMN IF NOT EXISTS details text;
-- Add avatar_url column to profiles table
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url text;

-- Create avatars storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Enable public access for avatars bucket
CREATE POLICY "Public Avatar Access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can update avatars"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can delete avatars"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);
-- Add onboarding_completed field to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS onboarding_completed boolean DEFAULT false;
-- Migration: Add strava_athlete_id to profiles for webhook mapping
-- Date: 2025-12-10

DO $$ BEGIN
    ALTER TABLE public.profiles ADD COLUMN strava_athlete_id text;
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

CREATE INDEX IF NOT EXISTS idx_profiles_strava_athlete_id ON public.profiles(strava_athlete_id);
-- Migration: Add dashboard feature columns (metrics & priorities)
-- Date: 2025-12-10

BEGIN;

-- Activities Table enhancements for Analytics
DO $$ BEGIN
    ALTER TABLE public.activities ADD COLUMN pr_tags jsonb DEFAULT '[]'::jsonb;
EXCEPTION WHEN duplicate_column THEN null; END $$;

DO $$ BEGIN
    ALTER TABLE public.activities ADD COLUMN training_load integer; -- TSS
EXCEPTION WHEN duplicate_column THEN null; END $$;

DO $$ BEGIN
    ALTER TABLE public.activities ADD COLUMN intensity_factor numeric; -- IF
EXCEPTION WHEN duplicate_column THEN null; END $$;

DO $$ BEGIN
    ALTER TABLE public.activities ADD COLUMN variability_index numeric; -- VI
EXCEPTION WHEN duplicate_column THEN null; END $$;

DO $$ BEGIN
    ALTER TABLE public.activities ADD COLUMN zone_distribution jsonb DEFAULT '{}'::jsonb; -- { "z1": 1200, "z2": ... }
EXCEPTION WHEN duplicate_column THEN null; END $$;

-- Goals Table enhancements for Roadmap
DO $$ BEGIN
    ALTER TABLE public.goals ADD COLUMN priority text DEFAULT 'B'; -- A, B, C race priority
EXCEPTION WHEN duplicate_column THEN null; END $$;

COMMIT;
-- Function to calculate CTL, ATL, TSB for the authenticated user
CREATE OR REPLACE FUNCTION get_user_performance_metrics()
RETURNS TABLE (
  date date,
  ctl int,
  atl int,
  tsb int
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  curr_user_id uuid;
  first_date date;
BEGIN
  curr_user_id := auth.uid();
  
  -- If no user, return empty
  IF curr_user_id IS NULL THEN
    RETURN;
  END IF;

  SELECT MIN(start_date)::date INTO first_date FROM activities WHERE user_id = curr_user_id;

  -- Default to 90 days ago if no activities found, to show empty chart instead of nothing
  IF first_date IS NULL THEN
    first_date := CURRENT_DATE - INTERVAL '90 days';
  END IF;

  RETURN QUERY
  WITH daily_tss AS (
    SELECT
      d::date as day,
      COALESCE(SUM(a.training_load), 0) as tss
    FROM
      generate_series(
        first_date,
        CURRENT_DATE,
        '1 day'::interval
      ) d
      LEFT JOIN activities a ON a.start_date::date = d::date AND a.user_id = curr_user_id
    GROUP BY d::date
  ),
  calc AS (
    -- Anchor member
    (
      SELECT
        dt.day,
        dt.tss::numeric as tss,
        dt.tss::numeric as ctl,
        dt.tss::numeric as atl
      FROM daily_tss dt
      WHERE dt.day = first_date
    )
    UNION ALL
    -- Recursive member
    (
      SELECT
        dt.day,
        dt.tss::numeric,
        (c.ctl + (dt.tss - c.ctl) / 42.0) as ctl,
        (c.atl + (dt.tss - c.atl) / 7.0) as atl
      FROM daily_tss dt
      JOIN calc c ON dt.day = c.day + INTERVAL '1 day'
    )
  )
  SELECT
    c.day as date,
    ROUND(c.ctl)::int as ctl,
    ROUND(c.atl)::int as atl,
    ROUND(c.ctl - c.atl)::int as tsb
  FROM calc c
  ORDER BY c.day;

END;
$$;
CREATE OR REPLACE FUNCTION get_user_performance_metrics()
RETURNS TABLE (
  date date,
  ctl integer,
  atl integer,
  tsb integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  curr_user_id uuid;
  first_date date;
BEGIN
  curr_user_id := auth.uid();
  IF curr_user_id IS NULL THEN
    RETURN;
  END IF;

  SELECT MIN(start_date)::date INTO first_date FROM activities WHERE user_id = curr_user_id;

  -- Default to 90 days ago if no activities found, to show empty chart instead of nothing
  IF first_date IS NULL THEN
    first_date := CURRENT_DATE - INTERVAL '90 days';
  END IF;

  RETURN QUERY
  WITH RECURSIVE daily_tss AS (
    SELECT
      d::date as day,
      COALESCE(SUM(a.training_load), 0) as tss
    FROM
      generate_series(
        first_date,
        CURRENT_DATE,
        '1 day'::interval
      ) d
      LEFT JOIN activities a ON a.start_date::date = d::date AND a.user_id = curr_user_id
    GROUP BY d::date
  ),
  calc_metrics AS (
    SELECT
      day,
      tss,
      -- Recursive CTE for CTL/ATL
      -- Since recursive aggregates are hard in one step, use window functions or simple recursion
      -- Rolling avg approximation:
      -- CTL_today = CTL_yesterday + (TSS_today - CTL_yesterday)/42
      -- We'll use a recursive CTE
      0 as dummy
    FROM daily_tss
  ),
  recursive_pmc AS (
    -- Anchor
    SELECT 
      day,
      tss::float as ctl_float,
      tss::float as atl_float
    FROM daily_tss 
    WHERE day = first_date
    
    UNION ALL
    
    -- Recursive
    SELECT
      d.day,
      (prev.ctl_float + (d.tss - prev.ctl_float) / 42.0) as ctl_float,
      (prev.atl_float + (d.tss - prev.atl_float) / 7.0) as atl_float
    FROM daily_tss d
    JOIN recursive_pmc prev ON d.day = (prev.day + INTERVAL '1 day')::date
  )
  SELECT
    day,
    ROUND(ctl_float)::integer as ctl,
    ROUND(atl_float)::integer as atl,
    ROUND(ctl_float - atl_float)::integer as tsb
  FROM recursive_pmc
  ORDER BY day;
END;
$$;
CREATE OR REPLACE FUNCTION get_user_performance_metrics()
RETURNS TABLE (
  date date,
  ctl integer,
  atl integer,
  tsb integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  curr_user_id uuid;
  first_date date;
BEGIN
  curr_user_id := auth.uid();
  IF curr_user_id IS NULL THEN
    RETURN;
  END IF;

  SELECT MIN(start_date)::date INTO first_date FROM activities WHERE user_id = curr_user_id;

  -- Default to 90 days ago if no activities found, to show empty chart instead of nothing
  IF first_date IS NULL THEN
    first_date := CURRENT_DATE - INTERVAL '90 days';
  END IF;

  RETURN QUERY
  WITH RECURSIVE daily_tss AS (
    SELECT
      d::date as day,
      COALESCE(SUM(a.training_load), 0) as tss
    FROM
      generate_series(
        first_date,
        CURRENT_DATE,
        '1 day'::interval
      ) d
      LEFT JOIN activities a ON a.start_date::date = d::date AND a.user_id = curr_user_id
    GROUP BY d::date
  ),
  recursive_pmc AS (
    -- Anchor
    SELECT 
      day,
      tss::float as ctl_float,
      tss::float as atl_float
    FROM daily_tss 
    WHERE day = first_date
    
    UNION ALL
    
    -- Recursive
    SELECT
      d.day,
      (prev.ctl_float + (d.tss - prev.ctl_float) / 42.0) as ctl_float,
      (prev.atl_float + (d.tss - prev.atl_float) / 7.0) as atl_float
    FROM daily_tss d
    JOIN recursive_pmc prev ON d.day = (prev.day + INTERVAL '1 day')::date
  )
  SELECT
    day,
    ROUND(ctl_float)::integer as ctl,
    ROUND(atl_float)::integer as atl,
    ROUND(ctl_float - atl_float)::integer as tsb
  FROM recursive_pmc
  ORDER BY day;
END;
$$;
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS ftp_value INTEGER DEFAULT 200,
ADD COLUMN IF NOT EXISTS threshold_pace INTEGER, -- Seconds per km
ADD COLUMN IF NOT EXISTS manual_override BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS last_estimated_date TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN profiles.ftp_value IS 'Functional Threshold Power in Watts';
COMMENT ON COLUMN profiles.threshold_pace IS 'Threshold running pace in seconds per kilometer';
-- Add threshold_hr to profiles
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS threshold_hr INTEGER;

-- Add heart rate fields to activities
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS average_heartrate FLOAT,
ADD COLUMN IF NOT EXISTS max_heartrate FLOAT;
-- Add velocity and speed stream columns to activities
ALTER TABLE activities 
ADD COLUMN IF NOT EXISTS velocity_over_time JSONB,
ADD COLUMN IF NOT EXISTS speed_over_time JSONB;
-- Add ai_analysis column to activities table
ALTER TABLE activities ADD COLUMN IF NOT EXISTS ai_analysis TEXT;
-- Migration: Add LLM settings to profiles
-- Safe to run multiple times

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'active_llm_provider') THEN
    ALTER TABLE public.profiles ADD COLUMN active_llm_provider text DEFAULT 'gemini';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'llm_base_url') THEN
    ALTER TABLE public.profiles ADD COLUMN llm_base_url text;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'llm_model_name') THEN
    ALTER TABLE public.profiles ADD COLUMN llm_model_name text;
  END IF;
END $$;
-- Migration: Global Admin Settings
-- 1. Add is_admin to profiles
-- 2. Create system_settings table
-- 3. Setup RLS for system_settings

-- 1. Add is_admin to profiles
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'is_admin') THEN
    ALTER TABLE public.profiles ADD COLUMN is_admin boolean DEFAULT false;
  END IF;
END $$;

-- 2. Create system_settings table
CREATE TABLE IF NOT EXISTS public.system_settings (
    key text PRIMARY KEY,
    value jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_by uuid REFERENCES public.profiles(user_id)
);

-- 3. Enable RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read settings (needed for app to function)
CREATE POLICY "Enable read access for all users" ON public.system_settings
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Policy: Only admins can insert/update/delete
CREATE POLICY "Enable write access for admins only" ON public.system_settings
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.user_id = auth.uid()
            AND profiles.is_admin = true
        )
    );

-- Grant access to authenticated users
GRANT SELECT ON public.system_settings TO authenticated;
GRANT ALL ON public.system_settings TO service_role;
-- Migration: Fix profiles RLS for authenticated users
-- The profiles table only had policies for 'anon' role, not 'authenticated'
-- This caused authenticated users to not be able to read their own profile (including is_admin)

-- Add policy for authenticated users to read their own profile
DO $$ BEGIN
  CREATE POLICY "authenticated users read own profile" 
    ON public.profiles 
    FOR SELECT 
    TO authenticated 
    USING (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Add policy for authenticated users to update their own profile
DO $$ BEGIN
  CREATE POLICY "authenticated users update own profile" 
    ON public.profiles 
    FOR UPDATE 
    TO authenticated 
    USING (user_id = auth.uid()) 
    WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Add policy for authenticated users to insert their own profile
DO $$ BEGIN
  CREATE POLICY "authenticated users insert own profile" 
    ON public.profiles 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
