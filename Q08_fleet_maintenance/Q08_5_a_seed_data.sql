-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: three vehicles at different service positions; six trips
--     added through the procedure after the trigger is installed.
-- ---------------------------------------------------------------------
INSERT INTO vehicles (registration, current_odometer, last_service_odometer) VALUES
    ('ABT 1234', 12000.0, 10000.0),   -- 2,000 km since service (well within)
    ('BAG 5678', 24800.0, 20000.0),   -- 4,800 km (close; trips push it over)
    ('ALD 9012', 51000.0, 45500.0);   -- 5,500 km (already due)

CALL pr_record_trip(1, CURRENT_DATE - 6, 12000.0, 12350.0);
CALL pr_record_trip(2, CURRENT_DATE - 6, 24800.0, 25100.0);
CALL pr_record_trip(3, CURRENT_DATE - 5, 51000.0, 51200.0);
CALL pr_record_trip(1, CURRENT_DATE - 3, 12350.0, 12900.0);
CALL pr_record_trip(2, CURRENT_DATE - 2, 25100.0, 25350.0);   -- now 5,350 km: due
CALL pr_record_trip(3, CURRENT_DATE - 1, 51200.0, 51480.0);

SELECT * FROM trips    ORDER BY trip_id;
SELECT * FROM vehicles ORDER BY vehicle_id;   -- odometers moved once per trip
