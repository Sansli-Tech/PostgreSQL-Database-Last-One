-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three farmers, six deliveries (all grades, paid/unpaid)
-- ---------------------------------------------------------------------
INSERT INTO farmers (farmer_number, full_name) VALUES
    ('F001', 'Kelvin Mbewe'),
    ('F002', 'Precious Lungu'),
    ('F003', 'Joshua Hamweemba');

CALL pr_receive_delivery(1, 'A', 1200.00, CURRENT_DATE - 2);
CALL pr_receive_delivery(2, 'B',  850.50, CURRENT_DATE - 2);
CALL pr_receive_delivery(3, 'C',  600.00, CURRENT_DATE - 1);
CALL pr_receive_delivery(1, 'B',  400.00, CURRENT_DATE - 1);
CALL pr_receive_delivery(2, 'A',  300.00, CURRENT_DATE - 1);
CALL pr_receive_delivery(3, 'A',  250.00, CURRENT_DATE);

-- Payment states: farmer 3 is fully paid; farmer 1 part paid
UPDATE deliveries SET is_paid = TRUE WHERE delivery_id IN (1, 3, 6);

SELECT * FROM deliveries ORDER BY delivery_id;
