-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT fn_sale_value(2, 4) AS value_of_4_amoxicillin;   -- 35.00

DO $$
BEGIN
    PERFORM fn_sale_value(999, 1);
    RAISE NOTICE 'UNEXPECTED: unknown medicine accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    PERFORM fn_sale_value(1, 0);
    RAISE NOTICE 'UNEXPECTED: zero quantity accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Overselling must fail and leave both tables unchanged.
DO $$
DECLARE
    v_sales_before INTEGER;
    v_stock_before INTEGER;
BEGIN
    SELECT count(*) INTO v_sales_before FROM sales;
    SELECT stock_qty INTO v_stock_before FROM medicines WHERE medicine_id = 3;
    BEGIN
        CALL pr_record_sale(3, 500, CURRENT_DATE);
        RAISE NOTICE 'UNEXPECTED: oversell accepted';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Rejected as expected: %', SQLERRM;
    END;
    RAISE NOTICE 'Sales rows before/after: % / %', v_sales_before, (SELECT count(*) FROM sales);
    RAISE NOTICE 'ORS stock before/after: % / %', v_stock_before,
                 (SELECT stock_qty FROM medicines WHERE medicine_id = 3);
END $$;

-- An update that does not change stock_qty must NOT be audited.
UPDATE medicines SET unit_price = 2.60 WHERE medicine_id = 1;
UPDATE medicines SET stock_qty  = stock_qty WHERE medicine_id = 1;
-- A manual restock IS audited.
UPDATE medicines SET stock_qty = stock_qty + 50 WHERE medicine_id = 2;

SELECT * FROM stock_audit ORDER BY audit_id;   -- 6 sale rows + 1 restock row
