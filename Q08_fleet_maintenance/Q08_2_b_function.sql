-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (b) Function
-- Run order: file 2 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (b) Function: fn_service_due(p_vehicle_id)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_service_due(p_vehicle_id INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_km NUMERIC(10,1);
BEGIN
    SELECT current_odometer - last_service_odometer INTO v_km
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown vehicle id %', p_vehicle_id;
    END IF;

    RETURN v_km >= 5000;
END;
$$;
