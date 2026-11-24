-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- (e) View: payroll report with names; history for now-inactive staff
--     The view joins on payroll rows and does NOT filter on active, so
--     Moses' month-1 payslip still appears after he leaves.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_payroll_report AS
SELECT p.payroll_id,
       e.employee_id,
       e.full_name,
       p.pay_month,
       p.gross_pay,
       p.net_pay
FROM payroll p
JOIN employees e ON e.employee_id = p.employee_id;

SELECT * FROM v_payroll_report ORDER BY pay_month, employee_id;
