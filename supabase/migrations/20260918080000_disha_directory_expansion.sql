-- Migration: 20260918080000_disha_directory_expansion.sql
-- Goal: Disha V1 Directory Expansion
-- Adds comprehensive healthcare provider fields, verification and data lifecycle statuses,
-- services taxonomy lookup, doctor_services junction, and strict RLS policies.

-- 1. Extend public.doctors with all required Disha directory fields
ALTER TABLE public.doctors
  ADD COLUMN IF NOT EXISTS external_id text UNIQUE,
  ADD COLUMN IF NOT EXISTS qualification text,
  ADD COLUMN IF NOT EXISTS sub_specialty text,
  ADD COLUMN IF NOT EXISTS years_experience int2 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS designation text,
  ADD COLUMN IF NOT EXISTS hospital_name text,
  ADD COLUMN IF NOT EXISTS practice_type text,
  ADD COLUMN IF NOT EXISTS district text,
  ADD COLUMN IF NOT EXISTS city text,
  ADD COLUMN IF NOT EXISTS pin_code text,
  ADD COLUMN IF NOT EXISTS mobile text,
  ADD COLUMN IF NOT EXISTS whatsapp text,
  ADD COLUMN IF NOT EXISTS hospital_phone text,
  ADD COLUMN IF NOT EXISTS emergency_contact text,
  ADD COLUMN IF NOT EXISTS email text,
  ADD COLUMN IF NOT EXISTS website_url text,
  ADD COLUMN IF NOT EXISTS languages text[],
  ADD COLUMN IF NOT EXISTS teleconsultation text DEFAULT 'unknown' CHECK (teleconsultation IN ('yes', 'no', 'unknown')),
  ADD COLUMN IF NOT EXISTS emergency_24x7 text DEFAULT 'unknown' CHECK (emergency_24x7 IN ('yes', 'no', 'unknown')),
  ADD COLUMN IF NOT EXISTS opd_days text[],
  ADD COLUMN IF NOT EXISTS opd_open time,
  ADD COLUMN IF NOT EXISTS opd_close time,
  ADD COLUMN IF NOT EXISTS opd_by_appointment bool DEFAULT false,
  ADD COLUMN IF NOT EXISTS council_name text,
  ADD COLUMN IF NOT EXISTS registration_no text,
  ADD COLUMN IF NOT EXISTS registration_state text,
  ADD COLUMN IF NOT EXISTS registration_status text,
  ADD COLUMN IF NOT EXISTS registration_verified_on date,
  ADD COLUMN IF NOT EXISTS source_type text,
  ADD COLUMN IF NOT EXISTS primary_source_url text,
  ADD COLUMN IF NOT EXISTS secondary_source_url text,
  ADD COLUMN IF NOT EXISTS remarks text,
  ADD COLUMN IF NOT EXISTS verified_by text,
  ADD COLUMN IF NOT EXISTS last_verified_at timestamptz,
  ADD COLUMN IF NOT EXISTS verification_status text NOT NULL DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'partially_verified', 'verified')),
  ADD COLUMN IF NOT EXISTS data_status text NOT NULL DEFAULT 'draft' CHECK (data_status IN ('draft', 'in_review', 'published', 'rejected', 'test'));

-- Migrate existing boolean is_verified and default existing rows to published if they were active
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'doctors' AND column_name = 'is_verified'
  ) THEN
    UPDATE public.doctors
    SET verification_status = CASE 
      WHEN is_verified = true THEN 'verified' 
      ELSE 'unverified' 
    END,
    data_status = 'published'
    WHERE data_status = 'draft';
  END IF;
END $$;

-- 2. Create services lookup table (11 medical specialties / subspecialties)
CREATE TABLE IF NOT EXISTS public.services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Seed 11 required service slugs
INSERT INTO public.services (slug, name) VALUES
  ('trauma', 'Brain & Spine Trauma'),
  ('brain_tumor', 'Brain Tumor'),
  ('spine', 'Spine Surgery'),
  ('stroke', 'Stroke Care'),
  ('neurovascular', 'Neurovascular'),
  ('pediatric', 'Pediatric Neurosurgery'),
  ('functional', 'Functional Neurosurgery'),
  ('epilepsy', 'Epilepsy Surgery'),
  ('skull_base', 'Pituitary & Skull Base'),
  ('endovascular', 'Endovascular Neurosurgery'),
  ('minimally_invasive_spine', 'Minimally Invasive Spine')
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;

-- 3. Create doctor_services junction table
CREATE TABLE IF NOT EXISTS public.doctor_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id uuid NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
  service_id uuid NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
  status text NOT NULL CHECK (status IN ('yes', 'no', 'unknown')),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT doctor_services_doctor_service_unique UNIQUE (doctor_id, service_id)
);

CREATE INDEX IF NOT EXISTS idx_doctor_services_doctor ON public.doctor_services (doctor_id);
CREATE INDEX IF NOT EXISTS idx_doctor_services_service ON public.doctor_services (service_id);

-- 4. Strict Row-Level Security (RLS)
-- Doctors table RLS: anon & authenticated may ONLY read published & (verified or partially_verified) rows.
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "doctors read" ON public.doctors;
DROP POLICY IF EXISTS "doctors read public" ON public.doctors;

CREATE POLICY "doctors read public" ON public.doctors
  FOR SELECT TO anon, authenticated
  USING (
    data_status = 'published' 
    AND verification_status IN ('verified', 'partially_verified')
  );

-- Services lookup table RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "services read public" ON public.services;
CREATE POLICY "services read public" ON public.services
  FOR SELECT TO anon, authenticated
  USING (true);

-- Doctor Services junction table RLS
ALTER TABLE public.doctor_services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "doctor_services read public" ON public.doctor_services;
CREATE POLICY "doctor_services read public" ON public.doctor_services
  FOR SELECT TO anon, authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.doctors d
      WHERE d.id = doctor_id
        AND d.data_status = 'published'
        AND d.verification_status IN ('verified', 'partially_verified')
    )
  );
