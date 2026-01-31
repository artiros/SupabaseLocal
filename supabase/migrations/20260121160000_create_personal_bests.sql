-- Create enum for source (wrapped in guard for idempotency)
DO $$ BEGIN
  CREATE TYPE personal_best_source AS ENUM ('manual', 'auto');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Create Personal Bests table
create table if not exists personal_bests (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null, -- Removed hard reference to auth.users to avoid boot-order errors
  activity_type text not null, -- 'Run', 'Ride', 'Swim'
  distance_meters numeric not null,
  time_seconds numeric not null,
  achieved_at timestamptz not null,
  source personal_best_source not null default 'auto',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  -- Ensure unique custom PB per distance/type to avoid duplicates
  unique(user_id, activity_type, distance_meters)
);

-- Enable RLS
alter table personal_bests enable row level security;

-- RLS Policies
create policy "Users can view their own PBs"
  on personal_bests for select
  using (auth.uid() = user_id);

create policy "Users can insert their own PBs"
  on personal_bests for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own PBs"
  on personal_bests for update
  using (auth.uid() = user_id);

create policy "Users can delete their own PBs"
  on personal_bests for delete
  using (auth.uid() = user_id);
