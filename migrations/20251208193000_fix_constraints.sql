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
