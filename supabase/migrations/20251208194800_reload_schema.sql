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
