-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT fn_water_charge(0)    AS zero_units,     -- 0.00
       fn_water_charge(10)   AS ten_units,      -- 50.00
       fn_water_charge(10.5) AS ten_and_half,   -- 54.00
       fn_water_charge(18)   AS eighteen;       -- 114.00

DO $$
BEGIN
    PERFORM fn_water_charge(-1);
    RAISE NOTICE 'UNEXPECTED: negative units accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    PERFORM fn_water_charge(NULL);
    RAISE NOTICE 'UNEXPECTED: NULL units accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_generate_bill(999, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: unknown reading billed';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_generate_bill(1, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: second bill accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Direct import of a bad reading is rejected and not stored
DO $$
BEGIN
    INSERT INTO readings (customer_id, reading_month, previous_reading, current_reading)
    VALUES (3, date_trunc('month', CURRENT_DATE)::date, 115.00, 99.00);
    RAISE NOTICE 'UNEXPECTED: backwards reading stored';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    UPDATE readings SET current_reading = 100.00 WHERE reading_id = 6;
    RAISE NOTICE 'UNEXPECTED: backwards update stored';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

SELECT count(*) AS readings_stored FROM readings;   -- still 6
