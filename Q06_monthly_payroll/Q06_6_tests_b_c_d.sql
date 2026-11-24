-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT employee_id, full_name, fn_net_pay(employee_id) AS net_pay_now
FROM employees ORDER BY employee_id;

DO $$
BEGIN
    PERFORM fn_net_pay(999);
    RAISE NOTICE 'UNEXPECTED: unknown employee accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_process_payroll(DATE '2026-10-15');
    RAISE NOTICE 'UNEXPECTED: mid-month date accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Reprocessing last month leaves existing rows unchanged (even after a raise)
UPDATE employees SET basic_salary = 7800.00 WHERE employee_id = 2;
CALL pr_process_payroll(date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date);
SELECT employee_id, pay_month, gross_pay, net_pay
FROM payroll
WHERE pay_month = date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date
ORDER BY employee_id;    -- Peter still 8500.00 gross

-- One invalid employee must fail the whole call: no rows for this month
DO $$
DECLARE
    v_month DATE := date_trunc('month', CURRENT_DATE)::date;
BEGIN
    BEGIN
        INSERT INTO employees (full_name, basic_salary, allowance, deduction)
        VALUES ('Bad Data', 1000.00, 0, 5000.00);          -- net would be -4000
        CALL pr_process_payroll(v_month);
        RAISE NOTICE 'UNEXPECTED: invalid calculation accepted';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Rejected as expected: %', SQLERRM;
    END;
    RAISE NOTICE 'Payroll rows for % after failed call: %', v_month,
                 (SELECT count(*) FROM payroll WHERE pay_month = v_month);   -- 0
END $$;

-- Unchanged salary must not be audited
UPDATE employees SET basic_salary = basic_salary WHERE employee_id = 3;
UPDATE employees SET allowance = 900.00 WHERE employee_id = 3;
SELECT * FROM salary_audit ORDER BY audit_id;   -- 2 rows (Grace, Peter)
