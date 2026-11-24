-- =====================================================================
-- ICT371 Advanced Database - Question 6: Monthly Payroll Processing
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q6, public;

-- ---------------------------------------------------------------------
-- (g) Schedule pr_process_payroll at 02:00 on the 1st of every month,
--     passing the first date of the previous month (pg_cron).
--     pg_cron must be in shared_preload_libraries; times are UTC unless
--     cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q6_monthly_payroll',
    '0 2 1 * *',
    $job$CALL q6.pr_process_payroll((date_trunc('month', CURRENT_DATE) - INTERVAL '1 month')::date)$job$
);

-- Inspect the job
SELECT jobid, jobname, schedule, command, database, username, active
FROM cron.job
WHERE jobname = 'q6_monthly_payroll';

-- Inspect its run history (empty until the first run)
SELECT d.runid, d.status, d.return_message, d.start_time, d.end_time
FROM cron.job_run_details d
JOIN cron.job j ON j.jobid = d.jobid
WHERE j.jobname = 'q6_monthly_payroll'
ORDER BY d.start_time DESC;
