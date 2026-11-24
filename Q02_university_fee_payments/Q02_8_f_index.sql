-- =====================================================================
-- ICT371 Advanced Database - Question 2: University Fee Payments
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q2, public;

-- ---------------------------------------------------------------------
-- (f) Composite index for payments by student_id and paid_on range
--     Justification: equality column (student_id) first, range column
--     (paid_on) second, so the B-tree goes straight to one student's
--     entries and reads only the dates inside the range. The reverse
--     order (paid_on, student_id) would scan every student's payments in
--     the date range. It also indexes the FK column student_id.
-- ---------------------------------------------------------------------
CREATE INDEX idx_payments_student_paid_on ON payments (student_id, paid_on);
ANALYZE payments;

-- Tiny demo table: disable seq scans so the plan shows the index.
SET enable_seqscan = off;
EXPLAIN
SELECT payment_id, amount, paid_on
FROM payments
WHERE student_id = 1
  AND paid_on BETWEEN CURRENT_DATE - 30 AND CURRENT_DATE;
RESET enable_seqscan;
