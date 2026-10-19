-- ============================================================
-- 02 | DATA QUALITY & VALIDATION
-- ============================================================
-- Project: Retail Demand Forecasting & Pricing Analytics
-- Purpose: Validate keys, duplicates, nulls, referential coverage, unusual quantities/prices/revenue, arithmetic consistency, and auxiliary dataset alignment before analytical use.
-- Database: PostgreSQL
-- Schema flow: raw -> analytics
-- Execution order: See sql/README.md
-- ============================================================

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;

SELECT
    'sales' AS table_name,
    COUNT(*) AS row_count
FROM raw.sales

UNION ALL

SELECT
    'online',
    COUNT(*)
FROM raw.online

UNION ALL

SELECT
    'price_history',
    COUNT(*)
FROM raw.price_history

UNION ALL

SELECT
    'discounts_history',
    COUNT(*)
FROM raw.discounts_history

UNION ALL

SELECT
    'markdowns',
    COUNT(*)
FROM raw.markdowns

UNION ALL

SELECT
    'catalog',
    COUNT(*)
FROM raw.catalog

UNION ALL

SELECT
    'stores',
    COUNT(*)
FROM raw.stores

UNION ALL

SELECT
    'actual_matrix',
    COUNT(*)
FROM raw.actual_matrix

ORDER BY row_count DESC;

SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
ORDER BY table_name, ordinal_position;

SELECT
    MIN("Unnamed: 0"::BIGINT) AS min_index,
    MAX("Unnamed: 0"::BIGINT) AS max_index,
    COUNT(*) AS row_count,
    COUNT(DISTINCT "Unnamed: 0") AS distinct_index_count
FROM raw.sales;

SELECT
    MIN("Unnamed: 0"::BIGINT) AS min_index,
    MAX("Unnamed: 0"::BIGINT) AS max_index,
    COUNT(*) AS actual_rows,
    MAX("Unnamed: 0"::BIGINT) - MIN("Unnamed: 0"::BIGINT) + 1 AS possible_positions,
    (MAX("Unnamed: 0"::BIGINT) - MIN("Unnamed: 0"::BIGINT) + 1)
        - COUNT(*) AS missing_positions
FROM raw.sales;

SELECT
    'sales' AS table_name,
    MIN("Unnamed: 0"::BIGINT) AS min_index,
    MAX("Unnamed: 0"::BIGINT) AS max_index,
    COUNT(*) AS row_count,
    COUNT(DISTINCT "Unnamed: 0") AS distinct_index_count
FROM raw.sales

UNION ALL

SELECT
    'online',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.online

UNION ALL

SELECT
    'price_history',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.price_history

UNION ALL

SELECT
    'discounts_history',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.discounts_history

UNION ALL

SELECT
    'markdowns',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.markdowns

UNION ALL

SELECT
    'catalog',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.catalog

UNION ALL

SELECT
    'stores',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.stores

UNION ALL

SELECT
    'actual_matrix',
    MIN("Unnamed: 0"),
    MAX("Unnamed: 0"),
    COUNT(*),
    COUNT(DISTINCT "Unnamed: 0")
FROM raw.actual_matrix

ORDER BY table_name;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS distinct_date_item_store_keys,
    COUNT(*) - COUNT(DISTINCT (date, item_id, store_id)) AS duplicate_excess_rows
FROM raw.sales;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS distinct_date_item_store_keys,
    COUNT(*) - COUNT(DISTINCT (date, item_id, store_id)) AS duplicate_excess_rows
FROM raw.online;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS distinct_date_item_store_keys,
    COUNT(*) - COUNT(DISTINCT (date, item_id, store_id)) AS duplicate_excess_rows
FROM raw.price_history;

SELECT
    COUNT(*) AS duplicate_groups,
    SUM(record_count - 1) AS duplicate_excess_rows,
    COUNT(*) FILTER (WHERE distinct_prices = 1) AS same_price_groups,
    COUNT(*) FILTER (WHERE distinct_prices > 1) AS multiple_price_groups
FROM (
    SELECT
        date,
        item_id,
        store_id,
        COUNT(*) AS record_count,
        COUNT(DISTINCT price) AS distinct_prices
    FROM raw.price_history
    GROUP BY date, item_id, store_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT
    date,
    item_id,
    store_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT price) AS distinct_prices,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ARRAY_AGG(DISTINCT price ORDER BY price) AS prices
