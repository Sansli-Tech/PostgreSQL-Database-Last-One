-- =====================================================================
-- ICT371 Advanced Database - Question 3: Library Returns and Overdue Fines
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q3, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT loan_id, due_on, returned_on,
       fn_loan_fine(loan_id, CURRENT_DATE) AS fine_today
FROM loans ORDER BY loan_id;    -- 32, 0, 6, 0, 2, 0  (loan 3 stopped at 6)

DO $$
BEGIN
    PERFORM fn_loan_fine(999, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: unknown loan accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_return_loan(999, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: unknown loan returned';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_return_loan(2, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: second return accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_return_loan(4, CURRENT_DATE - 10);   -- borrowed CURRENT_DATE - 5
    RAISE NOTICE 'UNEXPECTED: return before borrow accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Unchanged returned_on must not be audited
UPDATE loans SET returned_on = returned_on WHERE loan_id = 2;
UPDATE loans SET borrower_name = 'Kondwani M. Zulu' WHERE loan_id = 2;
SELECT * FROM loan_audit ORDER BY audit_id;   -- 3 rows: one per real return
