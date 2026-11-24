-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- (c) Procedure
-- Run order: file 3 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- (c) Procedure: pr_process_payroll(p_month)
--     Query FOR loop over active employees. Missing rows are inserted;
--     existing rows are left untouched (ON CONFLICT DO NOTHING). Any
--     failed calculation raises, which rolls back the whole CALL.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_process_payroll(p_month DATE)
LANGUAGE plpgsql
SET search_path = q6          -- so the scheduler can call it from any session
AS $$
DECLARE
    r_emp RECORD;
    v_net NUMERIC(12,2);
BEGIN
    IF p_month IS NULL OR p_month <> date_trunc('month', p_month)::date THEN
        RAISE EXCEPTION 'Pay month must be the first day of a month (got %)', p_month;
    END IF;

    FOR r_emp IN
        SELECT employee_id, basic_salary, allowance
        FROM employees
        WHERE active
        ORDER BY employee_id
    LOOP
        v_net := fn_net_pay(r_emp.employee_id);   -- raises on a bad calculation

        INSERT INTO payroll (employee_id, pay_month, gross_pay, net_pay)
        VALUES (r_emp.employee_id, p_month,
                r_emp.basic_salary + r_emp.allowance, v_net)
        ON CONFLICT (employee_id, pay_month) DO NOTHING;
    END LOOP;
END;
$$;
