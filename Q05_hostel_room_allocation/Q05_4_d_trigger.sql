-- =====================================================================
-- ICT371 Advanced Database - Question 5: Hostel Room Allocation
-- (d) Trigger
-- Run order: file 4 of 9 in this folder.
-- =====================================================================

SET search_path TO q5, public;

-- ---------------------------------------------------------------------
-- (d) Trigger: enforce capacity and one ACTIVE allocation per student
--     for ALL changes, including direct SQL (created before seeding)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_allocation_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacity INTEGER;
    v_others   INTEGER;
BEGIN
    -- ENDED rows occupy nothing, so they need no capacity check.
    IF NEW.status <> 'ACTIVE' THEN
        RETURN NEW;
    END IF;

    -- Lock the room (concurrent allocations to it wait) and the student.
    SELECT capacity INTO v_capacity FROM rooms WHERE room_id = NEW.room_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown room id %', NEW.room_id;
    END IF;
    PERFORM 1 FROM students WHERE student_id = NEW.student_id FOR UPDATE;

    -- One ACTIVE allocation per student (exclude the row being updated).
    IF EXISTS (
        SELECT 1 FROM allocations a
        WHERE a.student_id = NEW.student_id
          AND a.status = 'ACTIVE'
          AND (TG_OP = 'INSERT' OR a.allocation_id <> OLD.allocation_id)
    ) THEN
        RAISE EXCEPTION 'Student % already has an ACTIVE allocation', NEW.student_id;
    END IF;

    -- Capacity (exclude the row being updated).
    SELECT COUNT(*) INTO v_others
    FROM allocations a
    WHERE a.room_id = NEW.room_id
      AND a.status = 'ACTIVE'
      AND (TG_OP = 'INSERT' OR a.allocation_id <> OLD.allocation_id);

    IF v_others >= v_capacity THEN
        RAISE EXCEPTION 'Room % is full (capacity %)', NEW.room_id, v_capacity;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_allocations_rules
BEFORE INSERT OR UPDATE ON allocations
FOR EACH ROW
EXECUTE FUNCTION trg_fn_allocation_rules();
