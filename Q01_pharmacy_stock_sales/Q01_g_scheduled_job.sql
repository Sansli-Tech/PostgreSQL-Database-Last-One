-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_sales(p_day) — idempotent daily summary
--     An aggregate without GROUP BY always returns one row, so a day with
--     no sales is stored as zeros. ON CONFLICT replaces the existing row,
--     so a rerun never duplicates or double-counts.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_sales(p_day DATE)
LANGUAGE plpgsql
SET search_path = q1          -- so the scheduler can call it from any session
AS $$
BEGIN
    IF p_day IS NULL THEN
        RAISE EXCEPTION 'A day is required';
    END IF;

    INSERT INTO daily_sales (sales_date, total_qty, total_amount)
    SELECT p_day,
           COALESCE(SUM(quantity), 0),
           COALESCE(SUM(quantity * unit_price), 0)
    FROM sales
    WHERE sold_on = p_day
    ON CONFLICT (sales_date) DO UPDATE
        SET total_qty    = EXCLUDED.total_qty,
            total_amount = EXCLUDED.total_amount;
END;
$$;

-- Run twice for yesterday: still one row with the same totals.
CALL pr_refresh_sales(CURRENT_DATE - 1);
CALL pr_refresh_sales(CURRENT_DATE - 1);
CALL pr_refresh_sales(CURRENT_DATE - 2);
SELECT * FROM daily_sales ORDER BY sales_date;   -- yesterday: 27 units, 88.25

-- Schedule daily at 00:15 for the previous day (pg_cron).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q1_refresh_daily_sales',
    '15 0 * * *',
    $job$CALL q1.pr_refresh_sales(CURRENT_DATE - 1)$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q1_refresh_daily_sales';
