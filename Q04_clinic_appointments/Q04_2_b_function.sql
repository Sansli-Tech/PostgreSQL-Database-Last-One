-- =====================================================================
-- ICT371 Advanced Database - Question 4: Clinic Appointment Scheduling
-- (b) Function
-- Run order: file 2 of 9 in this folder.
-- =====================================================================

SET search_path TO q4, public;

-- ---------------------------------------------------------------------
-- (b) Function: fn_daily_load(p_doctor_id, p_day)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_daily_load(p_doctor_id INTEGER, p_day DATE)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM doctors WHERE doctor_id = p_doctor_id) THEN
        RAISE EXCEPTION 'Unknown doctor id %', p_doctor_id;
    END IF;

    -- COUNT(*) returns 0 when the day has no bookings.
    SELECT COUNT(*) INTO v_count
    FROM appointments
    WHERE doctor_id = p_doctor_id
      AND appointment_day = p_day
      AND status <> 'CANCELLED';

    RETURN v_count;
END;
$$;
