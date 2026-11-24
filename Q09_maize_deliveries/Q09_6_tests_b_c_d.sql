-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT fn_maize_rate('A') AS a, fn_maize_rate('B') AS b, fn_maize_rate('C') AS c;

DO $$
BEGIN
    PERFORM fn_maize_rate('D');
    RAISE NOTICE 'UNEXPECTED: grade D accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    PERFORM fn_maize_rate(NULL);
    RAISE NOTICE 'UNEXPECTED: NULL grade accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_receive_delivery(999, 'A', 100, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: unknown farmer accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_receive_delivery(1, 'A', 0, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: zero weight accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Direct SQL with a wrong price is corrected by the trigger
INSERT INTO deliveries (farmer_id, grade, weight_kg, unit_rate, total_value, delivered_on)
VALUES (2, 'C', 100.00, 99.00, 9900.00, CURRENT_DATE);
SELECT delivery_id, grade, weight_kg, unit_rate, total_value
FROM deliveries WHERE delivery_id = currval('deliveries_delivery_id_seq');  -- 3.00, 300.00

-- Changing a grade by UPDATE re-prices the row
UPDATE deliveries SET grade = 'B' WHERE delivery_id = currval('deliveries_delivery_id_seq');
SELECT delivery_id, grade, unit_rate, total_value
FROM deliveries WHERE delivery_id = currval('deliveries_delivery_id_seq');  -- 4.00, 400.00

-- Remove the demo row so the seed set stays at six deliveries
DELETE FROM deliveries WHERE delivery_id = currval('deliveries_delivery_id_seq');

-- Direct SQL with non-positive weight is rejected by the trigger
DO $$
BEGIN
    INSERT INTO deliveries (farmer_id, grade, weight_kg, delivered_on)
    VALUES (2, 'B', -5, CURRENT_DATE);
    RAISE NOTICE 'UNEXPECTED: negative weight stored';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;
