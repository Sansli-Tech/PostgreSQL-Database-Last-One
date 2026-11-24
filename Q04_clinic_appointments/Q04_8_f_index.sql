-- =====================================================================
-- ICT371 Advanced Database - Question 4: Clinic Appointment Scheduling
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q4, public;

-- ---------------------------------------------------------------------
-- (f) Non-unique index on (appointment_day, doctor_id)
--     Both the clash trigger and fn_daily_load search by day and doctor.
--     A composite B-tree on these two columns finds one doctor's
--     appointments for a day directly. It is non-unique because a doctor
--     has up to four slots per day and cancelled rows can repeat a slot.
-- ---------------------------------------------------------------------
CREATE INDEX idx_appointments_day_doctor ON appointments (appointment_day, doctor_id);
ANALYZE appointments;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT appointment_id, slot_time, status
FROM appointments
WHERE appointment_day = CURRENT_DATE
  AND doctor_id = 3;
RESET enable_seqscan;
