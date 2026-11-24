-- =====================================================================
-- ICT371 Advanced Database - Question 3: Library Returns and Overdue Fines
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q3, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_overdue(p_as_of)
--     A loan counts if, on p_as_of, it had been borrowed, was past its
--     due date and had not yet been returned (returned_on NULL or later
--     than p_as_of). This also gives correct figures for past dates.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_overdue(p_as_of DATE)
LANGUAGE plpgsql
SET search_path = q3          -- so the scheduler can call it from any session
AS $$
BEGIN
    IF p_as_of IS NULL THEN
        RAISE EXCEPTION 'An as-of date is required';
    END IF;

    INSERT INTO overdue_summary (snapshot_date, overdue_count, total_fine)
    SELECT p_as_of,
           COUNT(*),
           COALESCE(SUM(fn_loan_fine(loan_id, p_as_of)), 0)
    FROM loans
    WHERE borrowed_on <= p_as_of
      AND due_on < p_as_of
      AND (returned_on IS NULL OR returned_on > p_as_of)
    ON CONFLICT (snapshot_date) DO UPDATE
        SET overdue_count = EXCLUDED.overdue_count,
            total_fine    = EXCLUDED.total_fine;
END;
$$;

CALL pr_refresh_overdue(CURRENT_DATE);
CALL pr_refresh_overdue(CURRENT_DATE);   -- rerun replaces the same snapshot_date
SELECT * FROM overdue_summary;           -- 2 loans, K34.00

-- Schedule daily at 00:10 for CURRENT_DATE (pg_cron).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q3_refresh_overdue_summary',
    '10 0 * * *',
    $job$CALL q3.pr_refresh_overdue(CURRENT_DATE)$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q3_refresh_overdue_summary';
