-- =====================================================================
-- ICT371 Advanced Database - Question 2: University Fee Payments
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q2, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three students with different balances, six payments.
--     Student 3 has no payments.
-- ---------------------------------------------------------------------
INSERT INTO students (student_number, full_name, fee_due) VALUES
    ('2023001', 'Chanda Mwila',   6000.00),
    ('2023002', 'Bupe Tembo',     4000.00),
    ('2023003', 'Mutale Phiri',   5500.00);

CALL pr_receive_payment(1, 1000.00, CURRENT_DATE - 3);
CALL pr_receive_payment(2, 1500.00, CURRENT_DATE - 3);
CALL pr_receive_payment(1, 2000.00, CURRENT_DATE - 1);
CALL pr_receive_payment(2, 1000.00, CURRENT_DATE - 1);
CALL pr_receive_payment(1,  500.00, CURRENT_DATE - 1);
CALL pr_receive_payment(2, 1500.00, CURRENT_DATE);      -- student 2 now fully settled

SELECT * FROM payments      ORDER BY payment_id;
SELECT * FROM payment_audit ORDER BY audit_id;          -- 6 rows, written by the trigger
