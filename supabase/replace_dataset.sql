-- ============================================================================
-- TRANSACTIONAL DATASET REPLACEMENT SCRIPT: Neurosurgery Test Dataset (100 rows)
-- Safe execution: transactional, idempotent, outputs counts
-- ============================================================================
BEGIN;

-- Ensure teleconsultation supports text domain or alter column to text if boolean
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'doctors' AND column_name = 'teleconsultation' AND data_type = 'boolean'
  ) THEN
    ALTER TABLE public.doctors 
      ALTER COLUMN teleconsultation DROP DEFAULT,
      ALTER COLUMN teleconsultation TYPE text USING (
        CASE 
          WHEN teleconsultation = true THEN 'yes'
          WHEN teleconsultation = false THEN 'no'
          ELSE 'unknown'
        END
      ),
      ALTER COLUMN teleconsultation SET DEFAULT 'unknown';
  END IF;
END $$;

-- 1. Delete child records of obsolete doctors not present in the new dataset
DELETE FROM public.doctor_services 
WHERE doctor_id IN (SELECT id FROM public.doctors WHERE external_id NOT IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100') OR external_id IS NULL);

DELETE FROM public.doctor_reviews 
WHERE doctor_id IN (SELECT id FROM public.doctors WHERE external_id NOT IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100') OR external_id IS NULL);

DELETE FROM public.favorites 
WHERE doctor_id IN (SELECT id FROM public.doctors WHERE external_id NOT IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100') OR external_id IS NULL);

DELETE FROM public.reports 
WHERE reported_doctor_id IN (SELECT id FROM public.doctors WHERE external_id NOT IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100') OR external_id IS NULL);

DELETE FROM public.appointments 
WHERE doctor_id IN (SELECT id FROM public.doctors WHERE external_id NOT IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100') OR external_id IS NULL);

-- 2. Delete obsolete doctors
DELETE FROM public.doctors 
WHERE external_id NOT IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100') OR external_id IS NULL;

-- 3. Upsert doctors on external_id
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-001', 'Dr Aarav Sharma (Test 001)', 'Dr Aarav Sharma (Test 001)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 2, 2, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 01', 'Private', 'India', 'Gujarat', 'Ahmedabad', 'Ahmedabad', '380001', '0000000001', '0000000001', '0000000001', '0000000001', 'dummy.doctor.001@example.invalid', 'https://example.invalid/doctors/test-001', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10001', 'Gujarat', 'Active', '2026-01-01'::date, 'https://example.invalid/source/primary-001', 'https://example.invalid/source/secondary-001', 'Doctor Submitted', '0000000001', '0000000001', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 23.0185, 72.5654, 'unverified', 'published', false, 'Test Data Generator', '2026-09-01'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-002', 'Dr Vivaan Sharma (Test 002)', 'Dr Vivaan Sharma (Test 002)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 3, 3, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 02', 'Government', 'India', 'Gujarat', 'Sabarkantha', 'Himmatnagar', '383001', '0000000002', '0000000002', '0000000002', '0000000002', 'dummy.doctor.002@example.invalid', 'https://example.invalid/doctors/test-002', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10002', 'Gujarat', 'Pending Verification', '2026-02-02'::date, 'https://example.invalid/source/primary-002', 'https://example.invalid/source/secondary-002', 'Hospital Website', '0000000002', '0000000002', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 23.5949, 72.959, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-02'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-003', 'Dr Aditya Sharma (Test 003)', 'Dr Aditya Sharma (Test 003)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 4, 4, 'Associate Consultant', 'Demo Neuro Hospital 03', 'Trust / NGO', 'India', 'Gujarat', 'Aravalli', 'Modasa', '383315', '0000000003', '0000000003', '0000000003', '0000000003', 'dummy.doctor.003@example.invalid', 'https://example.invalid/doctors/test-003', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10003', 'Gujarat', 'Unknown', '2026-03-03'::date, 'https://example.invalid/source/primary-003', 'https://example.invalid/source/secondary-003', 'Medical Council', '0000000003', '0000000003', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 23.4625, 73.2966, 'verified', 'published', true, 'Test Data Generator', '2026-09-03'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-004', 'Dr Arjun Sharma (Test 004)', 'Dr Arjun Sharma (Test 004)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 5, 5, 'Assistant Professor', 'Demo Neuro Hospital 04', 'Medical College', 'India', 'Gujarat', 'Gandhinagar', 'Gandhinagar', '382010', '0000000004', '0000000004', '0000000004', '0000000004', 'dummy.doctor.004@example.invalid', 'https://example.invalid/doctors/test-004', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10004', 'Gujarat', 'Active', '2026-04-04'::date, 'https://example.invalid/source/primary-004', 'https://example.invalid/source/secondary-004', 'Professional Society', '0000000004', '0000000004', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 23.2176, 72.6369, 'unverified', 'published', false, 'Test Data Generator', '2026-09-04'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-005', 'Dr Reyansh Sharma (Test 005)', 'Dr Reyansh Sharma (Test 005)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 6, 6, 'Professor & Head', 'Demo Neuro Hospital 05', 'Corporate Hospital', 'India', 'Gujarat', 'Vadodara', 'Vadodara', '390001', '0000000005', '0000000005', '0000000005', '0000000005', 'dummy.doctor.005@example.invalid', 'https://example.invalid/doctors/test-005', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10005', 'Gujarat', 'Pending Verification', '2026-05-05'::date, 'https://example.invalid/source/primary-005', 'https://example.invalid/source/secondary-005', 'Public Directory', '0000000005', '0000000005', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 22.3112, 73.1832, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-05'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-006', 'Dr Ishaan Sharma (Test 006)', 'Dr Ishaan Sharma (Test 006)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 7, 7, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 06', 'Independent', 'India', 'Gujarat', 'Surat', 'Surat', '395003', '0000000006', '0000000006', '0000000006', '0000000006', 'dummy.doctor.006@example.invalid', 'https://example.invalid/doctors/test-006', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10006', 'Gujarat', 'Unknown', '2026-06-06'::date, 'https://example.invalid/source/primary-006', 'https://example.invalid/source/secondary-006', 'Other', '0000000006', '0000000006', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"Hindi", "English"}'::text[], 21.1662, 72.8351, 'verified', 'published', true, 'Test Data Generator', '2026-09-06'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-007', 'Dr Kabir Sharma (Test 007)', 'Dr Kabir Sharma (Test 007)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 8, 8, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 07', 'Private', 'India', 'Gujarat', 'Rajkot', 'Rajkot', '360001', '0000000007', '0000000007', '0000000007', '0000000007', 'dummy.doctor.007@example.invalid', 'https://example.invalid/doctors/test-007', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10007', 'Gujarat', 'Active', '2026-07-07'::date, 'https://example.invalid/source/primary-007', 'https://example.invalid/source/secondary-007', 'Doctor Submitted', '0000000007', '0000000007', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 22.3019, 70.8082, 'unverified', 'published', false, 'Test Data Generator', '2026-09-07'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-008', 'Dr Atharv Sharma (Test 008)', 'Dr Atharv Sharma (Test 008)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 9, 9, 'Associate Consultant', 'Demo Neuro Hospital 08', 'Government', 'India', 'Gujarat', 'Bhavnagar', 'Bhavnagar', '364001', '0000000008', '0000000008', '0000000008', '0000000008', 'dummy.doctor.008@example.invalid', 'https://example.invalid/doctors/test-008', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10008', 'Gujarat', 'Pending Verification', '2026-08-08'::date, 'https://example.invalid/source/primary-008', 'https://example.invalid/source/secondary-008', 'Hospital Website', '0000000008', '0000000008', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 21.7645, 72.1459, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-08'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-009', 'Dr Krish Sharma (Test 009)', 'Dr Krish Sharma (Test 009)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 10, 10, 'Assistant Professor', 'Demo Neuro Hospital 09', 'Trust / NGO', 'India', 'Gujarat', 'Jamnagar', 'Jamnagar', '361001', '0000000009', '0000000009', '0000000009', '0000000009', 'dummy.doctor.009@example.invalid', 'https://example.invalid/doctors/test-009', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10009', 'Gujarat', 'Unknown', '2026-01-09'::date, 'https://example.invalid/source/primary-009', 'https://example.invalid/source/secondary-009', 'Medical Council', '0000000009', '0000000009', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 22.4727, 70.0537, 'verified', 'published', true, 'Test Data Generator', '2026-09-09'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-010', 'Dr Rudra Sharma (Test 010)', 'Dr Rudra Sharma (Test 010)', 'MBBS, DNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 11, 11, 'Professor & Head', 'Demo Neuro Hospital 10', 'Medical College', 'India', 'Gujarat', 'Kutch', 'Bhuj', '370001', '0000000010', '0000000010', '0000000010', '0000000010', 'dummy.doctor.010@example.invalid', 'https://example.invalid/doctors/test-010', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10010', 'Gujarat', 'Active', '2026-02-10'::date, 'https://example.invalid/source/primary-010', 'https://example.invalid/source/secondary-010', 'Professional Society', '0000000010', '0000000010', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"Hindi", "English"}'::text[], 23.2459, 69.6649, 'unverified', 'published', false, 'Test Data Generator', '2026-09-10'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-011', 'Dr Anaya Sharma (Test 011)', 'Dr Anaya Sharma (Test 011)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 12, 12, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 11', 'Corporate Hospital', 'India', 'Gujarat', 'Mehsana', 'Mehsana', '384001', '0000000011', '0000000011', '0000000011', '0000000011', 'dummy.doctor.011@example.invalid', 'https://example.invalid/doctors/test-011', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10011', 'Gujarat', 'Pending Verification', '2026-03-11'::date, 'https://example.invalid/source/primary-011', 'https://example.invalid/source/secondary-011', 'Public Directory', '0000000011', '0000000011', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 23.584, 72.3693, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-11'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-012', 'Dr Diya Sharma (Test 012)', 'Dr Diya Sharma (Test 012)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 13, 13, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 12', 'Independent', 'India', 'Gujarat', 'Banaskantha', 'Palanpur', '385001', '0000000012', '0000000012', '0000000012', '0000000012', 'dummy.doctor.012@example.invalid', 'https://example.invalid/doctors/test-012', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10012', 'Gujarat', 'Unknown', '2026-04-12'::date, 'https://example.invalid/source/primary-012', 'https://example.invalid/source/secondary-012', 'Other', '0000000012', '0000000012', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 24.1704, 72.4366, 'verified', 'published', true, 'Test Data Generator', '2026-09-12'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-013', 'Dr Myra Sharma (Test 013)', 'Dr Myra Sharma (Test 013)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 14, 14, 'Associate Consultant', 'Demo Neuro Hospital 13', 'Private', 'India', 'Gujarat', 'Patan', 'Patan', '384265', '0000000013', '0000000013', '0000000013', '0000000013', 'dummy.doctor.013@example.invalid', 'https://example.invalid/doctors/test-013', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10013', 'Gujarat', 'Active', '2026-05-13'::date, 'https://example.invalid/source/primary-013', 'https://example.invalid/source/secondary-013', 'Doctor Submitted', '0000000013', '0000000013', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 23.8493, 72.1306, 'unverified', 'published', false, 'Test Data Generator', '2026-09-13'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-014', 'Dr Aadhya Sharma (Test 014)', 'Dr Aadhya Sharma (Test 014)', 'MBBS, DNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 15, 15, 'Assistant Professor', 'Demo Neuro Hospital 14', 'Government', 'India', 'Gujarat', 'Kheda', 'Nadiad', '387001', '0000000014', '0000000014', '0000000014', '0000000014', 'dummy.doctor.014@example.invalid', 'https://example.invalid/doctors/test-014', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10014', 'Gujarat', 'Pending Verification', '2026-06-14'::date, 'https://example.invalid/source/primary-014', 'https://example.invalid/source/secondary-014', 'Hospital Website', '0000000014', '0000000014', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 22.6936, 72.8694, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-14'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-015', 'Dr Ira Sharma (Test 015)', 'Dr Ira Sharma (Test 015)', 'MBBS, MS, DrNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 16, 16, 'Professor & Head', 'Demo Neuro Hospital 15', 'Trust / NGO', 'India', 'Gujarat', 'Anand', 'Anand', '388001', '0000000015', '0000000015', '0000000015', '0000000015', 'dummy.doctor.015@example.invalid', 'https://example.invalid/doctors/test-015', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10015', 'Gujarat', 'Unknown', '2026-07-15'::date, 'https://example.invalid/source/primary-015', 'https://example.invalid/source/secondary-015', 'Medical Council', '0000000015', '0000000015', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 22.5685, 72.9229, 'verified', 'published', true, 'Test Data Generator', '2026-09-15'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-016', 'Dr Kiara Sharma (Test 016)', 'Dr Kiara Sharma (Test 016)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 17, 17, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 16', 'Medical College', 'India', 'Gujarat', 'Bharuch', 'Bharuch', '392001', '0000000016', '0000000016', '0000000016', '0000000016', 'dummy.doctor.016@example.invalid', 'https://example.invalid/doctors/test-016', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10016', 'Gujarat', 'Active', '2026-08-16'::date, 'https://example.invalid/source/primary-016', 'https://example.invalid/source/secondary-016', 'Professional Society', '0000000016', '0000000016', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 21.7011, 72.9919, 'unverified', 'published', false, 'Test Data Generator', '2026-09-16'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-017', 'Dr Riya Sharma (Test 017)', 'Dr Riya Sharma (Test 017)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 18, 18, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 17', 'Corporate Hospital', 'India', 'Gujarat', 'Navsari', 'Navsari', '396445', '0000000017', '0000000017', '0000000017', '0000000017', 'dummy.doctor.017@example.invalid', 'https://example.invalid/doctors/test-017', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10017', 'Gujarat', 'Pending Verification', '2026-01-17'::date, 'https://example.invalid/source/primary-017', 'https://example.invalid/source/secondary-017', 'Public Directory', '0000000017', '0000000017', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 20.9447, 72.95, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-17'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-018', 'Dr Meera Sharma (Test 018)', 'Dr Meera Sharma (Test 018)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 19, 19, 'Associate Consultant', 'Demo Neuro Hospital 18', 'Independent', 'India', 'Gujarat', 'Valsad', 'Valsad', '396001', '0000000018', '0000000018', '0000000018', '0000000018', 'dummy.doctor.018@example.invalid', 'https://example.invalid/doctors/test-018', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10018', 'Gujarat', 'Unknown', '2026-02-18'::date, 'https://example.invalid/source/primary-018', 'https://example.invalid/source/secondary-018', 'Other', '0000000018', '0000000018', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"Hindi", "English"}'::text[], 20.5992, 72.9342, 'verified', 'published', true, 'Test Data Generator', '2026-09-01'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-019', 'Dr Avni Sharma (Test 019)', 'Dr Avni Sharma (Test 019)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 20, 20, 'Assistant Professor', 'Demo Neuro Hospital 19', 'Private', 'India', 'Gujarat', 'Junagadh', 'Junagadh', '362001', '0000000019', '0000000019', '0000000019', '0000000019', 'dummy.doctor.019@example.invalid', 'https://example.invalid/doctors/test-019', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10019', 'Gujarat', 'Active', '2026-03-19'::date, 'https://example.invalid/source/primary-019', 'https://example.invalid/source/secondary-019', 'Doctor Submitted', '0000000019', '0000000019', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 21.5242, 70.4599, 'unverified', 'published', false, 'Test Data Generator', '2026-09-02'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-020', 'Dr Tara Sharma (Test 020)', 'Dr Tara Sharma (Test 020)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 21, 21, 'Professor & Head', 'Demo Neuro Hospital 20', 'Government', 'India', 'Gujarat', 'Amreli', 'Amreli', '365601', '0000000020', '0000000020', '0000000020', '0000000020', 'dummy.doctor.020@example.invalid', 'https://example.invalid/doctors/test-020', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10020', 'Gujarat', 'Pending Verification', '2026-04-20'::date, 'https://example.invalid/source/primary-020', 'https://example.invalid/source/secondary-020', 'Hospital Website', '0000000020', '0000000020', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 21.6072, 71.2261, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-03'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-021', 'Dr Aarav Patel (Test 021)', 'Dr Aarav Patel (Test 021)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 22, 22, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 21', 'Trust / NGO', 'India', 'Gujarat', 'Ahmedabad', 'Ahmedabad', '380001', '0000000021', '0000000021', '0000000021', '0000000021', 'dummy.doctor.021@example.invalid', 'https://example.invalid/doctors/test-021', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10021', 'Gujarat', 'Unknown', '2026-05-21'::date, 'https://example.invalid/source/primary-021', 'https://example.invalid/source/secondary-021', 'Medical Council', '0000000021', '0000000021', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 23.0185, 72.5774, 'verified', 'published', true, 'Test Data Generator', '2026-09-04'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-022', 'Dr Vivaan Patel (Test 022)', 'Dr Vivaan Patel (Test 022)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 23, 23, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 22', 'Medical College', 'India', 'Gujarat', 'Sabarkantha', 'Himmatnagar', '383001', '0000000022', '0000000022', '0000000022', '0000000022', 'dummy.doctor.022@example.invalid', 'https://example.invalid/doctors/test-022', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10022', 'Gujarat', 'Active', '2026-06-22'::date, 'https://example.invalid/source/primary-022', 'https://example.invalid/source/secondary-022', 'Professional Society', '0000000022', '0000000022', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"Hindi", "English"}'::text[], 23.5949, 72.957, 'unverified', 'published', false, 'Test Data Generator', '2026-09-05'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-023', 'Dr Aditya Patel (Test 023)', 'Dr Aditya Patel (Test 023)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 24, 24, 'Associate Consultant', 'Demo Neuro Hospital 23', 'Corporate Hospital', 'India', 'Gujarat', 'Aravalli', 'Modasa', '383315', '0000000023', '0000000023', '0000000023', '0000000023', 'dummy.doctor.023@example.invalid', 'https://example.invalid/doctors/test-023', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10023', 'Gujarat', 'Pending Verification', '2026-07-23'::date, 'https://example.invalid/source/primary-023', 'https://example.invalid/source/secondary-023', 'Public Directory', '0000000023', '0000000023', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 23.4625, 73.2946, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-06'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-024', 'Dr Arjun Patel (Test 024)', 'Dr Arjun Patel (Test 024)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 25, 25, 'Assistant Professor', 'Demo Neuro Hospital 24', 'Independent', 'India', 'Gujarat', 'Gandhinagar', 'Gandhinagar', '382010', '0000000024', '0000000024', '0000000024', '0000000024', 'dummy.doctor.024@example.invalid', 'https://example.invalid/doctors/test-024', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10024', 'Gujarat', 'Unknown', '2026-08-24'::date, 'https://example.invalid/source/primary-024', 'https://example.invalid/source/secondary-024', 'Other', '0000000024', '0000000024', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 23.2176, 72.6349, 'verified', 'published', true, 'Test Data Generator', '2026-09-07'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-025', 'Dr Reyansh Patel (Test 025)', 'Dr Reyansh Patel (Test 025)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 26, 26, 'Professor & Head', 'Demo Neuro Hospital 25', 'Private', 'India', 'Gujarat', 'Vadodara', 'Vadodara', '390001', '0000000025', '0000000025', '0000000025', '0000000025', 'dummy.doctor.025@example.invalid', 'https://example.invalid/doctors/test-025', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10025', 'Gujarat', 'Active', '2026-01-25'::date, 'https://example.invalid/source/primary-025', 'https://example.invalid/source/secondary-025', 'Doctor Submitted', '0000000025', '0000000025', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 22.3112, 73.1812, 'unverified', 'published', false, 'Test Data Generator', '2026-09-08'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-026', 'Dr Ishaan Patel (Test 026)', 'Dr Ishaan Patel (Test 026)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 27, 27, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 01', 'Government', 'India', 'Gujarat', 'Surat', 'Surat', '395003', '0000000026', '0000000026', '0000000026', '0000000026', 'dummy.doctor.026@example.invalid', 'https://example.invalid/doctors/test-026', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10026', 'Gujarat', 'Pending Verification', '2026-02-26'::date, 'https://example.invalid/source/primary-026', 'https://example.invalid/source/secondary-026', 'Hospital Website', '0000000026', '0000000026', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 21.1662, 72.8331, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-09'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-027', 'Dr Kabir Patel (Test 027)', 'Dr Kabir Patel (Test 027)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 28, 28, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 02', 'Trust / NGO', 'India', 'Gujarat', 'Rajkot', 'Rajkot', '360001', '0000000027', '0000000027', '0000000027', '0000000027', 'dummy.doctor.027@example.invalid', 'https://example.invalid/doctors/test-027', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10027', 'Gujarat', 'Unknown', '2026-03-27'::date, 'https://example.invalid/source/primary-027', 'https://example.invalid/source/secondary-027', 'Medical Council', '0000000027', '0000000027', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 22.3019, 70.8062, 'verified', 'published', true, 'Test Data Generator', '2026-09-10'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-028', 'Dr Atharv Patel (Test 028)', 'Dr Atharv Patel (Test 028)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 29, 29, 'Associate Consultant', 'Demo Neuro Hospital 03', 'Medical College', 'India', 'Gujarat', 'Bhavnagar', 'Bhavnagar', '364001', '0000000028', '0000000028', '0000000028', '0000000028', 'dummy.doctor.028@example.invalid', 'https://example.invalid/doctors/test-028', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10028', 'Gujarat', 'Active', '2026-04-01'::date, 'https://example.invalid/source/primary-028', 'https://example.invalid/source/secondary-028', 'Professional Society', '0000000028', '0000000028', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 21.7645, 72.1579, 'unverified', 'published', false, 'Test Data Generator', '2026-09-11'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-029', 'Dr Krish Patel (Test 029)', 'Dr Krish Patel (Test 029)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 30, 30, 'Assistant Professor', 'Demo Neuro Hospital 04', 'Corporate Hospital', 'India', 'Gujarat', 'Jamnagar', 'Jamnagar', '361001', '0000000029', '0000000029', '0000000029', '0000000029', 'dummy.doctor.029@example.invalid', 'https://example.invalid/doctors/test-029', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10029', 'Gujarat', 'Pending Verification', '2026-05-02'::date, 'https://example.invalid/source/primary-029', 'https://example.invalid/source/secondary-029', 'Public Directory', '0000000029', '0000000029', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 22.4727, 70.0517, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-12'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-030', 'Dr Rudra Patel (Test 030)', 'Dr Rudra Patel (Test 030)', 'MBBS, DNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 2, 2, 'Professor & Head', 'Demo Neuro Hospital 05', 'Independent', 'India', 'Gujarat', 'Kutch', 'Bhuj', '370001', '0000000030', '0000000030', '0000000030', '0000000030', 'dummy.doctor.030@example.invalid', 'https://example.invalid/doctors/test-030', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10030', 'Gujarat', 'Unknown', '2026-06-03'::date, 'https://example.invalid/source/primary-030', 'https://example.invalid/source/secondary-030', 'Other', '0000000030', '0000000030', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'yes', 'no', '{"Hindi", "English"}'::text[], 23.2459, 69.6629, 'verified', 'published', true, 'Test Data Generator', '2026-09-13'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-031', 'Dr Anaya Patel (Test 031)', 'Dr Anaya Patel (Test 031)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 3, 3, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 06', 'Private', 'India', 'Gujarat', 'Mehsana', 'Mehsana', '384001', '0000000031', '0000000031', '0000000031', '0000000031', 'dummy.doctor.031@example.invalid', 'https://example.invalid/doctors/test-031', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10031', 'Gujarat', 'Active', '2026-07-04'::date, 'https://example.invalid/source/primary-031', 'https://example.invalid/source/secondary-031', 'Doctor Submitted', '0000000031', '0000000031', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 23.584, 72.3673, 'unverified', 'published', false, 'Test Data Generator', '2026-09-14'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-032', 'Dr Diya Patel (Test 032)', 'Dr Diya Patel (Test 032)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 4, 4, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 07', 'Government', 'India', 'Gujarat', 'Banaskantha', 'Palanpur', '385001', '0000000032', '0000000032', '0000000032', '0000000032', 'dummy.doctor.032@example.invalid', 'https://example.invalid/doctors/test-032', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10032', 'Gujarat', 'Pending Verification', '2026-08-05'::date, 'https://example.invalid/source/primary-032', 'https://example.invalid/source/secondary-032', 'Hospital Website', '0000000032', '0000000032', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 24.1704, 72.4346, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-15'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-033', 'Dr Myra Patel (Test 033)', 'Dr Myra Patel (Test 033)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 5, 5, 'Associate Consultant', 'Demo Neuro Hospital 08', 'Trust / NGO', 'India', 'Gujarat', 'Patan', 'Patan', '384265', '0000000033', '0000000033', '0000000033', '0000000033', 'dummy.doctor.033@example.invalid', 'https://example.invalid/doctors/test-033', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10033', 'Gujarat', 'Unknown', '2026-01-06'::date, 'https://example.invalid/source/primary-033', 'https://example.invalid/source/secondary-033', 'Medical Council', '0000000033', '0000000033', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 23.8493, 72.1286, 'verified', 'published', true, 'Test Data Generator', '2026-09-16'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-034', 'Dr Aadhya Patel (Test 034)', 'Dr Aadhya Patel (Test 034)', 'MBBS, DNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 6, 6, 'Assistant Professor', 'Demo Neuro Hospital 09', 'Medical College', 'India', 'Gujarat', 'Kheda', 'Nadiad', '387001', '0000000034', '0000000034', '0000000034', '0000000034', 'dummy.doctor.034@example.invalid', 'https://example.invalid/doctors/test-034', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10034', 'Gujarat', 'Active', '2026-02-07'::date, 'https://example.invalid/source/primary-034', 'https://example.invalid/source/secondary-034', 'Professional Society', '0000000034', '0000000034', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"Hindi", "English"}'::text[], 22.6936, 72.8674, 'unverified', 'published', false, 'Test Data Generator', '2026-09-17'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-035', 'Dr Ira Patel (Test 035)', 'Dr Ira Patel (Test 035)', 'MBBS, MS, DrNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 7, 7, 'Professor & Head', 'Demo Neuro Hospital 10', 'Corporate Hospital', 'India', 'Gujarat', 'Anand', 'Anand', '388001', '0000000035', '0000000035', '0000000035', '0000000035', 'dummy.doctor.035@example.invalid', 'https://example.invalid/doctors/test-035', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10035', 'Gujarat', 'Pending Verification', '2026-03-08'::date, 'https://example.invalid/source/primary-035', 'https://example.invalid/source/secondary-035', 'Public Directory', '0000000035', '0000000035', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 22.5685, 72.9349, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-01'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-036', 'Dr Kiara Patel (Test 036)', 'Dr Kiara Patel (Test 036)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 8, 8, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 11', 'Independent', 'India', 'Gujarat', 'Bharuch', 'Bharuch', '392001', '0000000036', '0000000036', '0000000036', '0000000036', 'dummy.doctor.036@example.invalid', 'https://example.invalid/doctors/test-036', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10036', 'Gujarat', 'Unknown', '2026-04-09'::date, 'https://example.invalid/source/primary-036', 'https://example.invalid/source/secondary-036', 'Other', '0000000036', '0000000036', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 21.7011, 72.9899, 'verified', 'published', true, 'Test Data Generator', '2026-09-02'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-037', 'Dr Riya Patel (Test 037)', 'Dr Riya Patel (Test 037)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 9, 9, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 12', 'Private', 'India', 'Gujarat', 'Navsari', 'Navsari', '396445', '0000000037', '0000000037', '0000000037', '0000000037', 'dummy.doctor.037@example.invalid', 'https://example.invalid/doctors/test-037', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10037', 'Gujarat', 'Active', '2026-05-10'::date, 'https://example.invalid/source/primary-037', 'https://example.invalid/source/secondary-037', 'Doctor Submitted', '0000000037', '0000000037', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 20.9447, 72.948, 'unverified', 'published', false, 'Test Data Generator', '2026-09-03'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-038', 'Dr Meera Patel (Test 038)', 'Dr Meera Patel (Test 038)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 10, 10, 'Associate Consultant', 'Demo Neuro Hospital 13', 'Government', 'India', 'Gujarat', 'Valsad', 'Valsad', '396001', '0000000038', '0000000038', '0000000038', '0000000038', 'dummy.doctor.038@example.invalid', 'https://example.invalid/doctors/test-038', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10038', 'Gujarat', 'Pending Verification', '2026-06-11'::date, 'https://example.invalid/source/primary-038', 'https://example.invalid/source/secondary-038', 'Hospital Website', '0000000038', '0000000038', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 20.5992, 72.9322, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-04'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-039', 'Dr Avni Patel (Test 039)', 'Dr Avni Patel (Test 039)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 11, 11, 'Assistant Professor', 'Demo Neuro Hospital 14', 'Trust / NGO', 'India', 'Gujarat', 'Junagadh', 'Junagadh', '362001', '0000000039', '0000000039', '0000000039', '0000000039', 'dummy.doctor.039@example.invalid', 'https://example.invalid/doctors/test-039', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10039', 'Gujarat', 'Unknown', '2026-07-12'::date, 'https://example.invalid/source/primary-039', 'https://example.invalid/source/secondary-039', 'Medical Council', '0000000039', '0000000039', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 21.5242, 70.4579, 'verified', 'published', true, 'Test Data Generator', '2026-09-05'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-040', 'Dr Tara Patel (Test 040)', 'Dr Tara Patel (Test 040)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 12, 12, 'Professor & Head', 'Demo Neuro Hospital 15', 'Medical College', 'India', 'Gujarat', 'Amreli', 'Amreli', '365601', '0000000040', '0000000040', '0000000040', '0000000040', 'dummy.doctor.040@example.invalid', 'https://example.invalid/doctors/test-040', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10040', 'Gujarat', 'Active', '2026-08-13'::date, 'https://example.invalid/source/primary-040', 'https://example.invalid/source/secondary-040', 'Professional Society', '0000000040', '0000000040', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 21.6072, 71.2241, 'unverified', 'published', false, 'Test Data Generator', '2026-09-06'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-041', 'Dr Aarav Mehta (Test 041)', 'Dr Aarav Mehta (Test 041)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 13, 13, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 16', 'Corporate Hospital', 'India', 'Gujarat', 'Ahmedabad', 'Ahmedabad', '380001', '0000000041', '0000000041', '0000000041', '0000000041', 'dummy.doctor.041@example.invalid', 'https://example.invalid/doctors/test-041', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10041', 'Gujarat', 'Pending Verification', '2026-01-14'::date, 'https://example.invalid/source/primary-041', 'https://example.invalid/source/secondary-041', 'Public Directory', '0000000041', '0000000041', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 23.0185, 72.5754, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-07'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-042', 'Dr Vivaan Mehta (Test 042)', 'Dr Vivaan Mehta (Test 042)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 14, 14, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 17', 'Independent', 'India', 'Gujarat', 'Sabarkantha', 'Himmatnagar', '383001', '0000000042', '0000000042', '0000000042', '0000000042', 'dummy.doctor.042@example.invalid', 'https://example.invalid/doctors/test-042', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10042', 'Gujarat', 'Unknown', '2026-02-15'::date, 'https://example.invalid/source/primary-042', 'https://example.invalid/source/secondary-042', 'Other', '0000000042', '0000000042', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'yes', 'no', '{"Hindi", "English"}'::text[], 23.5949, 72.969, 'verified', 'published', true, 'Test Data Generator', '2026-09-08'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-043', 'Dr Aditya Mehta (Test 043)', 'Dr Aditya Mehta (Test 043)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 15, 15, 'Associate Consultant', 'Demo Neuro Hospital 18', 'Private', 'India', 'Gujarat', 'Aravalli', 'Modasa', '383315', '0000000043', '0000000043', '0000000043', '0000000043', 'dummy.doctor.043@example.invalid', 'https://example.invalid/doctors/test-043', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10043', 'Gujarat', 'Active', '2026-03-16'::date, 'https://example.invalid/source/primary-043', 'https://example.invalid/source/secondary-043', 'Doctor Submitted', '0000000043', '0000000043', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 23.4625, 73.2926, 'unverified', 'published', false, 'Test Data Generator', '2026-09-09'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-044', 'Dr Arjun Mehta (Test 044)', 'Dr Arjun Mehta (Test 044)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 16, 16, 'Assistant Professor', 'Demo Neuro Hospital 19', 'Government', 'India', 'Gujarat', 'Gandhinagar', 'Gandhinagar', '382010', '0000000044', '0000000044', '0000000044', '0000000044', 'dummy.doctor.044@example.invalid', 'https://example.invalid/doctors/test-044', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10044', 'Gujarat', 'Pending Verification', '2026-04-17'::date, 'https://example.invalid/source/primary-044', 'https://example.invalid/source/secondary-044', 'Hospital Website', '0000000044', '0000000044', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 23.2176, 72.6329, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-10'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-045', 'Dr Reyansh Mehta (Test 045)', 'Dr Reyansh Mehta (Test 045)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 17, 17, 'Professor & Head', 'Demo Neuro Hospital 20', 'Trust / NGO', 'India', 'Gujarat', 'Vadodara', 'Vadodara', '390001', '0000000045', '0000000045', '0000000045', '0000000045', 'dummy.doctor.045@example.invalid', 'https://example.invalid/doctors/test-045', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10045', 'Gujarat', 'Unknown', '2026-05-18'::date, 'https://example.invalid/source/primary-045', 'https://example.invalid/source/secondary-045', 'Medical Council', '0000000045', '0000000045', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 22.3112, 73.1792, 'verified', 'published', true, 'Test Data Generator', '2026-09-11'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-046', 'Dr Ishaan Mehta (Test 046)', 'Dr Ishaan Mehta (Test 046)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 18, 18, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 21', 'Medical College', 'India', 'Gujarat', 'Surat', 'Surat', '395003', '0000000046', '0000000046', '0000000046', '0000000046', 'dummy.doctor.046@example.invalid', 'https://example.invalid/doctors/test-046', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10046', 'Gujarat', 'Active', '2026-06-19'::date, 'https://example.invalid/source/primary-046', 'https://example.invalid/source/secondary-046', 'Professional Society', '0000000046', '0000000046', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"Hindi", "English"}'::text[], 21.1662, 72.8311, 'unverified', 'published', false, 'Test Data Generator', '2026-09-12'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-047', 'Dr Kabir Mehta (Test 047)', 'Dr Kabir Mehta (Test 047)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 19, 19, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 22', 'Corporate Hospital', 'India', 'Gujarat', 'Rajkot', 'Rajkot', '360001', '0000000047', '0000000047', '0000000047', '0000000047', 'dummy.doctor.047@example.invalid', 'https://example.invalid/doctors/test-047', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10047', 'Gujarat', 'Pending Verification', '2026-07-20'::date, 'https://example.invalid/source/primary-047', 'https://example.invalid/source/secondary-047', 'Public Directory', '0000000047', '0000000047', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 22.3019, 70.8042, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-13'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-048', 'Dr Atharv Mehta (Test 048)', 'Dr Atharv Mehta (Test 048)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 20, 20, 'Associate Consultant', 'Demo Neuro Hospital 23', 'Independent', 'India', 'Gujarat', 'Bhavnagar', 'Bhavnagar', '364001', '0000000048', '0000000048', '0000000048', '0000000048', 'dummy.doctor.048@example.invalid', 'https://example.invalid/doctors/test-048', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10048', 'Gujarat', 'Unknown', '2026-08-21'::date, 'https://example.invalid/source/primary-048', 'https://example.invalid/source/secondary-048', 'Other', '0000000048', '0000000048', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 21.7645, 72.1559, 'verified', 'published', true, 'Test Data Generator', '2026-09-14'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-049', 'Dr Krish Mehta (Test 049)', 'Dr Krish Mehta (Test 049)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 21, 21, 'Assistant Professor', 'Demo Neuro Hospital 24', 'Private', 'India', 'Gujarat', 'Jamnagar', 'Jamnagar', '361001', '0000000049', '0000000049', '0000000049', '0000000049', 'dummy.doctor.049@example.invalid', 'https://example.invalid/doctors/test-049', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10049', 'Gujarat', 'Active', '2026-01-22'::date, 'https://example.invalid/source/primary-049', 'https://example.invalid/source/secondary-049', 'Doctor Submitted', '0000000049', '0000000049', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 22.4727, 70.0637, 'unverified', 'published', false, 'Test Data Generator', '2026-09-15'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-050', 'Dr Rudra Mehta (Test 050)', 'Dr Rudra Mehta (Test 050)', 'MBBS, DNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 22, 22, 'Professor & Head', 'Demo Neuro Hospital 25', 'Government', 'India', 'Gujarat', 'Kutch', 'Bhuj', '370001', '0000000050', '0000000050', '0000000050', '0000000050', 'dummy.doctor.050@example.invalid', 'https://example.invalid/doctors/test-050', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10050', 'Gujarat', 'Pending Verification', '2026-02-23'::date, 'https://example.invalid/source/primary-050', 'https://example.invalid/source/secondary-050', 'Hospital Website', '0000000050', '0000000050', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 23.2459, 69.6609, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-16'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-051', 'Dr Anaya Mehta (Test 051)', 'Dr Anaya Mehta (Test 051)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 23, 23, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 01', 'Trust / NGO', 'India', 'Gujarat', 'Mehsana', 'Mehsana', '384001', '0000000051', '0000000051', '0000000051', '0000000051', 'dummy.doctor.051@example.invalid', 'https://example.invalid/doctors/test-051', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10051', 'Gujarat', 'Unknown', '2026-03-24'::date, 'https://example.invalid/source/primary-051', 'https://example.invalid/source/secondary-051', 'Medical Council', '0000000051', '0000000051', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 23.584, 72.3653, 'verified', 'published', true, 'Test Data Generator', '2026-09-17'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-052', 'Dr Diya Mehta (Test 052)', 'Dr Diya Mehta (Test 052)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 24, 24, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 02', 'Medical College', 'India', 'Gujarat', 'Banaskantha', 'Palanpur', '385001', '0000000052', '0000000052', '0000000052', '0000000052', 'dummy.doctor.052@example.invalid', 'https://example.invalid/doctors/test-052', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10052', 'Gujarat', 'Active', '2026-04-25'::date, 'https://example.invalid/source/primary-052', 'https://example.invalid/source/secondary-052', 'Professional Society', '0000000052', '0000000052', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 24.1704, 72.4326, 'unverified', 'published', false, 'Test Data Generator', '2026-09-01'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-053', 'Dr Myra Mehta (Test 053)', 'Dr Myra Mehta (Test 053)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 25, 25, 'Associate Consultant', 'Demo Neuro Hospital 03', 'Corporate Hospital', 'India', 'Gujarat', 'Patan', 'Patan', '384265', '0000000053', '0000000053', '0000000053', '0000000053', 'dummy.doctor.053@example.invalid', 'https://example.invalid/doctors/test-053', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10053', 'Gujarat', 'Pending Verification', '2026-05-26'::date, 'https://example.invalid/source/primary-053', 'https://example.invalid/source/secondary-053', 'Public Directory', '0000000053', '0000000053', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 23.8493, 72.1266, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-02'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-054', 'Dr Aadhya Mehta (Test 054)', 'Dr Aadhya Mehta (Test 054)', 'MBBS, DNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 26, 26, 'Assistant Professor', 'Demo Neuro Hospital 04', 'Independent', 'India', 'Gujarat', 'Kheda', 'Nadiad', '387001', '0000000054', '0000000054', '0000000054', '0000000054', 'dummy.doctor.054@example.invalid', 'https://example.invalid/doctors/test-054', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10054', 'Gujarat', 'Unknown', '2026-06-27'::date, 'https://example.invalid/source/primary-054', 'https://example.invalid/source/secondary-054', 'Other', '0000000054', '0000000054', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"Hindi", "English"}'::text[], 22.6936, 72.8654, 'verified', 'published', true, 'Test Data Generator', '2026-09-03'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-055', 'Dr Ira Mehta (Test 055)', 'Dr Ira Mehta (Test 055)', 'MBBS, MS, DrNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 27, 27, 'Professor & Head', 'Demo Neuro Hospital 05', 'Private', 'India', 'Gujarat', 'Anand', 'Anand', '388001', '0000000055', '0000000055', '0000000055', '0000000055', 'dummy.doctor.055@example.invalid', 'https://example.invalid/doctors/test-055', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10055', 'Gujarat', 'Active', '2026-07-01'::date, 'https://example.invalid/source/primary-055', 'https://example.invalid/source/secondary-055', 'Doctor Submitted', '0000000055', '0000000055', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 22.5685, 72.9329, 'unverified', 'published', false, 'Test Data Generator', '2026-09-04'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-056', 'Dr Kiara Mehta (Test 056)', 'Dr Kiara Mehta (Test 056)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 28, 28, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 06', 'Government', 'India', 'Gujarat', 'Bharuch', 'Bharuch', '392001', '0000000056', '0000000056', '0000000056', '0000000056', 'dummy.doctor.056@example.invalid', 'https://example.invalid/doctors/test-056', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10056', 'Gujarat', 'Pending Verification', '2026-08-02'::date, 'https://example.invalid/source/primary-056', 'https://example.invalid/source/secondary-056', 'Hospital Website', '0000000056', '0000000056', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 21.7011, 73.0019, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-05'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-057', 'Dr Riya Mehta (Test 057)', 'Dr Riya Mehta (Test 057)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 29, 29, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 07', 'Trust / NGO', 'India', 'Gujarat', 'Navsari', 'Navsari', '396445', '0000000057', '0000000057', '0000000057', '0000000057', 'dummy.doctor.057@example.invalid', 'https://example.invalid/doctors/test-057', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10057', 'Gujarat', 'Unknown', '2026-01-03'::date, 'https://example.invalid/source/primary-057', 'https://example.invalid/source/secondary-057', 'Medical Council', '0000000057', '0000000057', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 20.9447, 72.946, 'verified', 'published', true, 'Test Data Generator', '2026-09-06'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-058', 'Dr Meera Mehta (Test 058)', 'Dr Meera Mehta (Test 058)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 30, 30, 'Associate Consultant', 'Demo Neuro Hospital 08', 'Medical College', 'India', 'Gujarat', 'Valsad', 'Valsad', '396001', '0000000058', '0000000058', '0000000058', '0000000058', 'dummy.doctor.058@example.invalid', 'https://example.invalid/doctors/test-058', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10058', 'Gujarat', 'Active', '2026-02-04'::date, 'https://example.invalid/source/primary-058', 'https://example.invalid/source/secondary-058', 'Professional Society', '0000000058', '0000000058', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'no', 'unknown', '{"Hindi", "English"}'::text[], 20.5992, 72.9302, 'unverified', 'published', false, 'Test Data Generator', '2026-09-07'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-059', 'Dr Avni Mehta (Test 059)', 'Dr Avni Mehta (Test 059)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 2, 2, 'Assistant Professor', 'Demo Neuro Hospital 09', 'Corporate Hospital', 'India', 'Gujarat', 'Junagadh', 'Junagadh', '362001', '0000000059', '0000000059', '0000000059', '0000000059', 'dummy.doctor.059@example.invalid', 'https://example.invalid/doctors/test-059', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10059', 'Gujarat', 'Pending Verification', '2026-03-05'::date, 'https://example.invalid/source/primary-059', 'https://example.invalid/source/secondary-059', 'Public Directory', '0000000059', '0000000059', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 21.5242, 70.4559, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-08'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-060', 'Dr Tara Mehta (Test 060)', 'Dr Tara Mehta (Test 060)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 3, 3, 'Professor & Head', 'Demo Neuro Hospital 10', 'Independent', 'India', 'Gujarat', 'Amreli', 'Amreli', '365601', '0000000060', '0000000060', '0000000060', '0000000060', 'dummy.doctor.060@example.invalid', 'https://example.invalid/doctors/test-060', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10060', 'Gujarat', 'Unknown', '2026-04-06'::date, 'https://example.invalid/source/primary-060', 'https://example.invalid/source/secondary-060', 'Other', '0000000060', '0000000060', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 21.6072, 71.2221, 'verified', 'published', true, 'Test Data Generator', '2026-09-09'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-061', 'Dr Aarav Shah (Test 061)', 'Dr Aarav Shah (Test 061)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 4, 4, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 11', 'Private', 'India', 'Gujarat', 'Ahmedabad', 'Ahmedabad', '380001', '0000000061', '0000000061', '0000000061', '0000000061', 'dummy.doctor.061@example.invalid', 'https://example.invalid/doctors/test-061', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10061', 'Gujarat', 'Active', '2026-05-07'::date, 'https://example.invalid/source/primary-061', 'https://example.invalid/source/secondary-061', 'Doctor Submitted', '0000000061', '0000000061', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 23.0185, 72.5734, 'unverified', 'published', false, 'Test Data Generator', '2026-09-10'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-062', 'Dr Vivaan Shah (Test 062)', 'Dr Vivaan Shah (Test 062)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 5, 5, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 12', 'Government', 'India', 'Gujarat', 'Sabarkantha', 'Himmatnagar', '383001', '0000000062', '0000000062', '0000000062', '0000000062', 'dummy.doctor.062@example.invalid', 'https://example.invalid/doctors/test-062', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10062', 'Gujarat', 'Pending Verification', '2026-06-08'::date, 'https://example.invalid/source/primary-062', 'https://example.invalid/source/secondary-062', 'Hospital Website', '0000000062', '0000000062', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 23.5949, 72.967, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-11'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-063', 'Dr Aditya Shah (Test 063)', 'Dr Aditya Shah (Test 063)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 6, 6, 'Associate Consultant', 'Demo Neuro Hospital 13', 'Trust / NGO', 'India', 'Gujarat', 'Aravalli', 'Modasa', '383315', '0000000063', '0000000063', '0000000063', '0000000063', 'dummy.doctor.063@example.invalid', 'https://example.invalid/doctors/test-063', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10063', 'Gujarat', 'Unknown', '2026-07-09'::date, 'https://example.invalid/source/primary-063', 'https://example.invalid/source/secondary-063', 'Medical Council', '0000000063', '0000000063', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 23.4625, 73.3046, 'verified', 'published', true, 'Test Data Generator', '2026-09-12'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-064', 'Dr Arjun Shah (Test 064)', 'Dr Arjun Shah (Test 064)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 7, 7, 'Assistant Professor', 'Demo Neuro Hospital 14', 'Medical College', 'India', 'Gujarat', 'Gandhinagar', 'Gandhinagar', '382010', '0000000064', '0000000064', '0000000064', '0000000064', 'dummy.doctor.064@example.invalid', 'https://example.invalid/doctors/test-064', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10064', 'Gujarat', 'Active', '2026-08-10'::date, 'https://example.invalid/source/primary-064', 'https://example.invalid/source/secondary-064', 'Professional Society', '0000000064', '0000000064', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 23.2176, 72.6309, 'unverified', 'published', false, 'Test Data Generator', '2026-09-13'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-065', 'Dr Reyansh Shah (Test 065)', 'Dr Reyansh Shah (Test 065)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 8, 8, 'Professor & Head', 'Demo Neuro Hospital 15', 'Corporate Hospital', 'India', 'Gujarat', 'Vadodara', 'Vadodara', '390001', '0000000065', '0000000065', '0000000065', '0000000065', 'dummy.doctor.065@example.invalid', 'https://example.invalid/doctors/test-065', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10065', 'Gujarat', 'Pending Verification', '2026-01-11'::date, 'https://example.invalid/source/primary-065', 'https://example.invalid/source/secondary-065', 'Public Directory', '0000000065', '0000000065', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 22.3112, 73.1772, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-14'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-066', 'Dr Ishaan Shah (Test 066)', 'Dr Ishaan Shah (Test 066)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 9, 9, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 16', 'Independent', 'India', 'Gujarat', 'Surat', 'Surat', '395003', '0000000066', '0000000066', '0000000066', '0000000066', 'dummy.doctor.066@example.invalid', 'https://example.invalid/doctors/test-066', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10066', 'Gujarat', 'Unknown', '2026-02-12'::date, 'https://example.invalid/source/primary-066', 'https://example.invalid/source/secondary-066', 'Other', '0000000066', '0000000066', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"Hindi", "English"}'::text[], 21.1662, 72.8291, 'verified', 'published', true, 'Test Data Generator', '2026-09-15'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-067', 'Dr Kabir Shah (Test 067)', 'Dr Kabir Shah (Test 067)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 10, 10, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 17', 'Private', 'India', 'Gujarat', 'Rajkot', 'Rajkot', '360001', '0000000067', '0000000067', '0000000067', '0000000067', 'dummy.doctor.067@example.invalid', 'https://example.invalid/doctors/test-067', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10067', 'Gujarat', 'Active', '2026-03-13'::date, 'https://example.invalid/source/primary-067', 'https://example.invalid/source/secondary-067', 'Doctor Submitted', '0000000067', '0000000067', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 22.3019, 70.8022, 'unverified', 'published', false, 'Test Data Generator', '2026-09-16'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-068', 'Dr Atharv Shah (Test 068)', 'Dr Atharv Shah (Test 068)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 11, 11, 'Associate Consultant', 'Demo Neuro Hospital 18', 'Government', 'India', 'Gujarat', 'Bhavnagar', 'Bhavnagar', '364001', '0000000068', '0000000068', '0000000068', '0000000068', 'dummy.doctor.068@example.invalid', 'https://example.invalid/doctors/test-068', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10068', 'Gujarat', 'Pending Verification', '2026-04-14'::date, 'https://example.invalid/source/primary-068', 'https://example.invalid/source/secondary-068', 'Hospital Website', '0000000068', '0000000068', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 21.7645, 72.1539, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-17'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-069', 'Dr Krish Shah (Test 069)', 'Dr Krish Shah (Test 069)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 12, 12, 'Assistant Professor', 'Demo Neuro Hospital 19', 'Trust / NGO', 'India', 'Gujarat', 'Jamnagar', 'Jamnagar', '361001', '0000000069', '0000000069', '0000000069', '0000000069', 'dummy.doctor.069@example.invalid', 'https://example.invalid/doctors/test-069', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10069', 'Gujarat', 'Unknown', '2026-05-15'::date, 'https://example.invalid/source/primary-069', 'https://example.invalid/source/secondary-069', 'Medical Council', '0000000069', '0000000069', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 22.4727, 70.0617, 'verified', 'published', true, 'Test Data Generator', '2026-09-01'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-070', 'Dr Rudra Shah (Test 070)', 'Dr Rudra Shah (Test 070)', 'MBBS, DNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 13, 13, 'Professor & Head', 'Demo Neuro Hospital 20', 'Medical College', 'India', 'Gujarat', 'Kutch', 'Bhuj', '370001', '0000000070', '0000000070', '0000000070', '0000000070', 'dummy.doctor.070@example.invalid', 'https://example.invalid/doctors/test-070', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10070', 'Gujarat', 'Active', '2026-06-16'::date, 'https://example.invalid/source/primary-070', 'https://example.invalid/source/secondary-070', 'Professional Society', '0000000070', '0000000070', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"Hindi", "English"}'::text[], 23.2459, 69.6729, 'unverified', 'published', false, 'Test Data Generator', '2026-09-02'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-071', 'Dr Anaya Shah (Test 071)', 'Dr Anaya Shah (Test 071)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 14, 14, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 21', 'Corporate Hospital', 'India', 'Gujarat', 'Mehsana', 'Mehsana', '384001', '0000000071', '0000000071', '0000000071', '0000000071', 'dummy.doctor.071@example.invalid', 'https://example.invalid/doctors/test-071', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10071', 'Gujarat', 'Pending Verification', '2026-07-17'::date, 'https://example.invalid/source/primary-071', 'https://example.invalid/source/secondary-071', 'Public Directory', '0000000071', '0000000071', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 23.584, 72.3633, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-03'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-072', 'Dr Diya Shah (Test 072)', 'Dr Diya Shah (Test 072)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 15, 15, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 22', 'Independent', 'India', 'Gujarat', 'Banaskantha', 'Palanpur', '385001', '0000000072', '0000000072', '0000000072', '0000000072', 'dummy.doctor.072@example.invalid', 'https://example.invalid/doctors/test-072', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10072', 'Gujarat', 'Unknown', '2026-08-18'::date, 'https://example.invalid/source/primary-072', 'https://example.invalid/source/secondary-072', 'Other', '0000000072', '0000000072', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 24.1704, 72.4306, 'verified', 'published', true, 'Test Data Generator', '2026-09-04'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-073', 'Dr Myra Shah (Test 073)', 'Dr Myra Shah (Test 073)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 16, 16, 'Associate Consultant', 'Demo Neuro Hospital 23', 'Private', 'India', 'Gujarat', 'Patan', 'Patan', '384265', '0000000073', '0000000073', '0000000073', '0000000073', 'dummy.doctor.073@example.invalid', 'https://example.invalid/doctors/test-073', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10073', 'Gujarat', 'Active', '2026-01-19'::date, 'https://example.invalid/source/primary-073', 'https://example.invalid/source/secondary-073', 'Doctor Submitted', '0000000073', '0000000073', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 23.8493, 72.1246, 'unverified', 'published', false, 'Test Data Generator', '2026-09-05'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-074', 'Dr Aadhya Shah (Test 074)', 'Dr Aadhya Shah (Test 074)', 'MBBS, DNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 17, 17, 'Assistant Professor', 'Demo Neuro Hospital 24', 'Government', 'India', 'Gujarat', 'Kheda', 'Nadiad', '387001', '0000000074', '0000000074', '0000000074', '0000000074', 'dummy.doctor.074@example.invalid', 'https://example.invalid/doctors/test-074', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10074', 'Gujarat', 'Pending Verification', '2026-02-20'::date, 'https://example.invalid/source/primary-074', 'https://example.invalid/source/secondary-074', 'Hospital Website', '0000000074', '0000000074', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 22.6936, 72.8634, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-06'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-075', 'Dr Ira Shah (Test 075)', 'Dr Ira Shah (Test 075)', 'MBBS, MS, DrNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 18, 18, 'Professor & Head', 'Demo Neuro Hospital 25', 'Trust / NGO', 'India', 'Gujarat', 'Anand', 'Anand', '388001', '0000000075', '0000000075', '0000000075', '0000000075', 'dummy.doctor.075@example.invalid', 'https://example.invalid/doctors/test-075', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10075', 'Gujarat', 'Unknown', '2026-03-21'::date, 'https://example.invalid/source/primary-075', 'https://example.invalid/source/secondary-075', 'Medical Council', '0000000075', '0000000075', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 22.5685, 72.9309, 'verified', 'published', true, 'Test Data Generator', '2026-09-07'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-076', 'Dr Kiara Shah (Test 076)', 'Dr Kiara Shah (Test 076)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 19, 19, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 01', 'Medical College', 'India', 'Gujarat', 'Bharuch', 'Bharuch', '392001', '0000000076', '0000000076', '0000000076', '0000000076', 'dummy.doctor.076@example.invalid', 'https://example.invalid/doctors/test-076', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10076', 'Gujarat', 'Active', '2026-04-22'::date, 'https://example.invalid/source/primary-076', 'https://example.invalid/source/secondary-076', 'Professional Society', '0000000076', '0000000076', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 21.7011, 72.9999, 'unverified', 'published', false, 'Test Data Generator', '2026-09-08'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-077', 'Dr Riya Shah (Test 077)', 'Dr Riya Shah (Test 077)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 20, 20, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 02', 'Corporate Hospital', 'India', 'Gujarat', 'Navsari', 'Navsari', '396445', '0000000077', '0000000077', '0000000077', '0000000077', 'dummy.doctor.077@example.invalid', 'https://example.invalid/doctors/test-077', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10077', 'Gujarat', 'Pending Verification', '2026-05-23'::date, 'https://example.invalid/source/primary-077', 'https://example.invalid/source/secondary-077', 'Public Directory', '0000000077', '0000000077', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 20.9447, 72.958, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-09'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-078', 'Dr Meera Shah (Test 078)', 'Dr Meera Shah (Test 078)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 21, 21, 'Associate Consultant', 'Demo Neuro Hospital 03', 'Independent', 'India', 'Gujarat', 'Valsad', 'Valsad', '396001', '0000000078', '0000000078', '0000000078', '0000000078', 'dummy.doctor.078@example.invalid', 'https://example.invalid/doctors/test-078', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10078', 'Gujarat', 'Unknown', '2026-06-24'::date, 'https://example.invalid/source/primary-078', 'https://example.invalid/source/secondary-078', 'Other', '0000000078', '0000000078', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"Hindi", "English"}'::text[], 20.5992, 72.9282, 'verified', 'published', true, 'Test Data Generator', '2026-09-10'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-079', 'Dr Avni Shah (Test 079)', 'Dr Avni Shah (Test 079)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 22, 22, 'Assistant Professor', 'Demo Neuro Hospital 04', 'Private', 'India', 'Gujarat', 'Junagadh', 'Junagadh', '362001', '0000000079', '0000000079', '0000000079', '0000000079', 'dummy.doctor.079@example.invalid', 'https://example.invalid/doctors/test-079', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10079', 'Gujarat', 'Active', '2026-07-25'::date, 'https://example.invalid/source/primary-079', 'https://example.invalid/source/secondary-079', 'Doctor Submitted', '0000000079', '0000000079', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 21.5242, 70.4539, 'unverified', 'published', false, 'Test Data Generator', '2026-09-11'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-080', 'Dr Tara Shah (Test 080)', 'Dr Tara Shah (Test 080)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 23, 23, 'Professor & Head', 'Demo Neuro Hospital 05', 'Government', 'India', 'Gujarat', 'Amreli', 'Amreli', '365601', '0000000080', '0000000080', '0000000080', '0000000080', 'dummy.doctor.080@example.invalid', 'https://example.invalid/doctors/test-080', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10080', 'Gujarat', 'Pending Verification', '2026-08-26'::date, 'https://example.invalid/source/primary-080', 'https://example.invalid/source/secondary-080', 'Hospital Website', '0000000080', '0000000080', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 21.6072, 71.2201, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-12'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-081', 'Dr Aarav Joshi (Test 081)', 'Dr Aarav Joshi (Test 081)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 24, 24, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 06', 'Trust / NGO', 'India', 'Gujarat', 'Ahmedabad', 'Ahmedabad', '380001', '0000000081', '0000000081', '0000000081', '0000000081', 'dummy.doctor.081@example.invalid', 'https://example.invalid/doctors/test-081', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10081', 'Gujarat', 'Unknown', '2026-01-27'::date, 'https://example.invalid/source/primary-081', 'https://example.invalid/source/secondary-081', 'Medical Council', '0000000081', '0000000081', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 23.0185, 72.5714, 'verified', 'published', true, 'Test Data Generator', '2026-09-13'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-082', 'Dr Vivaan Joshi (Test 082)', 'Dr Vivaan Joshi (Test 082)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 25, 25, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 07', 'Medical College', 'India', 'Gujarat', 'Sabarkantha', 'Himmatnagar', '383001', '0000000082', '0000000082', '0000000082', '0000000082', 'dummy.doctor.082@example.invalid', 'https://example.invalid/doctors/test-082', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10082', 'Gujarat', 'Active', '2026-02-01'::date, 'https://example.invalid/source/primary-082', 'https://example.invalid/source/secondary-082', 'Professional Society', '0000000082', '0000000082', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"Hindi", "English"}'::text[], 23.5949, 72.965, 'unverified', 'published', false, 'Test Data Generator', '2026-09-14'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-083', 'Dr Aditya Joshi (Test 083)', 'Dr Aditya Joshi (Test 083)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 26, 26, 'Associate Consultant', 'Demo Neuro Hospital 08', 'Corporate Hospital', 'India', 'Gujarat', 'Aravalli', 'Modasa', '383315', '0000000083', '0000000083', '0000000083', '0000000083', 'dummy.doctor.083@example.invalid', 'https://example.invalid/doctors/test-083', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10083', 'Gujarat', 'Pending Verification', '2026-03-02'::date, 'https://example.invalid/source/primary-083', 'https://example.invalid/source/secondary-083', 'Public Directory', '0000000083', '0000000083', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 23.4625, 73.3026, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-15'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-084', 'Dr Arjun Joshi (Test 084)', 'Dr Arjun Joshi (Test 084)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 27, 27, 'Assistant Professor', 'Demo Neuro Hospital 09', 'Independent', 'India', 'Gujarat', 'Gandhinagar', 'Gandhinagar', '382010', '0000000084', '0000000084', '0000000084', '0000000084', 'dummy.doctor.084@example.invalid', 'https://example.invalid/doctors/test-084', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10084', 'Gujarat', 'Unknown', '2026-04-03'::date, 'https://example.invalid/source/primary-084', 'https://example.invalid/source/secondary-084', 'Other', '0000000084', '0000000084', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 23.2176, 72.6429, 'verified', 'published', true, 'Test Data Generator', '2026-09-16'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-085', 'Dr Reyansh Joshi (Test 085)', 'Dr Reyansh Joshi (Test 085)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 28, 28, 'Professor & Head', 'Demo Neuro Hospital 10', 'Private', 'India', 'Gujarat', 'Vadodara', 'Vadodara', '390001', '0000000085', '0000000085', '0000000085', '0000000085', 'dummy.doctor.085@example.invalid', 'https://example.invalid/doctors/test-085', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10085', 'Gujarat', 'Active', '2026-05-04'::date, 'https://example.invalid/source/primary-085', 'https://example.invalid/source/secondary-085', 'Doctor Submitted', '0000000085', '0000000085', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 22.3112, 73.1752, 'unverified', 'published', false, 'Test Data Generator', '2026-09-17'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-086', 'Dr Ishaan Joshi (Test 086)', 'Dr Ishaan Joshi (Test 086)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 29, 29, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 11', 'Government', 'India', 'Gujarat', 'Surat', 'Surat', '395003', '0000000086', '0000000086', '0000000086', '0000000086', 'dummy.doctor.086@example.invalid', 'https://example.invalid/doctors/test-086', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10086', 'Gujarat', 'Pending Verification', '2026-06-05'::date, 'https://example.invalid/source/primary-086', 'https://example.invalid/source/secondary-086', 'Hospital Website', '0000000086', '0000000086', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 21.1662, 72.8271, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-01'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-087', 'Dr Kabir Joshi (Test 087)', 'Dr Kabir Joshi (Test 087)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 30, 30, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 12', 'Trust / NGO', 'India', 'Gujarat', 'Rajkot', 'Rajkot', '360001', '0000000087', '0000000087', '0000000087', '0000000087', 'dummy.doctor.087@example.invalid', 'https://example.invalid/doctors/test-087', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10087', 'Gujarat', 'Unknown', '2026-07-06'::date, 'https://example.invalid/source/primary-087', 'https://example.invalid/source/secondary-087', 'Medical Council', '0000000087', '0000000087', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 22.3019, 70.8002, 'verified', 'published', true, 'Test Data Generator', '2026-09-02'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-088', 'Dr Atharv Joshi (Test 088)', 'Dr Atharv Joshi (Test 088)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 2, 2, 'Associate Consultant', 'Demo Neuro Hospital 13', 'Medical College', 'India', 'Gujarat', 'Bhavnagar', 'Bhavnagar', '364001', '0000000088', '0000000088', '0000000088', '0000000088', 'dummy.doctor.088@example.invalid', 'https://example.invalid/doctors/test-088', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10088', 'Gujarat', 'Active', '2026-08-07'::date, 'https://example.invalid/source/primary-088', 'https://example.invalid/source/secondary-088', 'Professional Society', '0000000088', '0000000088', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 21.7645, 72.1519, 'unverified', 'published', false, 'Test Data Generator', '2026-09-03'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-089', 'Dr Krish Joshi (Test 089)', 'Dr Krish Joshi (Test 089)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 3, 3, 'Assistant Professor', 'Demo Neuro Hospital 14', 'Corporate Hospital', 'India', 'Gujarat', 'Jamnagar', 'Jamnagar', '361001', '0000000089', '0000000089', '0000000089', '0000000089', 'dummy.doctor.089@example.invalid', 'https://example.invalid/doctors/test-089', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10089', 'Gujarat', 'Pending Verification', '2026-01-08'::date, 'https://example.invalid/source/primary-089', 'https://example.invalid/source/secondary-089', 'Public Directory', '0000000089', '0000000089', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', true, 'unknown', 'yes', '{"Gujarati", "Hindi", "English"}'::text[], 22.4727, 70.0597, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-04'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-090', 'Dr Rudra Joshi (Test 090)', 'Dr Rudra Joshi (Test 090)', 'MBBS, DNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 4, 4, 'Professor & Head', 'Demo Neuro Hospital 15', 'Independent', 'India', 'Gujarat', 'Kutch', 'Bhuj', '370001', '0000000090', '0000000090', '0000000090', '0000000090', 'dummy.doctor.090@example.invalid', 'https://example.invalid/doctors/test-090', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10090', 'Gujarat', 'Unknown', '2026-02-09'::date, 'https://example.invalid/source/primary-090', 'https://example.invalid/source/secondary-090', 'Other', '0000000090', '0000000090', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'yes', 'no', '{"Hindi", "English"}'::text[], 23.2459, 69.6709, 'verified', 'published', true, 'Test Data Generator', '2026-09-05'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-091', 'Dr Anaya Joshi (Test 091)', 'Dr Anaya Joshi (Test 091)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Neurotrauma', 5, 5, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 16', 'Private', 'India', 'Gujarat', 'Mehsana', 'Mehsana', '384001', '0000000091', '0000000091', '0000000091', '0000000091', 'dummy.doctor.091@example.invalid', 'https://example.invalid/doctors/test-091', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10091', 'Gujarat', 'Active', '2026-03-10'::date, 'https://example.invalid/source/primary-091', 'https://example.invalid/source/secondary-091', 'Doctor Submitted', '0000000091', '0000000091', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi"}'::text[], 23.584, 72.3753, 'unverified', 'published', false, 'Test Data Generator', '2026-09-06'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-092', 'Dr Diya Joshi (Test 092)', 'Dr Diya Joshi (Test 092)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Brain & Spine Surgery', 6, 6, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 17', 'Government', 'India', 'Gujarat', 'Banaskantha', 'Palanpur', '385001', '0000000092', '0000000092', '0000000092', '0000000092', 'dummy.doctor.092@example.invalid', 'https://example.invalid/doctors/test-092', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10092', 'Gujarat', 'Pending Verification', '2026-04-11'::date, 'https://example.invalid/source/primary-092', 'https://example.invalid/source/secondary-092', 'Hospital Website', '0000000092', '0000000092', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', true, 'unknown', 'yes', '{"English", "Hindi", "Marathi"}'::text[], 24.1704, 72.4286, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-07'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-093', 'Dr Myra Joshi (Test 093)', 'Dr Myra Joshi (Test 093)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Cerebrovascular Neurosurgery', 7, 7, 'Associate Consultant', 'Demo Neuro Hospital 18', 'Trust / NGO', 'India', 'Gujarat', 'Patan', 'Patan', '384265', '0000000093', '0000000093', '0000000093', '0000000093', 'dummy.doctor.093@example.invalid', 'https://example.invalid/doctors/test-093', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10093', 'Gujarat', 'Unknown', '2026-05-12'::date, 'https://example.invalid/source/primary-093', 'https://example.invalid/source/secondary-093', 'Medical Council', '0000000093', '0000000093', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi", "English"}'::text[], 23.8493, 72.1226, 'verified', 'published', true, 'Test Data Generator', '2026-09-08'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-094', 'Dr Aadhya Joshi (Test 094)', 'Dr Aadhya Joshi (Test 094)', 'MBBS, DNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Pediatric Neurosurgery', 8, 8, 'Assistant Professor', 'Demo Neuro Hospital 19', 'Medical College', 'India', 'Gujarat', 'Kheda', 'Nadiad', '387001', '0000000094', '0000000094', '0000000094', '0000000094', 'dummy.doctor.094@example.invalid', 'https://example.invalid/doctors/test-094', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10094', 'Gujarat', 'Active', '2026-06-13'::date, 'https://example.invalid/source/primary-094', 'https://example.invalid/source/secondary-094', 'Professional Society', '0000000094', '0000000094', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'no', 'unknown', '{"Hindi", "English"}'::text[], 22.6936, 72.8614, 'unverified', 'published', false, 'Test Data Generator', '2026-09-09'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-095', 'Dr Ira Joshi (Test 095)', 'Dr Ira Joshi (Test 095)', 'MBBS, MS, DrNB (Neurosurgery)', 'Spine Surgery', 'Spine Surgery', 'Skull Base Surgery', 9, 9, 'Professor & Head', 'Demo Neuro Hospital 20', 'Corporate Hospital', 'India', 'Gujarat', 'Anand', 'Anand', '388001', '0000000095', '0000000095', '0000000095', '0000000095', 'dummy.doctor.095@example.invalid', 'https://example.invalid/doctors/test-095', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10095', 'Gujarat', 'Pending Verification', '2026-07-14'::date, 'https://example.invalid/source/primary-095', 'https://example.invalid/source/secondary-095', 'Public Directory', '0000000095', '0000000095', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'unknown', 'yes', '{"Gujarati", "Hindi"}'::text[], 22.5685, 72.9289, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-10'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-096', 'Dr Kiara Joshi (Test 096)', 'Dr Kiara Joshi (Test 096)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Neurosurgery', 'Neurosurgery', 'Functional Neurosurgery', 10, 10, 'Consultant Neurosurgeon', 'Demo Neuro Hospital 21', 'Independent', 'India', 'Gujarat', 'Bharuch', 'Bharuch', '392001', '0000000096', '0000000096', '0000000096', '0000000096', 'dummy.doctor.096@example.invalid', 'https://example.invalid/doctors/test-096', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10096', 'Gujarat', 'Unknown', '2026-08-15'::date, 'https://example.invalid/source/primary-096', 'https://example.invalid/source/secondary-096', 'Other', '0000000096', '0000000096', '{"Mon-Sat"}'::text[], '10:00:00'::time, '13:00:00'::time, '10:00 AM', '1:00 PM', false, 'yes', 'no', '{"English", "Hindi", "Marathi"}'::text[], 21.7011, 72.9979, 'verified', 'published', true, 'Test Data Generator', '2026-09-11'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-097', 'Dr Riya Joshi (Test 097)', 'Dr Riya Joshi (Test 097)', 'MBBS, MS (General Surgery), MCh (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Epilepsy Surgery', 11, 11, 'Senior Consultant Neurosurgeon', 'Demo Neuro Hospital 22', 'Private', 'India', 'Gujarat', 'Navsari', 'Navsari', '396445', '0000000097', '0000000097', '0000000097', '0000000097', 'dummy.doctor.097@example.invalid', 'https://example.invalid/doctors/test-097', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10097', 'Gujarat', 'Active', '2026-01-16'::date, 'https://example.invalid/source/primary-097', 'https://example.invalid/source/secondary-097', 'Doctor Submitted', '0000000097', '0000000097', '{"Mon-Fri"}'::text[], '16:00:00'::time, '19:00:00'::time, '4:00 PM', '7:00 PM', false, 'no', 'unknown', '{"Gujarati", "Hindi", "English"}'::text[], 20.9447, 72.956, 'unverified', 'published', false, 'Test Data Generator', '2026-09-12'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-098', 'Dr Meera Joshi (Test 098)', 'Dr Meera Joshi (Test 098)', 'MBBS, DNB (Neurosurgery)', 'Neurosurgery', 'Neurosurgery', 'Minimally Invasive Spine', 12, 12, 'Associate Consultant', 'Demo Neuro Hospital 23', 'Government', 'India', 'Gujarat', 'Valsad', 'Valsad', '396001', '0000000098', '0000000098', '0000000098', '0000000098', 'dummy.doctor.098@example.invalid', 'https://example.invalid/doctors/test-098', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10098', 'Gujarat', 'Pending Verification', '2026-02-17'::date, 'https://example.invalid/source/primary-098', 'https://example.invalid/source/secondary-098', 'Hospital Website', '0000000098', '0000000098', '{"Tue/Thu/Sat"}'::text[], '09:00:00'::time, '12:00:00'::time, '9:00 AM', '12:00 PM', true, 'unknown', 'yes', '{"Hindi", "English"}'::text[], 20.5992, 72.9402, 'partially_verified', 'published', false, 'Test Data Generator', '2026-09-13'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-099', 'Dr Avni Joshi (Test 099)', 'Dr Avni Joshi (Test 099)', 'MBBS, MS, DrNB (Neurosurgery)', 'Neurointervention', 'Neurointervention', 'Endovascular Neurointervention', 13, 13, 'Assistant Professor', 'Demo Neuro Hospital 24', 'Trust / NGO', 'India', 'Gujarat', 'Junagadh', 'Junagadh', '362001', '0000000099', '0000000099', '0000000099', '0000000099', 'dummy.doctor.099@example.invalid', 'https://example.invalid/doctors/test-099', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10099', 'Gujarat', 'Unknown', '2026-03-18'::date, 'https://example.invalid/source/primary-099', 'https://example.invalid/source/secondary-099', 'Medical Council', '0000000099', '0000000099', '{"Mon/Wed/Fri"}'::text[], '14:00:00'::time, '17:00:00'::time, '2:00 PM', '5:00 PM', false, 'yes', 'no', '{"Gujarati", "Hindi"}'::text[], 21.5242, 70.4519, 'verified', 'published', true, 'Test Data Generator', '2026-09-14'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;
INSERT INTO public.doctors (external_id, full_name, name, qualification, primary_specialty, specialty, sub_specialty, years_experience, years_of_experience, designation, hospital_name, practice_type, country, state, district, city, pin_code, mobile, phone, phone_number, whatsapp, email, website_url, council_name, registration_no, registration_state, registration_status, registration_verified_on, primary_source_url, secondary_source_url, source_type, hospital_phone, emergency_contact, opd_days, opd_open, opd_close, opening_time, closing_time, opd_by_appointment, teleconsultation, emergency_24x7, languages, lat, lng, verification_status, data_status, is_verified, verified_by, last_verified_at, remarks, rating)
VALUES ('TEST-DR-100', 'Dr Tara Joshi (Test 100)', 'Dr Tara Joshi (Test 100)', 'MBBS, MS, MCh (Neurosurgery), Fellowship', 'Spine Surgery', 'Spine Surgery', 'Neuro-oncology', 14, 14, 'Professor & Head', 'Demo Neuro Hospital 25', 'Medical College', 'India', 'Gujarat', 'Amreli', 'Amreli', '365601', '0000000100', '0000000100', '0000000100', '0000000100', 'dummy.doctor.100@example.invalid', 'https://example.invalid/doctors/test-100', 'Gujarat Medical Council (TEST)', 'TEST-GMC-10100', 'Gujarat', 'Active', '2026-04-19'::date, 'https://example.invalid/source/primary-100', 'https://example.invalid/source/secondary-100', 'Professional Society', '0000000100', '0000000100', '{"Daily"}'::text[], NULL, NULL, '09:00', '17:00', true, 'no', 'unknown', '{"English", "Hindi", "Marathi"}'::text[], 21.6072, 71.2181, 'unverified', 'published', false, 'Test Data Generator', '2026-09-15'::timestamptz, 'DUMMY TEST RECORD — NOT A REAL DOCTOR', 4.8)
ON CONFLICT (external_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  name = EXCLUDED.name,
  qualification = EXCLUDED.qualification,
  primary_specialty = EXCLUDED.primary_specialty,
  specialty = EXCLUDED.specialty,
  sub_specialty = EXCLUDED.sub_specialty,
  years_experience = EXCLUDED.years_experience,
  years_of_experience = EXCLUDED.years_of_experience,
  designation = EXCLUDED.designation,
  hospital_name = EXCLUDED.hospital_name,
  practice_type = EXCLUDED.practice_type,
  country = EXCLUDED.country,
  state = EXCLUDED.state,
  district = EXCLUDED.district,
  city = EXCLUDED.city,
  pin_code = EXCLUDED.pin_code,
  mobile = EXCLUDED.mobile,
  phone = EXCLUDED.phone,
  phone_number = EXCLUDED.phone_number,
  whatsapp = EXCLUDED.whatsapp,
  email = EXCLUDED.email,
  website_url = EXCLUDED.website_url,
  council_name = EXCLUDED.council_name,
  registration_no = EXCLUDED.registration_no,
  registration_state = EXCLUDED.registration_state,
  registration_status = EXCLUDED.registration_status,
  registration_verified_on = EXCLUDED.registration_verified_on,
  primary_source_url = EXCLUDED.primary_source_url,
  secondary_source_url = EXCLUDED.secondary_source_url,
  source_type = EXCLUDED.source_type,
  hospital_phone = EXCLUDED.hospital_phone,
  emergency_contact = EXCLUDED.emergency_contact,
  opd_days = EXCLUDED.opd_days,
  opd_open = EXCLUDED.opd_open,
  opd_close = EXCLUDED.opd_close,
  opd_by_appointment = EXCLUDED.opd_by_appointment,
  teleconsultation = EXCLUDED.teleconsultation,
  emergency_24x7 = EXCLUDED.emergency_24x7,
  languages = EXCLUDED.languages,
  lat = EXCLUDED.lat,
  lng = EXCLUDED.lng,
  verification_status = EXCLUDED.verification_status,
  data_status = EXCLUDED.data_status,
  is_verified = EXCLUDED.is_verified,
  verified_by = EXCLUDED.verified_by,
  last_verified_at = EXCLUDED.last_verified_at,
  remarks = EXCLUDED.remarks;

-- 4. Rebuild doctor_services for every TSV doctor
DELETE FROM public.doctor_services 
WHERE doctor_id IN (SELECT id FROM public.doctors WHERE external_id IN ('TEST-DR-001', 'TEST-DR-002', 'TEST-DR-003', 'TEST-DR-004', 'TEST-DR-005', 'TEST-DR-006', 'TEST-DR-007', 'TEST-DR-008', 'TEST-DR-009', 'TEST-DR-010', 'TEST-DR-011', 'TEST-DR-012', 'TEST-DR-013', 'TEST-DR-014', 'TEST-DR-015', 'TEST-DR-016', 'TEST-DR-017', 'TEST-DR-018', 'TEST-DR-019', 'TEST-DR-020', 'TEST-DR-021', 'TEST-DR-022', 'TEST-DR-023', 'TEST-DR-024', 'TEST-DR-025', 'TEST-DR-026', 'TEST-DR-027', 'TEST-DR-028', 'TEST-DR-029', 'TEST-DR-030', 'TEST-DR-031', 'TEST-DR-032', 'TEST-DR-033', 'TEST-DR-034', 'TEST-DR-035', 'TEST-DR-036', 'TEST-DR-037', 'TEST-DR-038', 'TEST-DR-039', 'TEST-DR-040', 'TEST-DR-041', 'TEST-DR-042', 'TEST-DR-043', 'TEST-DR-044', 'TEST-DR-045', 'TEST-DR-046', 'TEST-DR-047', 'TEST-DR-048', 'TEST-DR-049', 'TEST-DR-050', 'TEST-DR-051', 'TEST-DR-052', 'TEST-DR-053', 'TEST-DR-054', 'TEST-DR-055', 'TEST-DR-056', 'TEST-DR-057', 'TEST-DR-058', 'TEST-DR-059', 'TEST-DR-060', 'TEST-DR-061', 'TEST-DR-062', 'TEST-DR-063', 'TEST-DR-064', 'TEST-DR-065', 'TEST-DR-066', 'TEST-DR-067', 'TEST-DR-068', 'TEST-DR-069', 'TEST-DR-070', 'TEST-DR-071', 'TEST-DR-072', 'TEST-DR-073', 'TEST-DR-074', 'TEST-DR-075', 'TEST-DR-076', 'TEST-DR-077', 'TEST-DR-078', 'TEST-DR-079', 'TEST-DR-080', 'TEST-DR-081', 'TEST-DR-082', 'TEST-DR-083', 'TEST-DR-084', 'TEST-DR-085', 'TEST-DR-086', 'TEST-DR-087', 'TEST-DR-088', 'TEST-DR-089', 'TEST-DR-090', 'TEST-DR-091', 'TEST-DR-092', 'TEST-DR-093', 'TEST-DR-094', 'TEST-DR-095', 'TEST-DR-096', 'TEST-DR-097', 'TEST-DR-098', 'TEST-DR-099', 'TEST-DR-100'));

INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-001' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-002' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-003' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-004' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-005' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-006' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-007' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-008' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-009' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-010' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-011' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-012' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-013' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-014' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-015' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-016' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-017' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-018' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-019' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-020' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-021' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-022' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-023' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-024' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-025' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-026' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-027' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-028' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-029' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-030' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-031' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-032' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-033' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-034' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-035' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-036' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-037' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-038' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-039' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-040' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-041' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-042' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-043' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-044' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-045' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-046' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-047' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-048' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-049' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-050' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-051' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-052' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-053' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-054' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-055' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-056' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-057' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-058' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-059' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-060' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-061' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-062' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-063' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-064' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-065' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-066' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-067' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-068' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-069' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-070' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-071' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-072' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-073' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-074' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-075' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-076' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-077' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-078' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-079' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-080' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-081' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-082' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-083' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-084' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-085' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-086' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-087' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-088' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-089' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-090' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-091' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-092' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-093' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-094' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-095' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-096' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-097' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-098' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-099' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'trauma'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'brain_tumor'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'stroke'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'neurovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'pediatric'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'functional'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'epilepsy'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'unknown'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'skull_base'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'yes'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'endovascular'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;
INSERT INTO public.doctor_services (doctor_id, service_id, status)
SELECT d.id, s.id, 'no'
FROM public.doctors d, public.services s
WHERE d.external_id = 'TEST-DR-100' AND s.slug = 'minimally_invasive_spine'
ON CONFLICT (doctor_id, service_id) DO UPDATE SET status = EXCLUDED.status;

-- 5. Status report & verification queries
DO $$
DECLARE
  v_doctors_count int;
  v_services_count int;
  v_orphan_count int;
BEGIN
  SELECT count(*) INTO v_doctors_count FROM public.doctors;
  SELECT count(*) INTO v_services_count FROM public.doctor_services;
  SELECT count(*) INTO v_orphan_count FROM public.doctor_services ds WHERE NOT EXISTS (SELECT 1 FROM public.doctors d WHERE d.id = ds.doctor_id);
  RAISE NOTICE 'Total Doctors: %, Total Doctor Services: %, Orphan Services: %', v_doctors_count, v_services_count, v_orphan_count;
END $$;

COMMIT;

NOTIFY pgrst, 'reload schema';