FROM raw.price_history
GROUP BY date, item_id, store_id
HAVING COUNT(DISTINCT price) > 1
ORDER BY date, item_id, store_id
LIMIT 20;

SELECT
    code,
    COUNT(*) AS row_count,
    COUNT(DISTINCT item_id) AS distinct_items,
    COUNT(DISTINCT store_id) AS distinct_stores,
    MIN(date) AS first_date,
    MAX(date) AS last_date
FROM raw.price_history
GROUP BY code
ORDER BY code;

SELECT
    COUNT(*) AS duplicate_groups,
    COUNT(*) FILTER (WHERE distinct_codes = 1) AS one_code_groups,
    COUNT(*) FILTER (WHERE distinct_codes > 1) AS multiple_code_groups
FROM (
    SELECT
        date,
        item_id,
        store_id,
        COUNT(*) AS record_count,
        COUNT(DISTINCT price) AS distinct_prices,
        COUNT(DISTINCT code) AS distinct_codes
    FROM raw.price_history
    GROUP BY date, item_id, store_id
    HAVING COUNT(*) > 1
) AS grouped;

select date, item_id, store_id, 
count(*) as record_count,
array_agg(code order by code) as codes,
array_agg(price order by code) as prices 
from raw.price_history
group by date, item_id, store_id
having count(distinct code)> 1
order by date, item_id, store_id
limit 20;

SELECT
    code_combination,
    COUNT(*) AS group_count
FROM (
    SELECT
        date,
        item_id,
        store_id,
        ARRAY_AGG(DISTINCT code ORDER BY code) AS code_combination
    FROM raw.price_history
    GROUP BY date, item_id, store_id
    HAVING COUNT(DISTINCT code) > 1
) AS grouped_codes
GROUP BY code_combination
ORDER BY group_count DESC
LIMIT 20;

SELECT
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE date > (SELECT MAX(date) FROM raw.sales)
    ) AS rows_after_sales_period
FROM raw.discounts_history;

SELECT
    date,
    COUNT(*) AS row_count,
    COUNT(DISTINCT item_id) AS distinct_items,
    COUNT(DISTINCT store_id) AS distinct_stores
FROM raw.discounts_history
WHERE date > (SELECT MAX(date) FROM raw.sales)
GROUP BY date
ORDER BY date
LIMIT 20;

SELECT
    date,
    number_disc_day,
    COUNT(*) AS row_count
FROM raw.discounts_history
WHERE date > (SELECT MAX(date) FROM raw.sales)
GROUP BY date, number_disc_day
ORDER BY date, number_disc_day
LIMIT 30;

SELECT
    doc_id,
    item_id,
    store_id,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    COUNT(*) AS record_count,
    MIN(number_disc_day) AS min_disc_day,
    MAX(number_disc_day) AS max_disc_day,
    MIN(sale_price_before_promo) AS min_price_before,
    MAX(sale_price_before_promo) AS max_price_before,
    MIN(sale_price_time_promo) AS min_price_promo,
    MAX(sale_price_time_promo) AS max_price_promo
FROM raw.discounts_history
WHERE date > (SELECT MAX(date) FROM raw.sales)
GROUP BY doc_id, item_id, store_id
ORDER BY record_count DESC
LIMIT 20;

SELECT
    COUNT(*) AS future_promotion_groups,
    COUNT(*) FILTER (
        WHERE last_date = DATE '2045-12-31'
    ) AS ending_2045_groups,
    COUNT(*) FILTER (
        WHERE record_count > 100
    ) AS groups_over_100_days
FROM (
    SELECT
        doc_id,
        item_id,
        store_id,
        MIN(date) AS first_date,
        MAX(date) AS last_date,
        COUNT(*) AS record_count
    FROM raw.discounts_history
    WHERE date > (SELECT MAX(date) FROM raw.sales)
    GROUP BY doc_id, item_id, store_id
) AS future_promotions;

SELECT
    COUNT(*) AS future_groups,
    COUNT(*) FILTER (
        WHERE record_count =
              (last_date - first_date + 1)
    ) AS continuous_daily_groups,
    COUNT(*) FILTER (
        WHERE record_count <
              (last_date - first_date + 1)
    ) AS groups_with_missing_dates,
    COUNT(*) FILTER (
        WHERE record_count >
              (last_date - first_date + 1)
    ) AS groups_with_more_records_than_days
