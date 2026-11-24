-- =====================================================================
-- ICT371 Advanced Database - Question 3: Library Returns and Overdue Fines
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q3, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three books, six loans (dates relative to today so the
--     overdue cases stay overdue whenever the script is run)
-- ---------------------------------------------------------------------
INSERT INTO books (title) VALUES
    ('Database System Concepts'),
    ('Things Fall Apart'),
    ('Introduction to Algorithms');

INSERT INTO loans (book_id, borrower_name, borrowed_on, due_on) VALUES
    (1, 'Natasha Banda',  CURRENT_DATE - 30, CURRENT_DATE - 16),  -- 1 open, overdue 16 days
    (2, 'Kondwani Zulu',  CURRENT_DATE - 40, CURRENT_DATE - 26),  -- 2 returned on due date
    (3, 'Mwape Lungu',    CURRENT_DATE - 40, CURRENT_DATE - 26),  -- 3 returned 3 days late
    (2, 'Chileshe Mumba', CURRENT_DATE - 5,  CURRENT_DATE + 9),   -- 4 open, not yet due
    (3, 'Thandiwe Sakala',CURRENT_DATE - 15, CURRENT_DATE - 1),   -- 5 open, overdue 1 day
    (1, 'Mulenga Daka',   CURRENT_DATE - 60, CURRENT_DATE - 46);  -- 6 returned early

CALL pr_return_loan(2, CURRENT_DATE - 26);   -- on time: fine 0
CALL pr_return_loan(3, CURRENT_DATE - 23);   -- 3 days late: fine 6
CALL pr_return_loan(6, CURRENT_DATE - 50);   -- early: fine 0

SELECT * FROM loans ORDER BY loan_id;
