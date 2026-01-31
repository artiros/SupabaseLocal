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
