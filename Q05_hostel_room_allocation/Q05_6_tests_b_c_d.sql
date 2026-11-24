-- =====================================================================
-- ICT371 Advanced Database - Question 5: Hostel Room Allocation
-- Tests for (b), (c) and (d) (needs the seed data)
-- Run order: file 6 of 9 in this folder.
-- =====================================================================

SET search_path TO q5, public;

-- ---------------------------------------------------------------------
-- Tests for (b), (c) and (d)
-- ---------------------------------------------------------------------
SELECT room_id, room_number, capacity, fn_free_beds(room_id) AS free_beds
FROM rooms ORDER BY room_id;        -- 0, 1, 2  (ENDED row does not reduce C301)

DO $$
BEGIN
    PERFORM fn_free_beds(999);
    RAISE NOTICE 'UNEXPECTED: unknown room accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_allocate_room(5, 1, CURRENT_DATE);       -- A101 is full
    RAISE NOTICE 'UNEXPECTED: full room accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    CALL pr_allocate_room(3, 3, CURRENT_DATE);       -- student 3 already ACTIVE
    RAISE NOTICE 'UNEXPECTED: second ACTIVE allocation accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Direct SQL that bypasses the procedure is still blocked by the trigger
DO $$
BEGIN
    INSERT INTO allocations (student_id, room_id, status) VALUES (5, 1, 'ACTIVE');
    RAISE NOTICE 'UNEXPECTED: direct insert into full room accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

DO $$
BEGIN
    UPDATE allocations SET room_id = 1 WHERE allocation_id = 3;   -- move into full A101
    RAISE NOTICE 'UNEXPECTED: move into full room accepted';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Rejected as expected: %', SQLERRM;
END $$;

-- Updating an allocation in a full room without moving it must not count itself
UPDATE allocations SET allocated_on = allocated_on + 1 WHERE allocation_id = 1;
