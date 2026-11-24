-- =====================================================================
-- ICT371 Advanced Database - Question 10: Scholarship Application Assessment
-- (c) Procedure
-- Run order: file 3 of 9 in this folder.
-- =====================================================================

SET search_path TO q10, public;

-- ---------------------------------------------------------------------
-- (c) Procedure: pr_assess_application(p_application_id)
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_assess_application(p_application_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_app      applications%ROWTYPE;
    v_eligible BOOLEAN;
BEGIN
    SELECT * INTO v_app
    FROM applications
    WHERE application_id = p_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown application id %', p_application_id;
    END IF;
    IF v_app.status <> 'PENDING' THEN
        RAISE EXCEPTION 'Application % has already been assessed (status %)',
                        p_application_id, v_app.status;
    END IF;

    v_eligible := fn_scholarship_eligible(v_app.age_at_application,
                                          v_app.monthly_income,
                                          v_app.average_mark);

    UPDATE applications
    SET status = CASE WHEN v_eligible THEN 'APPROVED' ELSE 'REJECTED' END
    WHERE application_id = p_application_id;
END;
$$;
