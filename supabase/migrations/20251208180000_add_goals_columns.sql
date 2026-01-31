-- Add missing columns for triathlon goals
alter table if exists public.goals add column if not exists race_id text;
alter table if exists public.goals add column if not exists swim_distance_m numeric;
alter table if exists public.goals add column if not exists bike_distance_m numeric;
alter table if exists public.goals add column if not exists run_distance_m numeric;
