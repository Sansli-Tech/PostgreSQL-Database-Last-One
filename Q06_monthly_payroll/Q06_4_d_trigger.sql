-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- (d) Trigger
-- Run order: file 4 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- (d) Trigger: log real basic_salary changes
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_salary_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.basic_salary IS DISTINCT FROM OLD.basic_salary THEN
        INSERT INTO salary_audit (employee_id, old_salary, new_salary, changed_at)
        VALUES (NEW.employee_id, OLD.basic_salary, NEW.basic_salary, now());
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_employees_salary_audit
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (OLD.basic_salary IS DISTINCT FROM NEW.basic_salary)
EXECUTE FUNCTION trg_fn_salary_audit();
