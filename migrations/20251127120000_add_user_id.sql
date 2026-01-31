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
