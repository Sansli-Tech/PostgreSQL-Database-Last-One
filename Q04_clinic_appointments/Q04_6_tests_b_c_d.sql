-- =====================================================================
-- ICT371 Advanced Database - Question 4: Clinic Appointment Scheduling
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q4, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT fn_daily_load(1, CURRENT_DATE - 1) AS dr1_yesterday,    -- 1 (cancelled ignored)
       fn_daily_load(3, CURRENT_DATE + 7) AS dr3_next_week;    -- 0

DO $$
BEGIN
    PERFORM fn_daily_load(999, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: unknown doctor accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_book_appointment(999, 1, CURRENT_DATE + 2, '09:00');
    RAISE NOTICE 'UNEXPECTED: unknown patient accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_book_appointment(1, 1, CURRENT_DATE - 3, '09:00');
    RAISE NOTICE 'UNEXPECTED: past date accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_book_appointment(1, 1, CURRENT_DATE + 2, '14:30');
    RAISE NOTICE 'UNEXPECTED: unsupported slot accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Clash via the procedure
DO $$
BEGIN
    CALL pr_book_appointment(3, 3, CURRENT_DATE, '09:00');
    RAISE NOTICE 'UNEXPECTED: clash accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Clash via direct UPDATE (move appointment 4 into Dr. Njobvu's 09:00 today)
DO $$
BEGIN
    UPDATE appointments SET doctor_id = 3, slot_time = '09:00' WHERE appointment_id = 4;
    RAISE NOTICE 'UNEXPECTED: clashing update accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Updating a row without moving it must not clash with itself
UPDATE appointments SET patient_id = 2 WHERE appointment_id = 6;
UPDATE appointments SET patient_id = 3 WHERE appointment_id = 6;
