-- =====================================================================
-- ICT371 Advanced Database - Question 2: University Fee Payments
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q2, public;

-- ---------------------------------------------------------------------
-- (e) View: students who still owe fees (settled students excluded)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_fee_balances AS
SELECT s.student_number,
       s.full_name,
       s.fee_due - COALESCE(p.total_paid, 0) AS outstanding_balance
FROM students s
LEFT JOIN (
    SELECT student_id, SUM(amount) AS total_paid
    FROM payments
    GROUP BY student_id
) p ON p.student_id = s.student_id
WHERE s.fee_due - COALESCE(p.total_paid, 0) > 0;

SELECT * FROM v_fee_balances ORDER BY student_number;   -- 2023002 is excluded
