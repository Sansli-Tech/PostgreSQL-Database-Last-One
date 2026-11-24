-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_service_alerts()
--     Upserts one alert per due vehicle (flagged_on keeps the date the
--     vehicle was first flagged; km is refreshed), then removes alerts
--     for vehicles that are no longer due (e.g. after a service).
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_service_alerts()
LANGUAGE plpgsql
SET search_path = q8          -- so the scheduler can call it from any session
AS $$
BEGIN
    INSERT INTO service_alerts (vehicle_id, km_since_service, flagged_on)
    SELECT vehicle_id, km_since_service, CURRENT_DATE
    FROM v_service_due
    ON CONFLICT (vehicle_id) DO UPDATE
        SET km_since_service = EXCLUDED.km_since_service;

    DELETE FROM service_alerts sa
    USING vehicles v
    WHERE v.vehicle_id = sa.vehicle_id
      AND v.current_odometer - v.last_service_odometer < 5000;
END;
$$;

CALL pr_refresh_service_alerts();
SELECT * FROM service_alerts ORDER BY vehicle_id;   -- vehicles 2 and 3

-- Vehicle 3 is serviced; the next run removes its alert
UPDATE vehicles SET last_service_odometer = current_odometer WHERE vehicle_id = 3;
CALL pr_refresh_service_alerts();
CALL pr_refresh_service_alerts();                   -- rerun: no duplicates
SELECT * FROM service_alerts ORDER BY vehicle_id;   -- vehicle 2 only

-- Schedule every Monday at 06:00 (pg_cron; day-of-week 1 = Monday).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q8_refresh_service_alerts',
    '0 6 * * 1',
    $job$CALL q8.pr_refresh_service_alerts()$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q8_refresh_service_alerts';
