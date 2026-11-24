-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (c) Procedure
-- Run order: file 3 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (c) Procedure: pr_generate_bill(p_reading_id, p_due_on)
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_generate_bill(p_reading_id INTEGER, p_due_on DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_units  NUMERIC(12,2);
    v_charge NUMERIC(12,2);
BEGIN
    IF p_due_on IS NULL THEN
        RAISE EXCEPTION 'A due date is required';
    END IF;

    SELECT current_reading - previous_reading INTO v_units
    FROM readings
    WHERE reading_id = p_reading_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown reading id %', p_reading_id;
    END IF;

    IF EXISTS (SELECT 1 FROM bills WHERE reading_id = p_reading_id) THEN
        RAISE EXCEPTION 'Reading % has already been billed', p_reading_id;
    END IF;

    v_charge := fn_water_charge(v_units);

    INSERT INTO bills (reading_id, charge, amount_paid, due_on)
    VALUES (p_reading_id, v_charge, 0, p_due_on);
END;
$$;
