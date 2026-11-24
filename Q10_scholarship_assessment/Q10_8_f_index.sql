-- =====================================================================
-- ICT371 Advanced Database - Question 10: Scholarship Application Assessment
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q10, public;

-- ---------------------------------------------------------------------
-- (f) Index for applications by status within a submitted_on range
--     Equality column (status) first, range column (submitted_on)
--     second: the B-tree goes to e.g. the PENDING entries and reads only
--     the dates in range. pr_assess_pending's "status = 'PENDING'" scan
--     uses the same index.
-- ---------------------------------------------------------------------
CREATE INDEX idx_applications_status_submitted ON applications (status, submitted_on);
ANALYZE applications;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT application_id, student_id, submitted_on
FROM applications
WHERE status = 'PENDING'
  AND submitted_on BETWEEN CURRENT_DATE - 30 AND CURRENT_DATE;
RESET enable_seqscan;
