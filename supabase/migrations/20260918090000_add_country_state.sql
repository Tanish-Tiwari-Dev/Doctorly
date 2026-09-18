-- Migration: 20260918090000_add_country_state.sql
-- Goal: Add country and state columns to public.doctors for Disha V1 Directory

ALTER TABLE public.doctors
  ADD COLUMN IF NOT EXISTS country text DEFAULT 'India',
  ADD COLUMN IF NOT EXISTS state text DEFAULT 'Gujarat';
