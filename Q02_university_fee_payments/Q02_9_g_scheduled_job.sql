-- =====================================================================
-- ICT371 Advanced Database - Question 2: University Fee Payments
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q2, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_collections(p_day) — replaces on rerun
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_collections(p_day DATE)
LANGUAGE plpgsql
SET search_path = q2          -- so the scheduler can call it from any session
AS $$
BEGIN
    IF p_day IS NULL THEN
        RAISE EXCEPTION 'A day is required';
    END IF;

    INSERT INTO daily_collections (collection_date, payment_count, total_amount)
    SELECT p_day, COUNT(*), COALESCE(SUM(amount), 0)
    FROM payments
    WHERE paid_on = p_day
    ON CONFLICT (collection_date) DO UPDATE
        SET payment_count = EXCLUDED.payment_count,
            total_amount  = EXCLUDED.total_amount;
END;
$$;

CALL pr_refresh_collections(CURRENT_DATE - 1);
CALL pr_refresh_collections(CURRENT_DATE - 1);   -- rerun replaces, no duplicate
CALL pr_refresh_collections(CURRENT_DATE - 3);
SELECT * FROM daily_collections ORDER BY collection_date;  -- yesterday: 3 payments, 3500.00

-- Schedule daily at 01:00 for the previous day (pg_cron).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q2_refresh_daily_collections',
    '0 1 * * *',
    $job$CALL q2.pr_refresh_collections(CURRENT_DATE - 1)$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q2_refresh_daily_collections';
