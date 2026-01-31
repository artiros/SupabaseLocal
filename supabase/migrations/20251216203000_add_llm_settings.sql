-- Migration: Add LLM settings to profiles
-- Safe to run multiple times

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'active_llm_provider') THEN
    ALTER TABLE public.profiles ADD COLUMN active_llm_provider text DEFAULT 'gemini';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'llm_base_url') THEN
    ALTER TABLE public.profiles ADD COLUMN llm_base_url text;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'llm_model_name') THEN
    ALTER TABLE public.profiles ADD COLUMN llm_model_name text;
  END IF;
END $$;
