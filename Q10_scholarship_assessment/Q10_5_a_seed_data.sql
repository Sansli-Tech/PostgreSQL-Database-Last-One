-- =====================================================================
-- ICT371 Advanced Database - Question 10: Scholarship Application Assessment
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q10, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three students, six PENDING applications with
--     qualifying, non-qualifying and boundary cases
-- ---------------------------------------------------------------------
INSERT INTO students (student_number, full_name) VALUES
    ('2025201', 'Naomi Chisenga'),
    ('2025202', 'Victor Kaunda'),
    ('2025203', 'Ireen Mwale');

INSERT INTO applications (student_id, age_at_application, monthly_income, average_mark, submitted_on) VALUES
    (1, 18, 3000.00, 70.00, CURRENT_DATE - 20),   -- 1 all three boundaries -> APPROVED
    (2, 25, 2999.99, 85.50, CURRENT_DATE - 18),   -- 2 upper age boundary    -> APPROVED
    (3, 17, 1200.00, 90.00, CURRENT_DATE - 15),   -- 3 age 17 (just below)   -> REJECTED
    (1, 26, 1500.00, 80.00, CURRENT_DATE - 12),   -- 4 age 26 (just above)   -> REJECTED
    (2, 21, 3000.01, 75.00, CURRENT_DATE - 10),   -- 5 income 1 ngwee over   -> REJECTED
    (3, 22, 2500.00, 69.99, CURRENT_DATE - 5);    -- 6 mark just below 70    -> REJECTED

SELECT * FROM applications ORDER BY application_id;
