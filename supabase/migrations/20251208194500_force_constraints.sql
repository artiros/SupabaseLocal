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
