-- Add is_verified and years_of_experience columns to doctors table
ALTER TABLE doctors
  ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS years_of_experience INT2 DEFAULT 0;
