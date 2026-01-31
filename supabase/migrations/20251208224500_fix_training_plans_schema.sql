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
