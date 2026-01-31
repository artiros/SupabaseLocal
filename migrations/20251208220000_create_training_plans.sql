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
