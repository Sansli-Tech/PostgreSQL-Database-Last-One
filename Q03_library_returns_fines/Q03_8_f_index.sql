-- =====================================================================
-- ICT371 Advanced Database - Question 3: Library Returns and Overdue Fines
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q3, public;

-- ---------------------------------------------------------------------
-- (f) Index for a given book's unreturned loans
--     A partial index on book_id that only contains open loans
--     (returned_on IS NULL). The search is "book_id = ? AND returned_on
--     IS NULL", so the index holds exactly the rows the query can return,
--     stays small as returned history grows, and is cheap to maintain.
-- ---------------------------------------------------------------------
CREATE INDEX idx_loans_open_by_book ON loans (book_id) WHERE returned_on IS NULL;
ANALYZE loans;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT loan_id, borrower_name, borrowed_on, due_on
FROM loans
WHERE book_id = 1
  AND returned_on IS NULL;
RESET enable_seqscan;
