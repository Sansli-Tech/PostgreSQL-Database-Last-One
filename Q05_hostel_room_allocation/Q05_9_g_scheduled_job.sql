-- =====================================================================
-- ICT371 Advanced Database - Question 5: Hostel Room Allocation
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q5, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_occupancy() — one row per date and room
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_occupancy()
LANGUAGE plpgsql
SET search_path = q5          -- so the scheduler can call it from any session
AS $$
BEGIN
    INSERT INTO occupancy_snapshot (snapshot_date, room_id, occupied_beds, free_beds)
    SELECT CURRENT_DATE, room_id, occupied_beds, free_beds
    FROM v_room_occupancy
    ON CONFLICT (snapshot_date, room_id) DO UPDATE
        SET occupied_beds = EXCLUDED.occupied_beds,
            free_beds     = EXCLUDED.free_beds;
END;
$$;

CALL pr_refresh_occupancy();
CALL pr_allocate_room(5, 3, CURRENT_DATE);   -- occupancy changes
CALL pr_refresh_occupancy();                 -- rerun replaces today's rows
SELECT * FROM occupancy_snapshot ORDER BY room_id;   -- still 3 rows

-- Schedule daily at 23:55 (pg_cron).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q5_refresh_occupancy',
    '55 23 * * *',
    $job$CALL q5.pr_refresh_occupancy()$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q5_refresh_occupancy';