FROM (
    SELECT
        doc_id,
        item_id,
        store_id,
        MIN(date) AS first_date,
        MAX(date) AS last_date,
        COUNT(*) AS record_count
    FROM raw.discounts_history
    WHERE date > (SELECT MAX(date) FROM raw.sales)
    GROUP BY doc_id, item_id, store_id
) AS future_groups;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS distinct_date_item_store_keys,
    COUNT(*) - COUNT(DISTINCT (date, item_id, store_id)) AS duplicate_excess_rows
FROM raw.markdowns;

SELECT
    COUNT(*) AS duplicate_groups,
    SUM(record_count - 1) AS duplicate_excess_rows,
    COUNT(*) FILTER (WHERE distinct_prices = 1) AS same_price_groups,
    COUNT(*) FILTER (WHERE distinct_prices > 1) AS multiple_price_groups
FROM (
    SELECT
        date,
        item_id,
        store_id,
        COUNT(*) AS record_count,
        COUNT(DISTINCT price) AS distinct_prices
    FROM raw.markdowns
    GROUP BY date, item_id, store_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT
    COUNT(*) AS duplicate_groups,
    COUNT(*) FILTER (WHERE distinct_quantities = 1) AS same_quantity_groups,
    COUNT(*) FILTER (WHERE distinct_quantities > 1) AS different_quantity_groups
FROM (
    SELECT
        date,
        item_id,
        store_id,
        COUNT(DISTINCT quantity) AS distinct_quantities
    FROM raw.markdowns
    GROUP BY date, item_id, store_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT item_id) AS distinct_items,
    COUNT(*) - COUNT(DISTINCT item_id) AS duplicate_excess_rows
FROM raw.catalog;

SELECT
    COUNT(DISTINCT s.item_id) AS sales_items,
    COUNT(DISTINCT c.item_id) AS matched_catalog_items,
    COUNT(DISTINCT s.item_id) 
        - COUNT(DISTINCT c.item_id) AS unmatched_items
FROM raw.sales s
LEFT JOIN raw.catalog c
    ON s.item_id = c.item_id;

select 
     count(*) as unmatched_sales_rows,
     sum(s. quantity) as unmatched_quantity,
	 sum(s.sum_total) as unmatched_revenue
from raw.sales s
left join raw.catalog c
      on s.item_id = c.item_id
where c.item_id is null;

SELECT
    COUNT(DISTINCT s.store_id) AS sales_stores,
    COUNT(DISTINCT st.store_id) AS matched_stores,
    COUNT(DISTINCT s.store_id)
        - COUNT(DISTINCT st.store_id) AS unmatched_stores
FROM raw.sales s
LEFT JOIN raw.stores st
    ON s.store_id = st.store_id;

SELECT
    store_id,
    division,
    format,
    city,
    area
FROM raw.stores
ORDER BY store_id;

SELECT
    COUNT(*) AS online_rows,
    COUNT(s.item_id) AS matching_sales_rows,
    COUNT(*) - COUNT(s.item_id) AS online_rows_without_sales_match
FROM raw.online o
LEFT JOIN raw.sales s
    ON o.date = s.date
   AND o.item_id = s.item_id
   AND o.store_id = s.store_id;

SELECT
    COUNT(*) AS matching_rows,

    COUNT(*) FILTER (
        WHERE o.quantity = s.quantity
    ) AS same_quantity,

    COUNT(*) FILTER (
        WHERE o.price_base = s.price_base
    ) AS same_price,

    COUNT(*) FILTER (
        WHERE o.sum_total = s.sum_total
    ) AS same_revenue

FROM raw.online o
INNER JOIN raw.sales s
    ON o.date = s.date
   AND o.item_id = s.item_id
   AND o.store_id = s.store_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS distinct_date_item_store_keys,
    COUNT(*) - COUNT(DISTINCT (date, item_id, store_id)) AS duplicate_excess_rows
FROM raw.actual_matrix;

SELECT
    COUNT(*) AS actual_matrix_rows,
    COUNT(s.item_id) AS matching_sales_rows,
    COUNT(*) - COUNT(s.item_id) AS rows_without_sales_match
FROM raw.actual_matrix am
LEFT JOIN raw.sales s
    ON am.date = s.date
   AND am.item_id = s.item_id
   AND am.store_id = s.store_id;

SELECT
    COUNT(*) AS total_sales_rows,
    COUNT(*) FILTER (
        WHERE c.item_id IS NULL
    ) AS unmatched_catalog_rows,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE c.item_id IS NULL
        ) / COUNT(*),
        2
    ) AS unmatched_percentage
