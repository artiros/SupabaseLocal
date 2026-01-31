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
