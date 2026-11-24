-- =====================================================================
-- ICT371 Advanced Database - Question 9: Farmer Cooperative Maize Deliveries
-- (a) Database: tables, keys and constraints
-- Run order: file 1 of 9 in this folder.
-- =====================================================================

DROP SCHEMA IF EXISTS q9 CASCADE;
CREATE SCHEMA q9;
SET search_path TO q9, public;

-- ---------------------------------------------------------------------
-- (a) Database (tables and constraints)
-- ---------------------------------------------------------------------
CREATE TABLE farmers (
    farmer_id     SERIAL PRIMARY KEY,
    farmer_number VARCHAR(20)  NOT NULL UNIQUE,
    full_name     VARCHAR(100) NOT NULL
);

CREATE TABLE deliveries (
    delivery_id  SERIAL PRIMARY KEY,
    farmer_id    INTEGER       NOT NULL REFERENCES farmers(farmer_id),
    grade        CHAR(1)       NOT NULL CHECK (grade IN ('A', 'B', 'C')),
    weight_kg    NUMERIC(10,2) NOT NULL CHECK (weight_kg > 0),
    unit_rate    NUMERIC(6,2)  NOT NULL CHECK (unit_rate > 0),      -- set by trigger
    total_value  NUMERIC(12,2) NOT NULL CHECK (total_value >= 0),   -- set by trigger
    delivered_on DATE          NOT NULL DEFAULT CURRENT_DATE,
    is_paid      BOOLEAN       NOT NULL DEFAULT FALSE
);

CREATE TABLE daily_purchases (
    purchase_date DATE          PRIMARY KEY,
    total_weight  NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_weight >= 0),
    total_value   NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_value >= 0)
);
