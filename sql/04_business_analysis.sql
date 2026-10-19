-- ============================================================
-- 04 | BUSINESS ANALYSIS
-- ============================================================
-- Project: Retail Demand Forecasting & Pricing Analytics
-- Purpose: Business-facing SQL analysis covering store performance, sales share, ranking, top products by store, monthly sales, and month-over-month change.
-- Database: PostgreSQL
-- Schema flow: raw -> analytics
-- Execution order: See sql/README.md
-- ============================================================

-- How much sales value does each store generate, 
-- and how many transactions does each store have?

select
     store_id,
	 store_format,
	 city,
	 count(*) as transaction_rows,
	 sum(sum_total) as total_sales,
	 avg(sum_total) as avg_sales_per_row
from analytics.sales_enriched
group by 
     store_id,
    store_format,
    city
order by total_sales desc;

-- What percentage of total recorded sales comes from each store?

SELECT
    store_id,
    store_format,
    city,
    SUM(sum_total) AS total_sales,

    ROUND(
        100.0 * SUM(sum_total)
        / SUM(SUM(sum_total)) OVER (),
        2
    ) AS sales_share_pct

FROM analytics.sales_enriched
GROUP BY
    store_id,
    store_format,
    city
ORDER BY total_sales DESC;

-- What is the sales rank of each store?

SELECT
    store_id,
    store_format,
    city,
    sum(sum_total) as total_sales,

	rank() over (
        order by sum(sum_total) desc
    ) as sales_rank
	
from analytics.sales_enriched
group by
    store_id,
    store_format,
    city
order by sales_rank;

--  Within each store, which products generate the most recorded sales?
WITH product_sales AS (
    SELECT
        store_id,
        item_id,
        SUM(sum_total) AS product_sales
    FROM analytics.sales_enriched
    GROUP BY
        store_id,
        item_id
)

SELECT
    store_id,
    item_id,
    product_sales,

    RANK() OVER (
        PARTITION BY store_id
        ORDER BY product_sales DESC
    ) AS product_rank

FROM product_sales
ORDER BY
    store_id,
    product_rank
LIMIT 50;

WITH product_sales AS (
    SELECT
        store_id,
        item_id,
        SUM(sum_total) AS product_sales
    FROM analytics.sales_enriched
    GROUP BY
        store_id,
        item_id
),

ranked_products AS (
    SELECT
        store_id,
        item_id,
        product_sales,
        RANK() OVER (
            PARTITION BY store_id
            ORDER BY product_sales DESC
        ) AS product_rank
    FROM product_sales
)

SELECT
    store_id,
    item_id,
    product_sales,
    product_rank
FROM ranked_products
WHERE product_rank <= 5
ORDER BY
    store_id,
    product_rank;

-- How does recorded sales value change over time?
SELECT
    DATE_TRUNC('month', date)::date AS month,
    SUM(sum_total) AS total_sales,
    COUNT(*) AS sales_rows
FROM analytics.sales_enriched
GROUP BY
    DATE_TRUNC('month', date)
ORDER BY month;

--How much did recorded sales change compared with the previous month?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', date)::date AS month,
        SUM(sum_total) AS total_sales
    FROM analytics.sales_enriched
    GROUP BY DATE_TRUNC('month', date)
)

SELECT
    month,
    total_sales,

    LAG(total_sales) OVER (
        ORDER BY month
    ) AS previous_month_sales,

    ROUND(
        100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY month))
        / NULLIF(LAG(total_sales) OVER (ORDER BY month), 0),
        2
    ) AS mom_growth_pct

FROM monthly_sales
ORDER BY month;