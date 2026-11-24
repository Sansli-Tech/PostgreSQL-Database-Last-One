-- =====================================================================
-- ICT371 Advanced Database - Question 3: Library Returns and Overdue Fines
-- (b) Function
-- Run order: file 2 of 9 in this folder.
-- =====================================================================

SET search_path TO q3, public;

-- ---------------------------------------------------------------------
-- (b) Function: fn_loan_fine(p_loan_id, p_as_of)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_loan_fine(p_loan_id INTEGER, p_as_of DATE)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_due      DATE;
    v_returned DATE;
    v_end      DATE;
BEGIN
    IF p_as_of IS NULL THEN
        RAISE EXCEPTION 'An as-of date is required';
    END IF;

    SELECT due_on, returned_on INTO v_due, v_returned
    FROM loans
    WHERE loan_id = p_loan_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown loan id %', p_loan_id;
    END IF;

    -- A returned loan stops accumulating fines at its return date.
    IF v_returned IS NOT NULL THEN
        v_end := LEAST(p_as_of, v_returned);
    ELSE
        v_end := p_as_of;
    END IF;

    -- date - date gives whole days; minimum of zero.
    RETURN (GREATEST(v_end - v_due, 0) * 2)::NUMERIC(10,2);
END;
$$;
