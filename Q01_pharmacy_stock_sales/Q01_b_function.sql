-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (b) Function
-- Run order: file 2 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (b) Function: fn_sale_value(p_medicine_id, p_quantity)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_sale_value(p_medicine_id INTEGER, p_quantity INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC(10,2);
BEGIN
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be a positive whole number (got %)', p_quantity;
    END IF;

    SELECT unit_price INTO v_price
    FROM medicines
    WHERE medicine_id = p_medicine_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown medicine id %', p_medicine_id;
    END IF;

    RETURN v_price * p_quantity;
END;
$$;
