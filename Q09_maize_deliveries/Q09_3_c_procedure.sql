-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- (c) Procedure
-- Run order: file 3 of 9 in this folder.
-- =====================================================================

SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- (c) Procedure: pr_receive_delivery(p_farmer_id, p_grade, p_weight, p_date)
--     Inserts only the basic fields with is_paid = false; the trigger
--     supplies unit_rate and total_value.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_receive_delivery(
    p_farmer_id INTEGER,
    p_grade     TEXT,
    p_weight    NUMERIC,
    p_date      DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM farmers WHERE farmer_id = p_farmer_id) THEN
        RAISE EXCEPTION 'Unknown farmer id %', p_farmer_id;
    END IF;
    PERFORM fn_maize_rate(p_grade);              -- rejects NULL / unsupported grade
    IF p_weight IS NULL OR p_weight <= 0 THEN
        RAISE EXCEPTION 'Weight must be greater than zero (got %)', p_weight;
    END IF;
    IF p_date IS NULL OR p_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Delivery date % is missing or in the future', p_date;
    END IF;

    INSERT INTO deliveries (farmer_id, grade, weight_kg, delivered_on, is_paid)
    VALUES (p_farmer_id, p_grade, p_weight, p_date, FALSE);
END;
$$;
