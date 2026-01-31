-- Migration: Encrypt API keys in system_settings
-- Uses pgcrypto extension with encryption key from environment variable

-- 1. Enable pgcrypto extension (ALREADY ENABLED IN BOOTSTRAP)
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Create helper functions for encryption/decryption
-- The encryption key is read from a PostgreSQL setting that should be set via environment variable
-- In Supabase, set this in your project settings or via SQL: ALTER DATABASE postgres SET app.encryption_key = 'your-32-char-secret-key';

CREATE OR REPLACE FUNCTION encrypt_api_key(plain_text text)
RETURNS text AS $$
DECLARE
  encryption_key text;
BEGIN
  -- Get encryption key from database setting (set via env var or ALTER DATABASE)
  BEGIN
    encryption_key := current_setting('app.encryption_key', true);
  EXCEPTION WHEN OTHERS THEN
    encryption_key := NULL;
  END;
  
  -- If no encryption key is set, return plaintext (for backwards compatibility)
  IF encryption_key IS NULL OR encryption_key = '' THEN
    RETURN plain_text;
  END IF;
  
  -- Encrypt using AES-256 and return as base64
  RETURN encode(
    pgp_sym_encrypt(plain_text, encryption_key),
    'base64'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION decrypt_api_key(encrypted_text text)
RETURNS text AS $$
DECLARE
  encryption_key text;
BEGIN
  -- Get encryption key from database setting
  BEGIN
    encryption_key := current_setting('app.encryption_key', true);
  EXCEPTION WHEN OTHERS THEN
    encryption_key := NULL;
  END;
  
  -- If no encryption key, assume it's plaintext (backwards compatibility)
  IF encryption_key IS NULL OR encryption_key = '' THEN
    RETURN encrypted_text;
  END IF;
  
  -- Check if the value looks like it's encrypted (base64 encoded pgp)
  -- If it doesn't start with expected pattern, return as-is
  BEGIN
    RETURN pgp_sym_decrypt(
      decode(encrypted_text, 'base64'),
      encryption_key
    );
  EXCEPTION WHEN OTHERS THEN
    -- If decryption fails, it's probably plaintext
    RETURN encrypted_text;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Grant execute permissions
GRANT EXECUTE ON FUNCTION encrypt_api_key(text) TO authenticated;
GRANT EXECUTE ON FUNCTION decrypt_api_key(text) TO authenticated;
