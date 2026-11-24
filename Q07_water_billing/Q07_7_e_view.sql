-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (e) View: overdue, not fully paid bills
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_overdue_bills AS
SELECT b.bill_id,
       c.full_name               AS customer_name,
       b.due_on,
       b.charge - b.amount_paid  AS outstanding_amount
FROM bills b
JOIN readings  r ON r.reading_id  = b.reading_id
JOIN customers c ON c.customer_id = r.customer_id
WHERE b.due_on < CURRENT_DATE
  AND b.amount_paid < b.charge;

SELECT * FROM v_overdue_bills ORDER BY due_on;    -- bill 3 only (bill 1 is K0, bill 5 paid)