FROM raw.sales s
LEFT JOIN raw.catalog c
    ON s.item_id = c.item_id;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE date IS NULL) AS null_dates,
    COUNT(*) FILTER (WHERE item_id IS NULL) AS null_items,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity,
    COUNT(*) FILTER (WHERE price_base IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE sum_total IS NULL) AS null_revenue,
    COUNT(*) FILTER (WHERE store_id IS NULL) AS null_store
FROM raw.sales;

select 
    count(*) as total_rows,
	count(*) filter (where quantity = 0) as zero,
	count(*) filter (where quantity< 0) as negative,
	count(*) filter (where quantity > 0) as positive
from raw.sales;

SELECT
    COUNT(*) AS negative_quantity_rows,
    COUNT(*) FILTER (WHERE sum_total < 0) AS negative_revenue_rows,
    COUNT(*) FILTER (WHERE sum_total = 0) AS zero_revenue_rows,
    COUNT(*) FILTER (WHERE sum_total > 0) AS positive_revenue_rows,
    SUM(quantity) AS total_negative_quantity,
    SUM(sum_total) AS total_negative_revenue
FROM raw.sales
WHERE quantity < 0;

SELECT
    date,
    item_id,
    store_id,
    quantity,
    price_base,
    sum_total
FROM raw.sales
WHERE quantity < 0
  AND sum_total >= 0
ORDER BY date, item_id, store_id
LIMIT 50;

SELECT
    COUNT(*) AS anomalous_rows,
    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) < 0.01
    ) AS approximately_matching,
    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) >= 0.01
    ) AS not_matching
FROM raw.sales
WHERE quantity < 0
  AND sum_total >= 0;

SELECT
    COUNT(*) AS zero_quantity_rows,
    COUNT(*) FILTER (WHERE sum_total = 0) AS zero_quantity_zero_revenue,
    COUNT(*) FILTER (WHERE sum_total < 0) AS zero_quantity_negative_revenue,
    COUNT(*) FILTER (WHERE sum_total > 0) AS zero_quantity_positive_revenue,
    COUNT(*) FILTER (WHERE price_base = 0) AS zero_quantity_zero_price,
    COUNT(*) FILTER (WHERE price_base < 0) AS zero_quantity_negative_price,
    COUNT(*) FILTER (WHERE price_base > 0) AS zero_quantity_positive_price
FROM raw.sales
WHERE quantity = 0;

SELECT
    date,
    item_id,
    store_id,
    quantity,
    price_base,
    sum_total
FROM raw.sales
WHERE quantity = 0
  AND sum_total <> 0
ORDER BY date, item_id, store_id
LIMIT 30;

SELECT
    COUNT(*) AS zero_quantity_rows,
    SUM(sum_total) AS zero_quantity_total_value,
    SUM(ABS(sum_total)) AS zero_quantity_absolute_value,
    MIN(sum_total) AS smallest_value,
    MAX(sum_total) AS largest_value
FROM raw.sales
WHERE quantity = 0;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE price_base = 0) AS zero_price_rows,
    COUNT(*) FILTER (WHERE price_base < 0) AS negative_price_rows,
    COUNT(*) FILTER (WHERE price_base > 0) AS positive_price_rows
FROM raw.sales;

SELECT
    COUNT(*) FILTER (
        WHERE price_base = 0 AND quantity > 0
    ) AS zero_price_positive_quantity,

    COUNT(*) FILTER (
        WHERE price_base = 0 AND quantity < 0
    ) AS zero_price_negative_quantity,

    COUNT(*) FILTER (
        WHERE price_base = 0 AND quantity = 0
    ) AS zero_price_zero_quantity,

    COUNT(*) FILTER (
        WHERE price_base < 0 AND quantity > 0
    ) AS negative_price_positive_quantity,

    COUNT(*) FILTER (
        WHERE price_base < 0 AND quantity < 0
    ) AS negative_price_negative_quantity,

    COUNT(*) FILTER (
        WHERE price_base < 0 AND quantity = 0
    ) AS negative_price_zero_quantity
FROM raw.sales;

