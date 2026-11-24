-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (c) Procedure
-- Run order: file 3 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (c) Procedure: pr_record_trip(p_vehicle_id, p_trip_on, p_start, p_end)
--     Inserts the trip only; the trigger updates the odometer.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_record_trip(
    p_vehicle_id INTEGER,
    p_trip_on    DATE,
    p_start      NUMERIC,
    p_end        NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM vehicles WHERE vehicle_id = p_vehicle_id) THEN
        RAISE EXCEPTION 'Unknown vehicle id %', p_vehicle_id;
    END IF;
    IF p_trip_on IS NULL THEN
        RAISE EXCEPTION 'Trip date is required';
    END IF;
    IF p_start IS NULL OR p_end IS NULL OR p_end <= p_start THEN
        RAISE EXCEPTION 'End odometer (%) must be greater than start odometer (%)', p_end, p_start;
    END IF;

    INSERT INTO trips (vehicle_id, trip_on, start_odometer, end_odometer)
    VALUES (p_vehicle_id, p_trip_on, p_start, p_end);
END;
$$;
