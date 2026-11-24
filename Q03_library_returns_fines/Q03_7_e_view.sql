-- =====================================================================
-- ICT371 Advanced Database - Question 3: Library Returns and Overdue Fines
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q3, public;

-- ---------------------------------------------------------------------
-- (e) View: unreturned loans due before today, with today's fine
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_overdue_loans AS
SELECT l.loan_id,
       b.title,
       l.borrower_name,
       l.due_on,
       fn_loan_fine(l.loan_id, CURRENT_DATE) AS fine_as_of_today
FROM loans l
JOIN books b ON b.book_id = l.book_id
WHERE l.returned_on IS NULL
  AND l.due_on < CURRENT_DATE;

SELECT * FROM v_overdue_loans ORDER BY due_on;   -- loans 1 and 5
