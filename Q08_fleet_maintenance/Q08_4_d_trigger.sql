-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (d) Trigger
-- Run order: file 4 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (d) Trigger: BEFORE INSERT on trips — check start odometer, reject bad
--     mileage and move the vehicle odometer forward exactly once.
--     (Installed before any trips are loaded.)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_trip_odometer()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_current NUMERIC(10,1);
BEGIN
    -- Lock the vehicle so two trips cannot start from the same reading.
    SELECT current_odometer INTO v_current
    FROM vehicles
    WHERE vehicle_id = NEW.vehicle_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown vehicle id %', NEW.vehicle_id;
    END IF;

    IF NEW.start_odometer IS DISTINCT FROM v_current THEN
        RAISE EXCEPTION 'Trip start % does not match vehicle % current odometer %',
                        NEW.start_odometer, NEW.vehicle_id, v_current;
    END IF;

    IF NEW.end_odometer IS NULL OR NEW.end_odometer <= NEW.start_odometer THEN
        RAISE EXCEPTION 'Invalid mileage: end % must be greater than start %',
                        NEW.end_odometer, NEW.start_odometer;
    END IF;

    -- The one and only place the odometer is advanced.
    UPDATE vehicles
    SET current_odometer = NEW.end_odometer
    WHERE vehicle_id = NEW.vehicle_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_trips_odometer
BEFORE INSERT ON trips
FOR EACH ROW
EXECUTE FUNCTION trg_fn_trip_odometer();
