-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three medicines, six valid sales loaded via procedure
-- ---------------------------------------------------------------------
INSERT INTO medicines (medicine_name, unit_price, stock_qty) VALUES
    ('Paracetamol 500mg', 2.50, 100),
    ('Amoxicillin 250mg', 8.75,  40),
    ('ORS Sachet',        3.00,  15);

CALL pr_record_sale(1, 10, CURRENT_DATE - 2);
CALL pr_record_sale(2,  5, CURRENT_DATE - 2);
CALL pr_record_sale(1, 20, CURRENT_DATE - 1);
CALL pr_record_sale(3,  4, CURRENT_DATE - 1);
CALL pr_record_sale(2,  3, CURRENT_DATE - 1);
CALL pr_record_sale(3,  2, CURRENT_DATE);      -- ORS stock drops to 9 (low stock)

SELECT * FROM medicines ORDER BY medicine_id;
SELECT * FROM sales     ORDER BY sale_id;
