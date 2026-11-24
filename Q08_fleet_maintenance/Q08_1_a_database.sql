-- =====================================================================
-- ICT371 Advanced Database - Question 8: Transport Fleet Maintenance
-- (a) Database: tables, keys and constraints
-- Run order: file 1 of 9 in this folder.
-- =====================================================================

DROP SCHEMA IF EXISTS q8 CASCADE;
CREATE SCHEMA q8;
SET search_path TO q8, public;

-- ---------------------------------------------------------------------
-- (a) Database (tables and constraints)
-- ---------------------------------------------------------------------
CREATE TABLE vehicles (
    vehicle_id            SERIAL PRIMARY KEY,
    registration          VARCHAR(15)   NOT NULL UNIQUE,
    current_odometer      NUMERIC(10,1) NOT NULL CHECK (current_odometer >= 0),
    last_service_odometer NUMERIC(10,1) NOT NULL CHECK (last_service_odometer >= 0),
    CONSTRAINT chk_service_not_ahead CHECK (last_service_odometer <= current_odometer)
);

CREATE TABLE trips (
    trip_id        SERIAL PRIMARY KEY,
    vehicle_id     INTEGER       NOT NULL REFERENCES vehicles(vehicle_id),
    trip_on        DATE          NOT NULL,
    start_odometer NUMERIC(10,1) NOT NULL CHECK (start_odometer >= 0),
    end_odometer   NUMERIC(10,1) NOT NULL,
    CONSTRAINT chk_trip_distance CHECK (end_odometer > start_odometer)
);

CREATE TABLE service_alerts (
    vehicle_id       INTEGER       PRIMARY KEY REFERENCES vehicles(vehicle_id),
    km_since_service NUMERIC(10,1) NOT NULL,
    flagged_on       DATE          NOT NULL DEFAULT CURRENT_DATE
);
