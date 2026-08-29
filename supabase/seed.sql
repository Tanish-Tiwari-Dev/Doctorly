-- Doctorly Phase 5 seed
-- 6 doctors around Bangalore (12.9716, 77.5946).
-- Run AFTER schema.sql.

insert into public.doctors (name, specialty, location, address, rating, image_url, availability) values
  ('Dr. Priya Sharma', 'Cardiologist',
    ST_SetSRID(ST_MakePoint(77.5946, 12.9716), 4326)::geography,
    'MG Road, Bangalore', 4.8,
    'https://i.pravatar.cc/150?img=11', 'Available Today'),

  ('Dr. Arjun Mehta', 'Dermatologist',
    ST_SetSRID(ST_MakePoint(77.6068, 12.9854), 4326)::geography,
    'Indiranagar, Bangalore', 4.6,
    'https://i.pravatar.cc/150?img=12', 'Available Tomorrow'),

  ('Dr. Sneha Reddy', 'Pediatrician',
    ST_SetSRID(ST_MakePoint(77.6209, 12.9352), 4326)::geography,
    'Koramangala, Bangalore', 4.9,
    'https://i.pravatar.cc/150?img=13', 'Available Today'),

  ('Dr. Rajesh Kumar', 'Orthopedic Surgeon',
    ST_SetSRID(ST_MakePoint(77.5772, 12.9279), 4326)::geography,
    'Jayanagar, Bangalore', 4.7,
    'https://i.pravatar.cc/150?img=14', 'Available Tomorrow'),

  ('Dr. Ananya Desai', 'General Physician',
    ST_SetSRID(ST_MakePoint(77.6099, 12.9698), 4326)::geography,
    'Ulsoor, Bangalore', 4.5,
    'https://i.pravatar.cc/150?img=15', 'Available Today'),

  ('Dr. Amit Patel', 'Dentist',
    ST_SetSRID(ST_MakePoint(77.6411, 12.9921), 4326)::geography,
    'Whitefield, Bangalore', 4.3,
    'https://i.pravatar.cc/150?img=16', 'Available Tomorrow')
on conflict do nothing;
