-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- (d) Trigger
-- Run order: file 4 of 9 in this folder.
-- =====================================================================

SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- (d) Trigger: validate weight and set unit_rate / total_value on every
--     INSERT or UPDATE (installed before any deliveries are loaded)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_delivery_pricing()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.weight_kg IS NULL OR NEW.weight_kg <= 0 THEN
        RAISE EXCEPTION 'Weight must be greater than zero (got %)', NEW.weight_kg;
    END IF;

    -- Whatever a direct INSERT/UPDATE supplied is overwritten.
    NEW.unit_rate   := fn_maize_rate(NEW.grade);
    NEW.total_value := ROUND(NEW.weight_kg * NEW.unit_rate, 2);

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_deliveries_pricing
BEFORE INSERT OR UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION trg_fn_delivery_pricing();
