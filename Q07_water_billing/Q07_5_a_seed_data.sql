-- =====================================================================
-- ICT371 Advanced Database - Question 7: Water Meter Readings and Billing
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q7, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three customers, six readings (0, exactly 10, >10 units)
-- ---------------------------------------------------------------------
INSERT INTO customers (full_name) VALUES
    ('Mercy Chibwe'), ('Isaac Mulenga'), ('Hope Nyirenda');

INSERT INTO readings (customer_id, reading_month, previous_reading, current_reading) VALUES
    (1, date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date, 1200.00, 1200.00), -- 0 units
    (1, date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date,  1200.00, 1210.00), -- 10 units
    (2, date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date,  540.00,  558.00), -- 18 units
    (2, date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date,   558.00,  565.50), -- 7.5 units
    (3, date_trunc('month', CURRENT_DATE - INTERVAL '2 months')::date,   80.00,  105.00), -- 25 units
    (3, date_trunc('month', CURRENT_DATE - INTERVAL '1 month')::date,   105.00,  115.00); -- 10 units

CALL pr_generate_bill(1, CURRENT_DATE - 30);
CALL pr_generate_bill(2, CURRENT_DATE + 10);
CALL pr_generate_bill(3, CURRENT_DATE - 30);
CALL pr_generate_bill(4, CURRENT_DATE + 10);
CALL pr_generate_bill(5, CURRENT_DATE - 30);
CALL pr_generate_bill(6, CURRENT_DATE + 10);

-- Some payments
UPDATE bills SET amount_paid = 50.00  WHERE bill_id = 2;   -- fully paid
UPDATE bills SET amount_paid = 40.00  WHERE bill_id = 3;   -- part paid, overdue
UPDATE bills SET amount_paid = 170.00 WHERE bill_id = 5;   -- fully paid

SELECT r.reading_id, r.customer_id, r.current_reading - r.previous_reading AS units,
       b.bill_id, b.charge, b.amount_paid, b.due_on
FROM readings r JOIN bills b ON b.reading_id = r.reading_id
ORDER BY r.reading_id;
