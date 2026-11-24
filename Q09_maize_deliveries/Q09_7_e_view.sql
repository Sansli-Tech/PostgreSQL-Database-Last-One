-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- (e) View
-- Run order: file 7 of 9 in this folder.
-- =====================================================================

SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- (e) View: each farmer's unpaid total (zero when nothing is owed)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_farmer_amount_due AS
SELECT f.farmer_number,
       f.full_name,
       COALESCE(SUM(d.total_value) FILTER (WHERE NOT d.is_paid), 0)::NUMERIC(12,2) AS amount_due
FROM farmers f
LEFT JOIN deliveries d ON d.farmer_id = f.farmer_id
GROUP BY f.farmer_id, f.farmer_number, f.full_name;

SELECT * FROM v_farmer_amount_due ORDER BY farmer_number;   -- F003 shows 0.00
