-- ============================================================================
-- DOCTORLY MASTER SQL SETUP SCRIPT FOR SUPABASE
-- Run this entire file in your Supabase SQL Editor.
-- It initializes extensions, tables, missing columns, RLS policies, 
-- triggers, functions, and seeds realistic doctor data for testing.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. EXTENSIONS & PREREQUISITES
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ----------------------------------------------------------------------------
-- 2. TABLES & COLUMNS SETUP
-- ----------------------------------------------------------------------------

-- DOCTORS TABLE
CREATE TABLE IF NOT EXISTS public.doctors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure all columns exist even if doctors table was created earlier
ALTER TABLE public.doctors
  ADD COLUMN IF NOT EXISTS name TEXT,
  ADD COLUMN IF NOT EXISTS full_name TEXT,
  ADD COLUMN IF NOT EXISTS specialty TEXT,
  ADD COLUMN IF NOT EXISTS primary_specialty TEXT,
  ADD COLUMN IF NOT EXISTS qualification TEXT,
  ADD COLUMN IF NOT EXISTS sub_specialty TEXT,
  ADD COLUMN IF NOT EXISTS designation TEXT,
  ADD COLUMN IF NOT EXISTS hospital_name TEXT,
  ADD COLUMN IF NOT EXISTS practice_type TEXT,
  ADD COLUMN IF NOT EXISTS city TEXT DEFAULT 'Delhi',
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS phone TEXT,
  ADD COLUMN IF NOT EXISTS phone_number TEXT,
  ADD COLUMN IF NOT EXISTS email TEXT,
  ADD COLUMN IF NOT EXISTS website_url TEXT,
  ADD COLUMN IF NOT EXISTS rating NUMERIC DEFAULT 0.0,
  ADD COLUMN IF NOT EXISTS average_rating NUMERIC DEFAULT 0.0,
  ADD COLUMN IF NOT EXISTS review_count INT4 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS years_of_experience INT2 DEFAULT 0,
  ADD COLUMN IF NOT EXISTS opening_time TEXT DEFAULT '09:00',
  ADD COLUMN IF NOT EXISTS closing_time TEXT DEFAULT '17:00',
  ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS availability TEXT DEFAULT 'Open Today',
  ADD COLUMN IF NOT EXISTS teleconsultation BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS languages TEXT,
  ADD COLUMN IF NOT EXISTS expertise JSONB,
  ADD COLUMN IF NOT EXISTS about TEXT,
  ADD COLUMN IF NOT EXISTS lat DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS lng DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS location GEOGRAPHY(POINT, 4326);

-- PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  anonymous_token TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- FAVORITES TABLE
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT favorites_user_doctor_unique UNIQUE (user_id, doctor_id)
);

-- APPOINTMENTS TABLE
CREATE TABLE IF NOT EXISTS public.appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
  scheduled_for TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'confirmed',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT appointments_doctor_scheduled_for_unique UNIQUE (doctor_id, scheduled_for)
);

-- AVAILABILITY SLOTS TABLE
CREATE TABLE IF NOT EXISTS public.availability_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  is_booked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT availability_slots_doctor_start_time_unique UNIQUE (doctor_id, start_time)
);
CREATE INDEX IF NOT EXISTS availability_slots_doctor_time_idx ON public.availability_slots (doctor_id, start_time);

