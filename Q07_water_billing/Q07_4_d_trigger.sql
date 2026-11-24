-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (d) Trigger
-- Run order: file 4 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (d) Trigger: reject a current reading below the previous reading,
--     including direct SQL imports (created before seeding)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_reading_check()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.current_reading < NEW.previous_reading THEN
        RAISE EXCEPTION 'Current reading % is below previous reading % (customer %, %)',
                        NEW.current_reading, NEW.previous_reading,
                        NEW.customer_id, NEW.reading_month;
    END IF;
    RETURN NEW;     -- raising above means the row is never stored
END;
$$;

CREATE TRIGGER trg_readings_check
BEFORE INSERT OR UPDATE ON readings
FOR EACH ROW
EXECUTE FUNCTION trg_fn_reading_check();
