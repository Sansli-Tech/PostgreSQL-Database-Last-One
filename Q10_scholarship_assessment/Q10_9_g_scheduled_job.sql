-- =====================================================================
-- ICT371 Advanced Database - Question 10: Scholarship Application Assessment
-- (g) Scheduled job
-- Run order: file 9 of 9 in this folder.
-- =====================================================================

SET search_path TO q10, public;

-- ---------------------------------------------------------------------
-- (g) Procedure pr_assess_pending() — query FOR loop over PENDING only
--     Already assessed rows are never selected, so reruns do nothing and
--     the trigger writes no duplicate audit rows.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_assess_pending()
LANGUAGE plpgsql
SET search_path = q10         -- so the scheduler can call it from any session
AS $$
DECLARE
    r_app RECORD;
BEGIN
    FOR r_app IN
        SELECT application_id
        FROM applications
        WHERE status = 'PENDING'
        ORDER BY submitted_on, application_id
    LOOP
        CALL pr_assess_application(r_app.application_id);
    END LOOP;
END;
$$;

CALL pr_assess_pending();      -- assesses applications 2–6
SELECT application_id, age_at_application, monthly_income, average_mark, status
FROM applications ORDER BY application_id;

SELECT count(*) AS audit_rows_after_first_run FROM decision_audit;   -- 6
CALL pr_assess_pending();      -- rerun: nothing PENDING
SELECT count(*) AS audit_rows_after_rerun     FROM decision_audit;   -- still 6

-- Unchanged status creates no audit entry
UPDATE applications SET status = status WHERE application_id = 2;
SELECT * FROM decision_audit ORDER BY audit_id;

SELECT * FROM v_approved_applicants ORDER BY student_number;   -- applications 1 and 2

-- Schedule every Monday at 08:00 (pg_cron; day-of-week 1 = Monday).
-- pg_cron must be in shared_preload_libraries; times are UTC unless
-- cron.timezone is set (e.g. ALTER SYSTEM SET cron.timezone = 'Africa/Lusaka').
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'q10_assess_pending_applications',
    '0 8 * * 1',
    $job$CALL q10.pr_assess_pending()$job$
);

SELECT jobid, jobname, schedule, command, active
FROM cron.job
WHERE jobname = 'q10_assess_pending_applications';
