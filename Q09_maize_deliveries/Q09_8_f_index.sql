-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- (f) Composite index for a farmer's deliveries between two dates
--     Equality column farmer_id first, range column delivered_on second,
--     so the B-tree jumps to one farmer and reads only the date range.
--     It also indexes the FK column farmer_id.
-- ---------------------------------------------------------------------
CREATE INDEX idx_deliveries_farmer_date ON deliveries (farmer_id, delivered_on);
ANALYZE deliveries;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT delivery_id, grade, weight_kg, total_value, delivered_on
FROM deliveries
WHERE farmer_id = 1
  AND delivered_on BETWEEN CURRENT_DATE - 7 AND CURRENT_DATE;
RESET enable_seqscan;