-- REPORTS TABLE
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_doctor_id UUID REFERENCES public.doctors(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- DOCTOR REVIEWS TABLE
CREATE TABLE IF NOT EXISTS public.doctor_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INT2 NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ----------------------------------------------------------------------------

ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read doctors" ON public.doctors;
CREATE POLICY "Anyone can read doctors" ON public.doctors FOR SELECT TO authenticated, anon USING (true);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profiles read own" ON public.profiles;
CREATE POLICY "profiles read own" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "profiles insert anon" ON public.profiles;
CREATE POLICY "profiles insert anon" ON public.profiles FOR INSERT TO anon WITH CHECK (is_anonymous = true);

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read own favorites" ON public.favorites;
CREATE POLICY "Users can read own favorites" ON public.favorites FOR SELECT TO authenticated, anon USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own favorites" ON public.favorites;
CREATE POLICY "Users can insert own favorites" ON public.favorites FOR INSERT TO authenticated, anon WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own favorites" ON public.favorites;
CREATE POLICY "Users can delete own favorites" ON public.favorites FOR DELETE TO authenticated, anon USING (auth.uid() = user_id);

ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read own appointments" ON public.appointments;
CREATE POLICY "Users can read own appointments" ON public.appointments FOR SELECT TO authenticated, anon USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own appointments" ON public.appointments;
CREATE POLICY "Users can insert own appointments" ON public.appointments FOR INSERT TO authenticated, anon WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.availability_slots ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "availability_slots read" ON public.availability_slots;
CREATE POLICY "availability_slots read" ON public.availability_slots FOR SELECT TO anon, authenticated USING (true);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "reports insert own" ON public.reports;
CREATE POLICY "reports insert own" ON public.reports FOR INSERT TO authenticated, anon WITH CHECK (auth.uid() = reporter_id);
DROP POLICY IF EXISTS "reports select own" ON public.reports;
CREATE POLICY "reports select own" ON public.reports FOR SELECT TO authenticated, anon USING (auth.uid() = reporter_id);

ALTER TABLE public.doctor_reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can insert own doctor reviews" ON public.doctor_reviews;
CREATE POLICY "Users can insert own doctor reviews" ON public.doctor_reviews FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Anyone can read doctor reviews" ON public.doctor_reviews;
CREATE POLICY "Anyone can read doctor reviews" ON public.doctor_reviews FOR SELECT TO authenticated, anon USING (true);

-- ----------------------------------------------------------------------------
-- 4. FUNCTIONS AND TRIGGERS
-- ----------------------------------------------------------------------------

-- Trigger: auto-create profiles on auth.users insert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (user_id, is_anonymous)
    VALUES (new.id, new.email IS NULL)
    ON CONFLICT (user_id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- RPC Function: Merge anonymous account data into new authenticated account
CREATE OR REPLACE FUNCTION public.merge_anonymous_data(
  p_old_anon_id UUID,
  p_new_user_id UUID
)
RETURNS TABLE (
  transferred_favorites BIGINT,
  transferred_appointments BIGINT,
  errors TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_favs BIGINT;
  v_appts BIGINT;
  v_errors TEXT[] := '{}';
BEGIN
  INSERT INTO public.favorites (user_id, doctor_id, created_at)
  SELECT p_new_user_id, doctor_id, created_at
  FROM public.favorites
  WHERE user_id = p_old_anon_id
  ON CONFLICT (user_id, doctor_id) DO NOTHING;
  GET DIAGNOSTICS v_favs = ROW_COUNT;

  DELETE FROM public.favorites WHERE user_id = p_old_anon_id;

  UPDATE public.appointments
  SET user_id = p_new_user_id
  WHERE user_id = p_old_anon_id;
  GET DIAGNOSTICS v_appts = ROW_COUNT;

  UPDATE public.profiles
  SET is_anonymous = FALSE
  WHERE user_id = p_old_anon_id;

  RETURN QUERY SELECT v_favs, v_appts, v_errors;
END;
$$;
GRANT EXECUTE ON FUNCTION public.merge_anonymous_data(UUID, UUID) TO authenticated;

-- RPC Function: Delete User Account
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  DELETE FROM public.appointments WHERE user_id = v_user_id;
  DELETE FROM public.favorites WHERE user_id = v_user_id;
  DELETE FROM public.profiles WHERE user_id = v_user_id;
  DELETE FROM auth.users WHERE id = v_user_id;
END;
$$;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;

-- RPC Function: Nearby Doctors with PostGIS
DROP FUNCTION IF EXISTS public.nearby_doctors(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION);
CREATE OR REPLACE FUNCTION public.nearby_doctors(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  specialty TEXT,
  address TEXT,
  rating NUMERIC,
  image_url TEXT,
  availability TEXT,
  distance_m DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    d.id,
    COALESCE(d.name, d.full_name) AS name,
    COALESCE(d.specialty, d.primary_specialty) AS specialty,
    d.address,
    COALESCE(d.rating, d.average_rating) AS rating,
    d.image_url,
    d.availability,
    ST_Distance(
      d.location,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
    ) AS distance_m
  FROM public.doctors d
  WHERE d.location IS NOT NULL AND ST_DWithin(
    d.location,
    ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
    radius_km * 1000
  )
  ORDER BY distance_m ASC;
$$;
GRANT EXECUTE ON FUNCTION public.nearby_doctors(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) TO anon, authenticated;

-- Trigger Function: Update doctor average_rating & review_count on review change
CREATE OR REPLACE FUNCTION public.update_doctor_rating_on_review()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_doctor_id UUID;
  v_avg_rating NUMERIC;
  v_count INT;
BEGIN
  IF (TG_OP = 'DELETE') THEN
    v_doctor_id := OLD.doctor_id;
  ELSE
    v_doctor_id := NEW.doctor_id;
  END IF;

  SELECT COALESCE(AVG(rating), 0.0), COUNT(*)
  INTO v_avg_rating, v_count
  FROM public.doctor_reviews
  WHERE doctor_id = v_doctor_id;

  UPDATE public.doctors
  SET rating = ROUND(v_avg_rating, 1),
      average_rating = ROUND(v_avg_rating, 1),
      review_count = v_count
  WHERE id = v_doctor_id;

  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_doctor_rating ON public.doctor_reviews;
CREATE TRIGGER trg_update_doctor_rating
  AFTER INSERT OR UPDATE OR DELETE ON public.doctor_reviews
  FOR EACH ROW EXECUTE PROCEDURE public.update_doctor_rating_on_review();

-- Trigger Function: Sync name/full_name & specialty/primary_specialty & location on Doctor Insert/Update
CREATE OR REPLACE FUNCTION public.sync_doctor_fields()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.name IS NULL AND NEW.full_name IS NOT NULL THEN
    NEW.name := NEW.full_name;
  ELSIF NEW.full_name IS NULL AND NEW.name IS NOT NULL THEN
    NEW.full_name := NEW.name;
  END IF;

  IF NEW.specialty IS NULL AND NEW.primary_specialty IS NOT NULL THEN
    NEW.specialty := NEW.primary_specialty;
  ELSIF NEW.primary_specialty IS NULL AND NEW.specialty IS NOT NULL THEN
    NEW.primary_specialty := NEW.specialty;
  END IF;

  IF NEW.rating IS NULL AND NEW.average_rating IS NOT NULL THEN
    NEW.rating := NEW.average_rating;
  ELSIF NEW.average_rating IS NULL AND NEW.rating IS NOT NULL THEN
    NEW.average_rating := NEW.rating;
  END IF;

  IF NEW.phone IS NULL AND NEW.phone_number IS NOT NULL THEN
    NEW.phone := NEW.phone_number;
  ELSIF NEW.phone_number IS NULL AND NEW.phone IS NOT NULL THEN
    NEW.phone_number := NEW.phone;
  END IF;

  IF NEW.lat IS NOT NULL AND NEW.lng IS NOT NULL THEN
    NEW.location := ST_SetSRID(ST_MakePoint(NEW.lng, NEW.lat), 4326)::geography;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_doctor_fields ON public.doctors;
CREATE TRIGGER trg_sync_doctor_fields
  BEFORE INSERT OR UPDATE ON public.doctors
  FOR EACH ROW EXECUTE PROCEDURE public.sync_doctor_fields();

-- ----------------------------------------------------------------------------
-- 5. SEED DATA INSERTION
-- ----------------------------------------------------------------------------

INSERT INTO public.doctors (
  full_name, name,
  qualification, 
  primary_specialty, specialty,
  hospital_name, 
  city, 
  address, 
  phone_number, phone,
  average_rating, rating, 
  review_count, 
  years_of_experience, 
  opening_time, 
  closing_time, 
  is_verified, 
  lat, 
  lng, 
  about
) 
VALUES 
-- General Physicians
('Dr. Amarpreet Singh Riar', 'Dr. Amarpreet Singh Riar', 'MBBS, MD (Medicine)', 'General Physician', 'General Physician', 'City Care Hospital', 'Delhi', 'Sector 18, Noida', '+919876543210', '+919876543210', 4.8, 4.8, 124, 12, '09:00', '19:00', true, 28.5700, 77.3200, 'Experienced general physician specializing in preventive healthcare.'),
('Dr. (Maj.) Sharad Shrivastava', 'Dr. (Maj.) Sharad Shrivastava', 'MBBS, MD (Medicine)', 'General Physician', 'General Physician', 'Adarsh Health Clinic', 'Delhi', 'Dilshad Garden', '+919876543211', '+919876543211', 4.7, 4.7, 98, 15, '10:00', '18:00', true, 28.6810, 77.3020, 'Former military doctor with expertise in internal medicine.'),
('Dr. Anirban Biswas', 'Dr. Anirban Biswas', 'MBBS, MD (Medicine)', 'General Physician', 'General Physician', 'Diabetes & Hormone Care', 'Delhi', 'Lajpat Nagar', '+919876543212', '+919876543212', 4.9, 4.9, 210, 18, '08:00', '20:00', true, 28.5670, 77.2440, 'Diabetologist and general physician.'),
('Dr. Aman Vij', 'Dr. Aman Vij', 'MBBS, MD (Medicine)', 'General Physician', 'General Physician', 'Pitampura Medical Center', 'Delhi', 'Pitampura', '+919876543213', '+919876543213', 4.5, 4.5, 67, 7, '09:30', '17:30', false, 28.6980, 77.1320, 'General physician with a focus on lifestyle diseases.'),

-- Homoeopaths
('Dr. Mansi Arya', 'Dr. Mansi Arya', 'BHMS, MD (Homoeopathy)', 'Homoeopath', 'Homoeopath', 'Rohini Homoeo Clinic', 'Delhi', 'Rohini', '+919876543214', '+919876543214', 4.6, 4.6, 45, 8, '10:00', '19:00', true, 28.7320, 77.0870, 'Homoeopath specializing in chronic ailments.'),
('Dr. Sunil Kumar Dwivedi', 'Dr. Sunil Kumar Dwivedi', 'BHMS', 'Homoeopath', 'Homoeopath', 'Uttam Nagar Wellness', 'Delhi', 'Uttam Nagar', '+919876543215', '+919876543215', 4.4, 4.4, 32, 11, '09:00', '18:00', false, 28.6280, 77.0640, 'Holistic homoeopathic treatments.'),
('Dr. Chhavi Bansal', 'Dr. Chhavi Bansal', 'BHMS, MD (Homoeopathy)', 'Homoeopath', 'Homoeopath', 'Janakpuri Skin Cure', 'Delhi', 'Janakpuri', '+919876543216', '+919876543216', 4.8, 4.8, 89, 9, '10:00', '20:00', true, 28.6210, 77.0870, 'Expert in homoeopathic dermatology.'),
('Dr. Sneh Khera', 'Dr. Sneh Khera', 'BHMS', 'Homoeopath', 'Homoeopath', 'Saket Homoeo Centre', 'Delhi', 'Saket', '+919876543217', '+919876543217', 4.7, 4.7, 56, 14, '09:30', '17:00', true, 28.5240, 77.2060, 'Homoeopath with a focus on women''s health.'),
('Dr. Inderjeet Singh', 'Dr. Inderjeet Singh', 'BHMS', 'Homoeopath', 'Homoeopath', 'Vasant Vihar Clinic', 'Delhi', 'Vasant Vihar', '+919876543218', '+919876543218', 4.5, 4.5, 41, 6, '11:00', '19:00', false, 28.5600, 77.1600, 'General homoeopathic practitioner.'),
('Dr. Suman Mohan', 'Dr. Suman Mohan', 'BHMS', 'Homoeopath', 'Homoeopath', 'Karol Bagh Health Clinic', 'Delhi', 'Karol Bagh', '+919876543219', '+919876543219', 4.3, 4.3, 23, 10, '10:00', '18:00', false, 28.6510, 77.1900, 'Homoeopathic consultant.'),

-- ENT Specialists
('Dr. Manish Munjal', 'Dr. Manish Munjal', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Sir Ganga Ram Hospital', 'Delhi', 'Rajouri Garden', '+919876543220', '+919876543220', 4.9, 4.9, 150, 20, '09:00', '19:00', true, 28.6500, 77.1200, 'Senior ENT surgeon.'),
('Dr. Ajay Jain', 'Dr. Ajay Jain', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Max Super Speciality Hospital', 'Delhi', 'Preet Vihar', '+919876543221', '+919876543221', 4.7, 4.7, 85, 16, '10:00', '18:00', true, 28.6400, 77.2970, 'ENT specialist and head-neck surgeon.'),
('Dr. Anshul Gupta', 'Dr. Anshul Gupta', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Balaji Action Hospital', 'Delhi', 'Paschim Vihar', '+919876543222', '+919876543222', 4.6, 4.6, 72, 12, '09:30', '17:30', true, 28.6720, 77.0980, 'ENT surgeon.'),
('Dr. B B Khatri', 'Dr. B B Khatri', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Dwarka ENT Clinic', 'Delhi', 'Dwarka', '+919876543223', '+919876543223', 4.8, 4.8, 110, 22, '10:00', '20:00', true, 28.5700, 77.0700, 'Veteran ENT consultant.'),
('Dr. Rajeev Adhana', 'Dr. Rajeev Adhana', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Adhana ENT Clinic', 'Delhi', 'Dilshad Garden', '+919876543224', '+919876543224', 4.4, 4.4, 34, 8, '09:00', '17:00', false, 28.6810, 77.3200, 'ENT specialist.'),
('Dr. Vidit Tripathi', 'Dr. Vidit Tripathi', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Greater Kailash Hospital', 'Delhi', 'Greater Kailash', '+919876543225', '+919876543225', 4.9, 4.9, 190, 15, '11:00', '19:00', true, 28.5400, 77.2400, 'ENT specialist.'),
('Dr. Arun Wadhawan', 'Dr. Arun Wadhawan', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Vikaspuri Medical Center', 'Delhi', 'Vikaspuri', '+919876543226', '+919876543226', 4.5, 4.5, 60, 10, '10:00', '18:00', false, 28.6370, 77.0680, 'ENT consultant.'),
('Dr. Neha Sood', 'Dr. Neha Sood', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Shalimar Bagh Clinic', 'Delhi', 'Shalimar Bagh', '+919876543227', '+919876543227', 4.7, 4.7, 95, 11, '09:00', '19:00', true, 28.7000, 77.1500, 'ENT surgeon.'),
('Dr. Vineet Narula', 'Dr. Vineet Narula', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Model Town Hospital', 'Delhi', 'Model Town', '+919876543228', '+919876543228', 4.6, 4.6, 80, 14, '10:00', '18:00', true, 28.6800, 77.1900, 'ENT specialist.'),
('Dr. Yogesh Jain', 'Dr. Yogesh Jain', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Adarsh Nagar Clinic', 'Delhi', 'Adarsh Nagar', '+919876543229', '+919876543229', 4.5, 4.5, 55, 9, '09:30', '17:30', false, 28.7200, 77.1800, 'ENT consultant.'),
('Dr. Rakesh Singh', 'Dr. Rakesh Singh', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Ear-Nose-Throat (ENT) Specialist', 'Mayur Vihar Health Center', 'Delhi', 'Mayur Vihar', '+919876543230', '+919876543230', 4.4, 4.4, 40, 7, '10:00', '18:00', false, 28.6100, 77.2900, 'ENT specialist.'),

-- Ayurveda
('Dr. Sudha Asokan', 'Dr. Sudha Asokan', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Ayurveda', 'Saket Ayurveda Center', 'Delhi', 'Saket', '+919876543231', '+919876543231', 4.8, 4.8, 120, 19, '09:00', '18:00', true, 28.5240, 77.2060, 'Ayurvedic specialist.'),
('Dr. Mahesh Shah', 'Dr. Mahesh Shah', 'BAMS', 'Ayurveda', 'Ayurveda', 'Lajpat Nagar Ayurveda', 'Delhi', 'Lajpat Nagar', '+919876543232', '+919876543232', 4.3, 4.3, 25, 8, '10:00', '19:00', false, 28.5670, 77.2440, 'Ayurvedic consultant.'),
('Dr. S K Singh', 'Dr. S K Singh', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Ayurveda', 'Rohini Ayurvedic Clinic', 'Delhi', 'Rohini', '+919876543233', '+919876543233', 4.7, 4.7, 88, 15, '09:30', '17:30', true, 28.7320, 77.0870, 'Ayurveda expert.'),
('Dr. Sudhir Bhola', 'Dr. Sudhir Bhola', 'BAMS', 'Ayurveda', 'Ayurveda', 'Pitampura Alternative Med', 'Delhi', 'Pitampura', '+919876543234', '+919876543234', 4.6, 4.6, 75, 12, '10:00', '20:00', true, 28.6980, 77.1320, 'Alternative medicine specialist.'),
('Dr. Jyoti Arora Monga', 'Dr. Jyoti Arora Monga', 'BAMS', 'Ayurveda', 'Ayurveda', 'Janakpuri Ayurveda', 'Delhi', 'Janakpuri', '+919876543235', '+919876543235', 4.5, 4.5, 60, 10, '09:00', '18:00', false, 28.6210, 77.0870, 'Ayurvedic doctor.'),
('Dr. Vijay Abbot', 'Dr. Vijay Abbot', 'BAMS', 'Ayurveda', 'Ayurveda', 'Lajpat Nagar Clinic', 'Delhi', 'Lajpat Nagar', '+919876543236', '+919876543236', 4.4, 4.4, 35, 9, '11:00', '19:00', false, 28.5670, 77.2440, 'Ayurvedic consultant.'),
('Dr. Rakesh Gupta', 'Dr. Rakesh Gupta', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Ayurveda', 'Uttam Nagar Clinic', 'Delhi', 'Uttam Nagar', '+919876543237', '+919876543237', 4.8, 4.8, 90, 16, '09:00', '17:00', true, 28.6280, 77.0640, 'Ayurveda specialist.'),
('Dr. Sugeeta Mutreja', 'Dr. Sugeeta Mutreja', 'BAMS', 'Ayurveda', 'Ayurveda', 'Preet Vihar Diet & Ayur', 'Delhi', 'Preet Vihar', '+919876543238', '+919876543238', 4.6, 4.6, 50, 11, '10:00', '18:00', true, 28.6400, 77.2970, 'Dietitian and Ayurvedic expert.'),
('Dr. Ruchi Gupta', 'Dr. Ruchi Gupta', 'BAMS', 'Ayurveda', 'Ayurveda', 'Uttam Nagar Ayurveda', 'Delhi', 'Uttam Nagar', '+919876543239', '+919876543239', 4.5, 4.5, 45, 8, '10:00', '18:00', false, 28.6280, 77.0640, 'Ayurvedic consultant.'),
('Dr. Praveen Rustagi', 'Dr. Praveen Rustagi', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Ayurveda', 'Rohini Ayurvedic Hospital', 'Delhi', 'Rohini', '+919876543240', '+919876543240', 4.7, 4.7, 65, 13, '09:30', '17:30', true, 28.7320, 77.0870, 'Ayurvedic doctor.'),

-- Dermatologists
('Dr. S.K Kashyap', 'Dr. S.K Kashyap', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Saket Skin Hospital', 'Delhi', 'Saket', '+919876543241', '+919876543241', 4.9, 4.9, 200, 20, '09:00', '19:00', true, 28.5240, 77.2060, 'Dermatologist and cosmetologist.'),
('Dr. Nipun Jain', 'Dr. Nipun Jain', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Shalimar Bagh Skin Clinic', 'Delhi', 'Shalimar Bagh', '+919876543242', '+919876543242', 4.7, 4.7, 110, 12, '10:00', '18:00', true, 28.7000, 77.1500, 'Dermatologist.'),
('Dr. Rohit Batra', 'Dr. Rohit Batra', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Rajouri Garden Derma', 'Delhi', 'Rajouri Garden', '+919876543243', '+919876543243', 4.8, 4.8, 150, 15, '10:00', '20:00', true, 28.6500, 77.1200, 'Dermatologist and cosmetologist.'),
('Dr. Lipy Gupta', 'Dr. Lipy Gupta', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Paschim Vihar Derma', 'Delhi', 'Paschim Vihar', '+919876543244', '+919876543244', 4.5, 4.5, 70, 9, '09:30', '17:30', false, 28.6720, 77.0980, 'Dermatologist.'),
('Dr. Gaurav Garg', 'Dr. Gaurav Garg', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Pitampura Skin Care', 'Delhi', 'Pitampura', '+919876543245', '+919876543245', 4.9, 4.9, 180, 14, '10:00', '19:00', true, 28.6980, 77.1320, 'Dermatologist and cosmetologist.'),
('Dr. Parmil Kumar Sharma', 'Dr. Parmil Kumar Sharma', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Dwarka Derma Clinic', 'Delhi', 'Dwarka', '+919876543246', '+919876543246', 4.4, 4.4, 40, 7, '09:00', '17:00', false, 28.5700, 77.0700, 'Dermatologist.'),
('Dr. Shruti Gupta', 'Dr. Shruti Gupta', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Lajpat Nagar Derma', 'Delhi', 'Lajpat Nagar', '+919876543247', '+919876543247', 4.6, 4.6, 85, 10, '10:00', '18:00', true, 28.5670, 77.2440, 'Dermatologist.'),
('Dr. Manisha Chopra', 'Dr. Manisha Chopra', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Saket Derma & Cosmeto', 'Delhi', 'Saket', '+919876543248', '+919876543248', 4.8, 4.8, 120, 16, '09:00', '19:00', true, 28.5240, 77.2060, 'Dermatologist and cosmetologist.'),
('Dr. Ranjan Upadhyay', 'Dr. Ranjan Upadhyay', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dermatologist', 'Mayur Vihar Skin Clinic', 'Delhi', 'Mayur Vihar', '+919876543249', '+919876543249', 4.3, 4.3, 30, 5, '10:00', '18:00', false, 28.6100, 77.2900, 'Dermatologist.'),

-- Gynecologist
('Dr. Gayatri Bala Juneja', 'Dr. Gayatri Bala Juneja', 'MBBS, MS (OBGYN)', 'Gynecologist/Obstetrician', 'Gynecologist/Obstetrician', 'Greater Kailash Hospital', 'Delhi', 'Greater Kailash', '+919876543250', '+919876543250', 4.9, 4.9, 220, 22, '09:00', '19:00', true, 28.5400, 77.2400, 'Gynecologist and obstetrician.');
