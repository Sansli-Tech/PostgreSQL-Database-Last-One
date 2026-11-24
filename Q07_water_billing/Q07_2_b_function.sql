-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (b) Function
-- Run order: file 2 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (b) Function: fn_water_charge(p_units)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_water_charge(p_units NUMERIC)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_units IS NULL OR p_units < 0 THEN
        RAISE EXCEPTION 'Consumption must be zero or more (got %)', p_units;
    END IF;

    RETURN ROUND(
        LEAST(p_units, 10) * 5                -- band 1: first 10 units at K5
      + GREATEST(p_units - 10, 0) * 8,        -- band 2: units above 10 at K8
      2);
END;
$$;
