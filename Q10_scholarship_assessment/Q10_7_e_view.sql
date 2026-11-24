-- =====================================================================
-- ICT371 Advanced Database - Question 10: Scholarship Application Assessment
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q10, public;

-- ---------------------------------------------------------------------
-- (e) View: APPROVED applicants only; household income not exposed
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_approved_applicants AS
SELECT s.student_number,
       s.full_name,
       a.average_mark,
       a.status
FROM applications a
JOIN students s ON s.student_id = a.student_id
WHERE a.status = 'APPROVED';

SELECT * FROM v_approved_applicants ORDER BY student_number;   -- application 1 so far (2 is assessed in part g)
