-- =====================================================================
-- ICT371 Advanced Database - Question 4: Clinic Appointment Scheduling
-- (d) Trigger
-- Run order: file 4 of 9 in this folder.
-- =====================================================================

SET search_path TO q4, public;

-- ---------------------------------------------------------------------
-- (d) Trigger: reject slot clashes on INSERT or UPDATE
--     (created before seeding so seed data is checked too)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_appointment_clash()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- A cancelled appointment never occupies a slot.
    IF NEW.status = 'CANCELLED' THEN
        RETURN NEW;
    END IF;

    -- Serialise concurrent bookings for the same doctor/day/slot so two
    -- sessions cannot both pass the check before either commits.
    PERFORM pg_advisory_xact_lock(
        hashtext(NEW.doctor_id || '|' || NEW.appointment_day || '|' || NEW.slot_time));

    IF EXISTS (
        SELECT 1
        FROM appointments a
        WHERE a.doctor_id       = NEW.doctor_id
          AND a.appointment_day = NEW.appointment_day
          AND a.slot_time       = NEW.slot_time
          AND a.status         <> 'CANCELLED'
          -- On UPDATE, ignore the row being changed.
          AND (TG_OP = 'INSERT' OR a.appointment_id <> OLD.appointment_id)
    ) THEN
        RAISE EXCEPTION 'Doctor % already has an appointment on % at %',
                        NEW.doctor_id, NEW.appointment_day, NEW.slot_time;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_appointments_no_clash
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_appointment_clash();
