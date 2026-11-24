-- =====================================================================
-- ICT371 Advanced Database - Question 4: Clinic Appointment Scheduling
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q4, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three patients, three doctors, six appointments.
--     Yesterday's history is inserted directly (the procedure only books
--     today or later); new bookings go through the procedure.
-- ---------------------------------------------------------------------
INSERT INTO patients (full_name) VALUES
    ('Esther Mwanza'), ('Joseph Chola'), ('Ruth Nkhata');

INSERT INTO doctors (full_name) VALUES
    ('Dr. Kabwe'), ('Dr. Siame'), ('Dr. Njobvu');

INSERT INTO appointments (patient_id, doctor_id, appointment_day, slot_time, status) VALUES
    (1, 1, CURRENT_DATE - 1, '09:00', 'ATTENDED'),
    (2, 1, CURRENT_DATE - 1, '09:00', 'CANCELLED'),   -- same slot is fine: cancelled
    (3, 2, CURRENT_DATE - 1, '10:00', 'BOOKED');      -- no-show, still BOOKED

CALL pr_book_appointment(1, 2, CURRENT_DATE,     '11:00');
CALL pr_book_appointment(2, 3, CURRENT_DATE,     '09:00');
CALL pr_book_appointment(3, 1, CURRENT_DATE + 1, '12:00');

SELECT * FROM appointments ORDER BY appointment_id;
