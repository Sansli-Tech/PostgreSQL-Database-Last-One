-- =====================================================================
-- ICT371 Advanced Database - Question 5: Hostel Room Allocation
-- (f) Index
-- Run order: file 8 of 9 in this folder.
-- =====================================================================

SET search_path TO q5, public;

-- ---------------------------------------------------------------------
-- (f) Index for ACTIVE allocations filtered by room_id
--     A partial index on room_id containing only ACTIVE rows. Capacity
--     checks and fn_free_beds always ask "ACTIVE rows for this room", so
--     the index matches that predicate exactly and ignores the growing
--     ENDED history, keeping it small and fast.
-- ---------------------------------------------------------------------
CREATE INDEX idx_allocations_active_room ON allocations (room_id) WHERE status = 'ACTIVE';
ANALYZE allocations;

SET enable_seqscan = off;    -- tiny demo table; show the index plan
EXPLAIN
SELECT allocation_id, student_id, allocated_on
FROM allocations
WHERE room_id = 2
  AND status = 'ACTIVE';
RESET enable_seqscan;
