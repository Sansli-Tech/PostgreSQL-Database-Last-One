-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (c) Procedure
-- Run order: file 3 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (c) Procedure: pr_record_sale(p_medicine_id, p_quantity, p_sold_on)
--     All checks happen before any write. If anything raises, the whole
--     CALL is rolled back, so sales and medicines stay unchanged.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_record_sale(
    p_medicine_id INTEGER,
    p_quantity    INTEGER,
    p_sold_on     DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC(10,2);
    v_stock INTEGER;
BEGIN
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be a positive whole number (got %)', p_quantity;
    END IF;
    IF p_sold_on IS NULL THEN
        RAISE EXCEPTION 'Sale date is required';
    END IF;

    -- Lock the medicine row so two tills cannot sell the same last units.
    SELECT unit_price, stock_qty INTO v_price, v_stock
    FROM medicines
    WHERE medicine_id = p_medicine_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown medicine id %', p_medicine_id;
    END IF;

    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock for medicine %: requested %, available %',
                        p_medicine_id, p_quantity, v_stock;
    END IF;

    -- Store the current price with the sale.
    INSERT INTO sales (medicine_id, quantity, unit_price, sold_on)
    VALUES (p_medicine_id, p_quantity, v_price, p_sold_on);

    -- Deduct stock exactly once.
    UPDATE medicines
    SET stock_qty = stock_qty - p_quantity
    WHERE medicine_id = p_medicine_id;
END;
$$;
