-- ============================================================
-- 01 | RAW SCHEMA & TABLE SETUP
-- ============================================================
-- Project: Retail Demand Forecasting & Pricing Analytics
-- Purpose: Create the raw schema, define source-table structures, standardize source column types, and perform basic schema/table metadata checks.
-- Database: PostgreSQL
-- Schema flow: raw -> analytics
-- Execution order: See sql/README.md
-- ============================================================

create schema raw;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'raw';

create table raw.sales(
column0 text,
date date,
item_id bigint,
quantity numeric,
price_base numeric,
sum_total numeric,
store_id bigint
);

ALTER TABLE raw.sales
RENAME COLUMN column0 TO "Unnamed: 0";

ALTER TABLE raw.sales
ALTER COLUMN item_id TYPE TEXT;

select column_name, data_type
from information_schema.columns
where table_schema = 'raw' and table_name='sales'
order by ordinal_position;

select count(*) from raw.sales;

CREATE TABLE raw.online (
    "Unnamed: 0" BIGINT,
    date DATE,
    item_id TEXT,
    quantity NUMERIC,
    price_base NUMERIC,
    sum_total NUMERIC,
    store_id BIGINT
);

select count(*) from raw.online;

CREATE TABLE raw.price_history (
    "Unnamed: 0" BIGINT,
    date DATE,
    item_id TEXT,
    price NUMERIC,
    code BIGINT,
    store_id BIGINT
);

SELECT COUNT(*)
FROM raw.price_history;

CREATE TABLE raw.discounts_history (
    "Unnamed: 0" BIGINT,
    date DATE,
    item_id TEXT,
    sale_price_before_promo NUMERIC,
    sale_price_time_promo NUMERIC,
    promo_type_code NUMERIC,
    doc_id TEXT,
    number_disc_day NUMERIC,
    store_id BIGINT
);

SELECT COUNT(*)
FROM raw.discounts_history;

CREATE TABLE raw.markdowns (
    "Unnamed: 0" BIGINT,
    date DATE,
    item_id TEXT,
    normal_price NUMERIC,
    price NUMERIC,
    quantity NUMERIC,
    store_id BIGINT
);

SELECT COUNT(*)
FROM raw.markdowns;

CREATE TABLE raw.catalog (
    "Unnamed: 0" BIGINT,
    item_id TEXT,
    dept_name TEXT,
    class_name TEXT,
    subclass_name TEXT,
    item_type TEXT,
    weight_volume NUMERIC,
    weight_netto NUMERIC,
    fatness NUMERIC
);

SELECT COUNT(*)
FROM raw.catalog;

CREATE TABLE raw.stores (
    "Unnamed: 0" BIGINT,
    store_id BIGINT,
    division TEXT,
    format TEXT,
    city TEXT,
    area BIGINT
);

SELECT COUNT(*)
FROM raw.stores;

CREATE TABLE raw.actual_matrix (
    "Unnamed: 0" BIGINT,
    item_id TEXT,
    date DATE,
    store_id BIGINT
);

select count(*) from raw.actual_matrix;