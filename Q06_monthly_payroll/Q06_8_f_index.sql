-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- (f) Index for reports filtered by pay_month across all employees
--     The unique constraint already creates an index on
--     (employee_id, pay_month). Because employee_id is its leading
--     column it cannot efficiently answer "WHERE pay_month = ?" for all
--     employees. A single-column index on pay_month serves that report
--     and does not duplicate the existing index.
-- ---------------------------------------------------------------------
CREATE INDEX idx_payroll_pay_month ON payroll (pay_month);
ANALYZE payroll;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT employee_id, gross_pay, net_pay
FROM payroll
WHERE pay_month = date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date;
RESET enable_seqscan;
