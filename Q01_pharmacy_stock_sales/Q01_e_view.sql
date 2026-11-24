-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (e) View: medicines with stock below 10
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_low_stock AS
SELECT medicine_id, medicine_name, unit_price, stock_qty AS remaining_stock
FROM medicines
WHERE stock_qty < 10;

-- Query the view after a sale
SELECT * FROM v_low_stock;
