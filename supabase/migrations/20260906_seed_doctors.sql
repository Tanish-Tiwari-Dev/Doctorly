-- Seed data for Doctorly testing matching exact schema

INSERT INTO public.doctors (
  full_name, 
  qualification, 
  primary_specialty, 
  hospital_name, 
  city, 
  address, 
  phone_number,
  average_rating, 
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
('Dr. Amarpreet Singh Riar', 'MBBS, MD (Medicine)', 'General Physician', 'City Care Hospital', 'Delhi', 'Sector 18, Noida', '+919876543210', 4.8, 124, 12, '09:00', '19:00', true, 28.5700, 77.3200, 'Experienced general physician specializing in preventive healthcare.'),
('Dr. (Maj.) Sharad Shrivastava', 'MBBS, MD (Medicine)', 'General Physician', 'Adarsh Health Clinic', 'Delhi', 'Dilshad Garden', '+919876543211', 4.7, 98, 15, '10:00', '18:00', true, 28.6810, 77.3020, 'Former military doctor with expertise in internal medicine.'),
('Dr. Anirban Biswas', 'MBBS, MD (Medicine)', 'General Physician', 'Diabetes & Hormone Care', 'Delhi', 'Lajpat Nagar', '+919876543212', 4.9, 210, 18, '08:00', '20:00', true, 28.5670, 77.2440, 'Diabetologist and general physician.'),
('Dr. Aman Vij', 'MBBS, MD (Medicine)', 'General Physician', 'Pitampura Medical Center', 'Delhi', 'Pitampura', '+919876543213', 4.5, 67, 7, '09:30', '17:30', false, 28.6980, 77.1320, 'General physician with a focus on lifestyle diseases.'),

-- Homoeopaths
('Dr. Mansi Arya', 'BHMS, MD (Homoeopathy)', 'Homoeopath', 'Rohini Homoeo Clinic', 'Delhi', 'Rohini', '+919876543214', 4.6, 45, 8, '10:00', '19:00', true, 28.7320, 77.0870, 'Homoeopath specializing in chronic ailments.'),
('Dr. Sunil Kumar Dwivedi', 'BHMS', 'Homoeopath', 'Uttam Nagar Wellness', 'Delhi', 'Uttam Nagar', '+919876543215', 4.4, 32, 11, '09:00', '18:00', false, 28.6280, 77.0640, 'Holistic homoeopathic treatments.'),
('Dr. Chhavi Bansal', 'BHMS, MD (Homoeopathy)', 'Homoeopath', 'Janakpuri Skin Cure', 'Delhi', 'Janakpuri', '+919876543216', 4.8, 89, 9, '10:00', '20:00', true, 28.6210, 77.0870, 'Expert in homoeopathic dermatology.'),
('Dr. Sneh Khera', 'BHMS', 'Homoeopath', 'Saket Homoeo Centre', 'Delhi', 'Saket', '+919876543217', 4.7, 56, 14, '09:30', '17:00', true, 28.5240, 77.2060, 'Homoeopath with a focus on women''s health.'),
('Dr. Inderjeet Singh', 'BHMS', 'Homoeopath', 'Vasant Vihar Clinic', 'Delhi', 'Vasant Vihar', '+919876543218', 4.5, 41, 6, '11:00', '19:00', false, 28.5600, 77.1600, 'General homoeopathic practitioner.'),
('Dr. Suman Mohan', 'BHMS', 'Homoeopath', 'Karol Bagh Health Clinic', 'Delhi', 'Karol Bagh', '+919876543219', 4.3, 23, 10, '10:00', '18:00', false, 28.6510, 77.1900, 'Homoeopathic consultant.'),

-- ENT Specialists
('Dr. Manish Munjal', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Sir Ganga Ram Hospital', 'Delhi', 'Rajouri Garden', '+919876543220', 4.9, 150, 20, '09:00', '19:00', true, 28.6500, 77.1200, 'Senior ENT surgeon.'),
('Dr. Ajay Jain', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Max Super Speciality Hospital', 'Delhi', 'Preet Vihar', '+919876543221', 4.7, 85, 16, '10:00', '18:00', true, 28.6400, 77.2970, 'ENT specialist and head-neck surgeon.'),
('Dr. Anshul Gupta', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Balaji Action Hospital', 'Delhi', 'Paschim Vihar', '+919876543222', 4.6, 72, 12, '09:30', '17:30', true, 28.6720, 77.0980, 'ENT surgeon.'),
('Dr. B B Khatri', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Dwarka ENT Clinic', 'Delhi', 'Dwarka', '+919876543223', 4.8, 110, 22, '10:00', '20:00', true, 28.5700, 77.0700, 'Veteran ENT consultant.'),
('Dr. Rajeev Adhana', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Adhana ENT Clinic', 'Delhi', 'Dilshad Garden', '+919876543224', 4.4, 34, 8, '09:00', '17:00', false, 28.6810, 77.3200, 'ENT specialist.'),
('Dr. Vidit Tripathi', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Greater Kailash Hospital', 'Delhi', 'Greater Kailash', '+919876543225', 4.9, 190, 15, '11:00', '19:00', true, 28.5400, 77.2400, 'ENT specialist.'),
('Dr. Arun Wadhawan', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Vikaspuri Medical Center', 'Delhi', 'Vikaspuri', '+919876543226', 4.5, 60, 10, '10:00', '18:00', false, 28.6370, 77.0680, 'ENT consultant.'),
('Dr. Neha Sood', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Shalimar Bagh Clinic', 'Delhi', 'Shalimar Bagh', '+919876543227', 4.7, 95, 11, '09:00', '19:00', true, 28.7000, 77.1500, 'ENT surgeon.'),
('Dr. Vineet Narula', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Model Town Hospital', 'Delhi', 'Model Town', '+919876543228', 4.6, 80, 14, '10:00', '18:00', true, 28.6800, 77.1900, 'ENT specialist.'),
('Dr. Yogesh Jain', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Adarsh Nagar Clinic', 'Delhi', 'Adarsh Nagar', '+919876543229', 4.5, 55, 9, '09:30', '17:30', false, 28.7200, 77.1800, 'ENT consultant.'),
('Dr. Rakesh Singh', 'MS (ENT)', 'Ear-Nose-Throat (ENT) Specialist', 'Mayur Vihar Health Center', 'Delhi', 'Mayur Vihar', '+919876543230', 4.4, 40, 7, '10:00', '18:00', false, 28.6100, 77.2900, 'ENT specialist.'),

-- Ayurveda
('Dr. Sudha Asokan', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Saket Ayurveda Center', 'Delhi', 'Saket', '+919876543231', 4.8, 120, 19, '09:00', '18:00', true, 28.5240, 77.2060, 'Ayurvedic specialist.'),
('Dr. Mahesh Shah', 'BAMS', 'Ayurveda', 'Lajpat Nagar Ayurveda', 'Delhi', 'Lajpat Nagar', '+919876543232', 4.3, 25, 8, '10:00', '19:00', false, 28.5670, 77.2440, 'Ayurvedic consultant.'),
('Dr. S K Singh', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Rohini Ayurvedic Clinic', 'Delhi', 'Rohini', '+919876543233', 4.7, 88, 15, '09:30', '17:30', true, 28.7320, 77.0870, 'Ayurveda expert.'),
('Dr. Sudhir Bhola', 'BAMS', 'Ayurveda', 'Pitampura Alternative Med', 'Delhi', 'Pitampura', '+919876543234', 4.6, 75, 12, '10:00', '20:00', true, 28.6980, 77.1320, 'Alternative medicine specialist.'),
('Dr. Jyoti Arora Monga', 'BAMS', 'Ayurveda', 'Janakpuri Ayurveda', 'Delhi', 'Janakpuri', '+919876543235', 4.5, 60, 10, '09:00', '18:00', false, 28.6210, 77.0870, 'Ayurvedic doctor.'),
('Dr. Vijay Abbot', 'BAMS', 'Ayurveda', 'Lajpat Nagar Clinic', 'Delhi', 'Lajpat Nagar', '+919876543236', 4.4, 35, 9, '11:00', '19:00', false, 28.5670, 77.2440, 'Ayurvedic consultant.'),
('Dr. Rakesh Gupta', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Uttam Nagar Clinic', 'Delhi', 'Uttam Nagar', '+919876543237', 4.8, 90, 16, '09:00', '17:00', true, 28.6280, 77.0640, 'Ayurveda specialist.'),
('Dr. Sugeeta Mutreja', 'BAMS', 'Ayurveda', 'Preet Vihar Diet & Ayur', 'Delhi', 'Preet Vihar', '+919876543238', 4.6, 50, 11, '10:00', '18:00', true, 28.6400, 77.2970, 'Dietitian and Ayurvedic expert.'),
('Dr. Ruchi Gupta', 'BAMS', 'Ayurveda', 'Uttam Nagar Ayurveda', 'Delhi', 'Uttam Nagar', '+919876543239', 4.5, 45, 8, '10:00', '18:00', false, 28.6280, 77.0640, 'Ayurvedic consultant.'),
('Dr. Praveen Rustagi', 'BAMS, MD (Ayurveda)', 'Ayurveda', 'Rohini Ayurvedic Hospital', 'Delhi', 'Rohini', '+919876543240', 4.7, 65, 13, '09:30', '17:30', true, 28.7320, 77.0870, 'Ayurvedic doctor.'),

-- Dermatologists
('Dr. S.K Kashyap', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Saket Skin Hospital', 'Delhi', 'Saket', '+919876543241', 4.9, 200, 20, '09:00', '19:00', true, 28.5240, 77.2060, 'Dermatologist and cosmetologist.'),
('Dr. Nipun Jain', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Shalimar Bagh Skin Clinic', 'Delhi', 'Shalimar Bagh', '+919876543242', 4.7, 110, 12, '10:00', '18:00', true, 28.7000, 77.1500, 'Dermatologist.'),
('Dr. Rohit Batra', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Rajouri Garden Derma', 'Delhi', 'Rajouri Garden', '+919876543243', 4.8, 150, 15, '10:00', '20:00', true, 28.6500, 77.1200, 'Dermatologist and cosmetologist.'),
('Dr. Lipy Gupta', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Paschim Vihar Derma', 'Delhi', 'Paschim Vihar', '+919876543244', 4.5, 70, 9, '09:30', '17:30', false, 28.6720, 77.0980, 'Dermatologist.'),
('Dr. Gaurav Garg', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Pitampura Skin Care', 'Delhi', 'Pitampura', '+919876543245', 4.9, 180, 14, '10:00', '19:00', true, 28.6980, 77.1320, 'Dermatologist and cosmetologist.'),
('Dr. Parmil Kumar Sharma', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Dwarka Derma Clinic', 'Delhi', 'Dwarka', '+919876543246', 4.4, 40, 7, '09:00', '17:00', false, 28.5700, 77.0700, 'Dermatologist.'),
('Dr. Shruti Gupta', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Lajpat Nagar Derma', 'Delhi', 'Lajpat Nagar', '+919876543247', 4.6, 85, 10, '10:00', '18:00', true, 28.5670, 77.2440, 'Dermatologist.'),
('Dr. Manisha Chopra', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Saket Derma & Cosmeto', 'Delhi', 'Saket', '+919876543248', 4.8, 120, 16, '09:00', '19:00', true, 28.5240, 77.2060, 'Dermatologist and cosmetologist.'),
('Dr. Ranjan Upadhyay', 'MBBS, MD (Dermatology)', 'Dermatologist', 'Mayur Vihar Skin Clinic', 'Delhi', 'Mayur Vihar', '+919876543249', 4.3, 30, 5, '10:00', '18:00', false, 28.6100, 77.2900, 'Dermatologist.'),

-- Gynecologist
('Dr. Gayatri Bala Juneja', 'MBBS, MS (OBGYN)', 'Gynecologist/Obstetrician', 'Greater Kailash Hospital', 'Delhi', 'Greater Kailash', '+919876543250', 4.9, 220, 22, '09:00', '19:00', true, 28.5400, 77.2400, 'Gynecologist and obstetrician.');
