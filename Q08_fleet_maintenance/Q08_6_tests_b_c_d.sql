-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT vehicle_id, registration, fn_service_due(vehicle_id) AS service_due
FROM vehicles ORDER BY vehicle_id;            -- false, true, true

DO $$
BEGIN
    PERFORM fn_service_due(999);
    RAISE NOTICE 'UNEXPECTED: unknown vehicle accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_record_trip(1, CURRENT_DATE, 12900.0, 12800.0);
    RAISE NOTICE 'UNEXPECTED: backwards trip accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Start does not match current odometer (12900) — caught by the trigger
DO $$
BEGIN
    CALL pr_record_trip(1, CURRENT_DATE, 13000.0, 13100.0);
    RAISE NOTICE 'UNEXPECTED: mismatched start accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Direct SQL insert is also checked by the trigger
DO $$
BEGIN
    INSERT INTO trips (vehicle_id, trip_on, start_odometer, end_odometer)
    VALUES (2, CURRENT_DATE, 20000.0, 20100.0);
    RAISE NOTICE 'UNEXPECTED: direct insert with wrong start accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

SELECT vehicle_id, current_odometer FROM vehicles ORDER BY vehicle_id;  -- unchanged
