-- =====================================================================
-- ICT371 Advanced Database - Question 1: Pharmacy Stock and Daily Sales
-- (a) Database: tables, keys and constraints
-- Run order: file 1 of 9 in this folder.
-- =====================================================================

DROP SCHEMA IF EXISTS q1 CASCADE;
CREATE SCHEMA q1;
SET search_path TO q1, public;

-- ---------------------------------------------------------------------
-- (a) Database (tables, keys, types, constraints)
-- ---------------------------------------------------------------------
CREATE TABLE medicines (
    medicine_id   SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100)  NOT NULL UNIQUE,
    unit_price    NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    stock_qty     INTEGER       NOT NULL CHECK (stock_qty >= 0)
);

CREATE TABLE sales (
    sale_id     SERIAL PRIMARY KEY,
    medicine_id INTEGER       NOT NULL REFERENCES medicines(medicine_id),
    quantity    INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),  -- price at time of sale
    sold_on     DATE          NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE stock_audit (
    audit_id    SERIAL PRIMARY KEY,
    medicine_id INTEGER     NOT NULL REFERENCES medicines(medicine_id),
    old_qty     INTEGER     NOT NULL,
    new_qty     INTEGER     NOT NULL,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE daily_sales (
    sales_date   DATE          PRIMARY KEY,
    total_qty    INTEGER       NOT NULL DEFAULT 0 CHECK (total_qty >= 0),
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0)
);
