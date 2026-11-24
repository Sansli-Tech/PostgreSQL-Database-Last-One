-- =====================================================================
-- ICT371 Advanced Database - Question 2: University Fee Payments
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q2, public;

-- ---------------------------------------------------------------------
-- Tests for (b) and (c)
-- ---------------------------------------------------------------------
SELECT student_id, full_name, fee_due, fn_fee_balance(student_id) AS balance
FROM students ORDER BY student_id;    -- 2500.00, 0.00, 5500.00 (full fee, no payments)

DO $$
BEGIN
    PERFORM fn_fee_balance(999);
    RAISE NOTICE 'UNEXPECTED: unknown student accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_receive_payment(1, NULL, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: NULL amount accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_receive_payment(1, 0, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: zero amount accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_receive_payment(1, -50, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: negative amount accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_receive_payment(1, 2500.01, CURRENT_DATE);   -- 1 ngwee over balance
    RAISE NOTICE 'UNEXPECTED: overpayment accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- fee_due is unchanged by payments
SELECT student_number, fee_due FROM students ORDER BY student_id;
