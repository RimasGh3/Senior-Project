-- ============================================================
-- Migration 0: Extensions
-- ============================================================
create extension if not exists pgcrypto;   -- AES-256, SHA-256, gen_random_uuid
create extension if not exists "uuid-ossp"; -- uuid_generate_v4 fallback

-- Set the AES-256 encryption key used for PII columns (GPS coordinates).
-- ⚠ Replace this 32-character placeholder with a real secret before production.
-- In production: store in Supabase Vault (Dashboard → Vault) and read via
--   current_setting('vault.secret_name') or a Vault helper function.
alter database postgres
  set app.aes_key = 'REPLACE_32_CHAR_SECRET_KEY_HERE!';  -- exactly 32 chars