SELECT
    COUNT(*) AS rows,
    COUNT(*) FILTER (WHERE sum_total = 0) AS zero_revenue,
    COUNT(*) FILTER (WHERE sum_total < 0) AS negative_revenue,
    COUNT(*) FILTER (WHERE sum_total > 0) AS positive_revenue,
    SUM(quantity) AS total_quantity,
    SUM(sum_total) AS total_value
FROM raw.sales
WHERE price_base = 0
  AND quantity > 0;

SELECT
    COUNT(*) AS rows,
    COUNT(*) FILTER (WHERE sum_total = 0) AS zero_revenue,
    COUNT(*) FILTER (WHERE sum_total < 0) AS negative_revenue,
    COUNT(*) FILTER (WHERE sum_total > 0) AS positive_revenue,
    SUM(quantity) AS total_quantity,
    SUM(sum_total) AS total_value
FROM raw.sales
WHERE price_base < 0




SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) < 0.01
    ) AS approximately_matching,

    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) >= 0.01
    ) AS not_matching
FROM raw.sales;

SELECT
    COUNT(*) AS mismatched_rows,

    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) < 1
    ) AS difference_under_1,

    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) >= 1
        AND ABS(sum_total - (quantity * price_base)) < 10
    ) AS difference_1_to_10,

    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) >= 10
    ) AS difference_10_or_more
FROM raw.sales
WHERE ABS(sum_total - (quantity * price_base)) >= 0.01;

SELECT
    date,
    item_id,
    store_id,
    quantity,
    price_base,
    sum_total,
    quantity * price_base AS calculated_value,
    sum_total - (quantity * price_base) AS difference
FROM raw.sales
WHERE ABS(sum_total - (quantity * price_base)) >= 10
ORDER BY ABS(sum_total - (quantity * price_base)) DESC
LIMIT 30;

SELECT
    COUNT(*) AS large_mismatch_rows,

    COUNT(*) FILTER (
        WHERE quantity = 0
    ) AS zero_quantity_rows,

    COUNT(*) FILTER (
        WHERE quantity <> 0
    ) AS nonzero_quantity_rows

FROM raw.sales
WHERE ABS(sum_total - (quantity * price_base)) >= 10;

SELECT
    date,
    item_id,
    store_id,
    quantity,
    price_base,
    sum_total,
    quantity * price_base AS calculated_value,
    sum_total - (quantity * price_base) AS difference
FROM raw.sales
WHERE ABS(sum_total - (quantity * price_base)) >= 10
  AND quantity <> 0
ORDER BY ABS(sum_total - (quantity * price_base)) DESC;

SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY quantity) AS median_quantity,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY quantity) AS p90_quantity,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY quantity) AS p95_quantity,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY quantity) AS p99_quantity,
    PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY quantity) AS p999_quantity
FROM raw.sales;

SELECT
    date,
    item_id,
    store_id,
    quantity,
    price_base,
    sum_total
FROM raw.sales
WHERE quantity > 0
ORDER BY quantity DESC
LIMIT 20;

SELECT
    c.item_id,
    c.dept_name,
    c.class_name,
    c.subclass_name,
    c.item_type,
    c.weight_volume,
    c.weight_netto,
    c.fatness
FROM raw.catalog c
WHERE c.item_id IN (
    '327c5bc1e583',
    'b0d24502fb66',
    '6d284b4e9982'
);

SELECT
    COUNT(*) AS sales_rows,
    COUNT(DISTINCT store_id) AS stores,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(price_base) AS min_price,
    MAX(price_base) AS max_price,
    SUM(sum_total) AS total_value
FROM raw.sales
WHERE item_id = '327c5bc1e583';

SELECT
    date,
    item_id,
    store_id,
    quantity,
    price_base,
    sum_total
FROM raw.sales
WHERE sum_total > 0
ORDER BY sum_total DESC
LIMIT 20;

SELECT
    MIN(sum_total) AS min_value,
    MAX(sum_total) AS max_value,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY sum_total) AS median_value,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY sum_total) AS p90_value,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY sum_total) AS p95_value,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY sum_total) AS p99_value,
    PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY sum_total) AS p999_value
FROM raw.sales;

SELECT
    COUNT(*) AS negative_revenue_rows,
    SUM(sum_total) AS total_negative_revenue,
    SUM(ABS(sum_total)) AS absolute_negative_revenue,
    MIN(sum_total) AS most_negative_value,
    MAX(sum_total) AS least_negative_value
FROM raw.sales
WHERE sum_total < 0;