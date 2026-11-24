-- =====================================================================
-- ICT371 Advanced Database - Question 5: Hostel Room Allocation
-- (a) Seed data (needs the procedure and trigger, so it runs after b, c and d)
-- Run order: file 5 of 9 in this folder.
-- =====================================================================

SET search_path TO q5, public;

-- ---------------------------------------------------------------------
-- (a) Seed data: full room (A101), partly occupied (B201), empty (C301)
--     plus an ENDED history row.
-- ---------------------------------------------------------------------
INSERT INTO rooms (room_number, capacity) VALUES
    ('A101', 2),
    ('B201', 3),
    ('C301', 2);

INSERT INTO students (student_number, full_name) VALUES
    ('2024101', 'Abel Mwansa'),
    ('2024102', 'Brian Chanda'),
    ('2024103', 'Cynthia Musonda'),
    ('2024104', 'Doreen Kapata'),
    ('2024105', 'Emmanuel Simwanza');

CALL pr_allocate_room(1, 1, CURRENT_DATE - 60);     -- A101 1/2
CALL pr_allocate_room(2, 1, CURRENT_DATE - 60);     -- A101 2/2 (full)
CALL pr_allocate_room(3, 2, CURRENT_DATE - 30);     -- B201 1/3
CALL pr_allocate_room(4, 3, CURRENT_DATE - 90);     -- C301, later ended

-- Student 4 moves out of C301: allocation becomes history.
UPDATE allocations
SET status = 'ENDED', released_on = CURRENT_DATE - 10
WHERE allocation_id = 4;

CALL pr_allocate_room(4, 2, CURRENT_DATE - 10);     -- B201 2/3 (partly occupied)

SELECT * FROM allocations ORDER BY allocation_id;
