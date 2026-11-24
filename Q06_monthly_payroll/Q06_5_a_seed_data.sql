-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: active and inactive employees, two payroll months
-- ---------------------------------------------------------------------
INSERT INTO employees (full_name, basic_salary, allowance, deduction, active) VALUES
    ('Grace Mutale',   9000.00, 1500.00, 1200.00, TRUE),
    ('Peter Ngoma',    7500.00, 1000.00,  950.00, TRUE),
    ('Lillian Kunda',  6200.00,  800.00,  700.00, TRUE),
    ('Moses Siwale',   5800.00,  600.00,  650.00, TRUE),   -- leaves after month 1
    ('Agnes Hamoonga', 6000.00,  500.00,  600.00, FALSE);  -- inactive throughout

-- Month 1 (two months ago)
CALL pr_process_payroll(date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date);

-- Between months: Grace gets a raise, Moses leaves
UPDATE employees SET basic_salary = 9500.00 WHERE employee_id = 1;
UPDATE employees SET active = FALSE WHERE employee_id = 4;

-- Month 2 (last month)
CALL pr_process_payroll(date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date);

SELECT * FROM payroll ORDER BY pay_month, employee_id;   -- 4 rows + 3 rows
