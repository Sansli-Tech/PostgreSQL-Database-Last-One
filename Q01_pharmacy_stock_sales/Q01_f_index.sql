-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (f) Index for one medicine's sales within a sold_on date range
--     Justification: the query filters on equality (medicine_id = ?) and
--     a range (sold_on BETWEEN ? AND ?). A composite B-tree with the
--     equality column first and the range column second lets PostgreSQL
--     jump to that medicine and scan only the matching dates, instead of
--     reading the whole sales table. The FK column is not indexed by
--     default, so this also speeds up FK checks on medicines.
-- ---------------------------------------------------------------------
CREATE INDEX idx_sales_medicine_sold_on ON sales (medicine_id, sold_on);
ANALYZE sales;

-- With only six rows the planner would rightly choose a sequential scan,
-- so seq scans are switched off for this demo to show the index being used.
SET enable_seqscan = off;
EXPLAIN
SELECT sale_id, quantity, unit_price, sold_on
FROM sales
WHERE medicine_id = 1
  AND sold_on BETWEEN CURRENT_DATE - 7 AND CURRENT_DATE;
RESET enable_seqscan;
