-- =====================================================================
-- ICT371 Advanced Database - Question 10: Scholarship Application Assessment
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q10, public;

-- ---------------------------------------------------------------------
-- Tests for (b) and (c)
-- ---------------------------------------------------------------------
SELECT fn_scholarship_eligible(18, 3000, 70) AS lower_bounds,   -- true
       fn_scholarship_eligible(26, 1000, 90) AS too_old;        -- false

DO $$
BEGIN
    PERFORM fn_scholarship_eligible(NULL, 1000, 80);
    RAISE NOTICE 'UNEXPECTED: NULL age accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    PERFORM fn_scholarship_eligible(20, -1, 80);
    RAISE NOTICE 'UNEXPECTED: negative income accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    PERFORM fn_scholarship_eligible(0, 1000, 80);
    RAISE NOTICE 'UNEXPECTED: zero age accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    PERFORM fn_scholarship_eligible(20, 1000, 101);
    RAISE NOTICE 'UNEXPECTED: mark above 100 accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_assess_application(999);
    RAISE NOTICE 'UNEXPECTED: unknown application accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Assess application 1 by hand, then try again
CALL pr_assess_application(1);
DO $$
BEGIN
    CALL pr_assess_application(1);
    RAISE NOTICE 'UNEXPECTED: reassessment accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;
