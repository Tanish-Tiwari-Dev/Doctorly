-- Add opening_time and closing_time columns to doctors table
ALTER TABLE doctors
  ADD COLUMN IF NOT EXISTS opening_time TIME DEFAULT '09:00',
  ADD COLUMN IF NOT EXISTS closing_time TIME DEFAULT '17:00';
