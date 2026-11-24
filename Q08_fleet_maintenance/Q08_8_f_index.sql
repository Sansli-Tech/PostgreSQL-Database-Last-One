-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (f) Index for one vehicle's trips within a trip_on date range
--     Justification: equality on vehicle_id then a range on trip_on.
--     With vehicle_id first, the B-tree goes to that vehicle's entries
--     and scans only the dates in range, already sorted by trip_on.
--     It also indexes the FK column vehicle_id.
-- ---------------------------------------------------------------------
CREATE INDEX idx_trips_vehicle_trip_on ON trips (vehicle_id, trip_on);
ANALYZE trips;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT trip_id, trip_on, start_odometer, end_odometer
FROM trips
WHERE vehicle_id = 2
  AND trip_on BETWEEN CURRENT_DATE - 7 AND CURRENT_DATE
ORDER BY trip_on;
RESET enable_seqscan;
