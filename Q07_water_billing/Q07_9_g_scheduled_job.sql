-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_refresh_receivables() — today's total unpaid balance
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_refresh_receivables()
LANGUAGE plpgsql
SET search_path = q7          -- so the scheduler can call it from any session
AS $$
BEGIN
    INSERT INTO receivable_snapshot (snapshot_date, total_due)
    SELECT CURRENT_DATE, COALESCE(SUM(charge - amount_paid), 0)
    FROM bills
    WHERE amount_paid < charge
    ON CONFLICT (snapshot_date) DO UPDATE
        SET total_due = EXCLUDED.total_due;
END;
$$;

CALL pr_refresh_receivables();
UPDATE bills SET amount_paid = 30.00 WHERE bill_id = 4;    -- a payment comes in
CALL pr_refresh_receivables();                              -- rerun replaces today's total
SELECT * FROM receivable_snapshot;                          -- 74 + 7.5 + 50 = 131.50

-- Schedule daily at 00:30 (pg_cron).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q7_refresh_receivables',
    '30 0 * * *',
    $job$CALL q7.pr_refresh_receivables()$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q7_refresh_receivables';
