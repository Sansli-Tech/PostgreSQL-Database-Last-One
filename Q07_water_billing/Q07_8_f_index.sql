-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (f) Index for date-based searches of overdue bills
--     Partial B-tree on due_on that only holds bills still owing money
--     (amount_paid < charge). Overdue searches are "due_on < date AND
--     unpaid", so the index range-scans due_on over unpaid bills only;
--     fully paid bills, which become the majority over time, are left out.
-- ---------------------------------------------------------------------
CREATE INDEX idx_bills_unpaid_due_on ON bills (due_on) WHERE amount_paid < charge;
ANALYZE bills;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT bill_id, due_on, charge - amount_paid AS outstanding
FROM bills
WHERE due_on < CURRENT_DATE
  AND amount_paid < charge;
RESET enable_seqscan;
