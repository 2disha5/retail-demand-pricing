-- ============================================================
-- 03 | ANALYTICS LAYER
-- ============================================================
-- Project: Retail Demand Forecasting & Pricing Analytics
-- Purpose: Build reusable analytical tables by enriching sales with product and store attributes while retaining unmatched records through LEFT JOINs.
-- Database: PostgreSQL
-- Schema flow: raw -> analytics
-- Execution order: See sql/README.md
-- ============================================================

create schema if not exists analytics;

create table analytics.sales as
          select date,
		  item_id,
		  store_id,
		  quantity,
		  price_base,
		  sum_total,

		  case
		      when quantity>0 then 'Positive'
			  when quantity=0 then 'Zero'
			  when quantity<0 then 'Negative'
		  end as quantity_type,

		  case
		      when sum_total>0 then 'Positive'
			  when sum_total=0 then 'Zero'
			  when sum_total<0 then 'Negative'
		  end as revenue_type
		  
from raw.sales;

select * from analytics.sales;

SELECT
    quantity_type,
    COUNT(*) AS rows
FROM analytics.sales
GROUP BY quantity_type
ORDER BY quantity_type;

SELECT
    revenue_type,
    COUNT(*) AS rows
FROM analytics.sales
GROUP BY revenue_type
ORDER BY revenue_type;

CREATE TABLE analytics.sales_product AS
SELECT
    s.date,
    s.item_id,
    s.store_id,
    s.quantity,
    s.price_base,
    s.sum_total,
    s.quantity_type,
    s.revenue_type,

    c.dept_name,
    c.class_name,
    c.subclass_name,
    c.item_type,
    c.weight_volume,
    c.weight_netto,
    c.fatness

FROM analytics.sales s
LEFT JOIN raw.catalog c
    ON s.item_id = c.item_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE dept_name IS NOT NULL
    ) AS matched_catalog_rows,
    COUNT(*) FILTER (
        WHERE dept_name IS NULL
    ) AS unmatched_catalog_rows
FROM analytics.sales_product;

CREATE TABLE analytics.sales_enriched AS
SELECT
    sp.*,

    st.division,
    st.format AS store_format,
    st.city,
    st.area AS store_area

FROM analytics.sales_product sp
LEFT JOIN raw.stores st
    ON sp.store_id = st.store_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE division IS NOT NULL
    ) AS matched_store_rows,
    COUNT(*) FILTER (
        WHERE division IS NULL
    ) AS unmatched_store_rows
FROM analytics.sales_enriched;