-- =====================================================================
-- ICT371 Advanced Database - Question 4: Clinic Appointment Scheduling
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q4, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_clinic_summary(p_day) — replaces on rerun
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_clinic_summary(p_day DATE)
LANGUAGE plpgsql
SET search_path = q4          -- so the scheduler can call it from any session
AS $$
BEGIN
    IF p_day IS NULL THEN
        RAISE EXCEPTION 'A day is required';
    END IF;

    INSERT INTO clinic_summary (summary_date, booked_count, attended_count, cancelled_count)
    SELECT p_day,
           COUNT(*) FILTER (WHERE status = 'BOOKED'),
           COUNT(*) FILTER (WHERE status = 'ATTENDED'),
           COUNT(*) FILTER (WHERE status = 'CANCELLED')
    FROM appointments
    WHERE appointment_day = p_day
    ON CONFLICT (summary_date) DO UPDATE
        SET booked_count    = EXCLUDED.booked_count,
            attended_count  = EXCLUDED.attended_count,
            cancelled_count = EXCLUDED.cancelled_count;
END;
$$;

CALL pr_refresh_clinic_summary(CURRENT_DATE - 1);
CALL pr_refresh_clinic_summary(CURRENT_DATE - 1);   -- rerun replaces
SELECT * FROM clinic_summary;                        -- 1 booked, 1 attended, 1 cancelled

-- Schedule daily at 01:00 for the previous day (pg_cron).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q4_refresh_clinic_summary',
    '0 1 * * *',
    $job$CALL q4.pr_refresh_clinic_summary(CURRENT_DATE - 1)$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q4_refresh_clinic_summary';
