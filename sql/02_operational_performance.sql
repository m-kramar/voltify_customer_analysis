/*
══════════════════════════════════════
 QUERY 1: Days to First Purchase
══════════════════════════════════════
*/

/*
Purpose: Calculate average days from sign-up to first purchase for customers 
         who become returning buyers (Can be adjusted to query one-time users as well)

Methodology:
1. Create stable order IDs with null timestamp handling
2. Identify one-time customers (single order only)
3. Filter to returning(or one-time) customers only
4. Calculate time difference between sign-up and first purchase
5. Exclude negative day differences (data quality control)
*/

WITH order_data AS (
  SELECT
    -- Create unique order ID handling null timestamps
    COALESCE(
      CONCAT(customer_id, '_', CAST(purchase_ts AS STRING)),
      CAST(customer_id AS STRING)
    ) AS order_id,
    customer_id,
    product_name,
    usd_price
  FROM core.orders 
),

one_time_customers AS (
  SELECT 
    customer_id
  FROM order_data
  GROUP BY 1
  HAVING COUNT(DISTINCT order_id) = 1  -- Single order customers
),

-- Rank orders to determine the first purchase date
ranked_orders AS (
  SELECT 
    customer_id,
    purchase_ts,
    -- Number orders chronologically per customer
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY purchase_ts ASC
    ) AS order_rank
  FROM core.orders
-- Change for "customer_id IN" to query for one-time users
  WHERE customer_id NOT IN (SELECT customer_id FROM one_time_customers)
)

-- Calculate average days from sign-up to first purchase
SELECT
  AVG(
    DATE_DIFF(ranked_orders.purchase_ts, customers.created_on, DAY)
  ) AS days_to_purchase
FROM core.customers 
LEFT JOIN ranked_orders 
  ON customers.id = ranked_orders.customer_id
WHERE 
  ranked_orders.order_rank = 1  -- Focus on first purchase only
  -- Exclude cases where purchase happens before sign-up (data quality)
  AND DATE_DIFF(ranked_orders.purchase_ts, customers.created_on, DAY) >= 0;


/* 
═══════════════════════════════════════════════════════════════════════
 QUERY 2: Days Between First and Second Purchase - Returning Customers
═══════════════════════════════════════════════════════════════════════
*/

/*
Purpose: Calculate average days between first and second purchase 
         for customers who become returning buyers

Methodology:
1. Create stable order IDs with null timestamp handling
2. Identify one-time customers (single order only) for exclusion
3. Rank orders chronologically for returning customers using DENSE_RANK
   (ensures same timestamp records get same rank)
4. Calculate day difference between first and second purchase per customer
5. Compute overall average of days between purchases
*/

WITH order_data AS (
  SELECT
    -- Create unique order ID handling null timestamps
    COALESCE(
      CONCAT(customer_id, '_', CAST(purchase_ts AS STRING)),
      CAST(customer_id AS STRING)
    ) AS order_id,
    customer_id,
    product_name,
    usd_price
  FROM core.orders 
),

one_time_customers AS (
  SELECT 
    customer_id
  FROM order_data
  GROUP BY 1
  HAVING COUNT(DISTINCT order_id) = 1  -- Single order customers
),

-- Rank orders chronologically for RETURNING customers only
ranked_orders AS (
  SELECT 
    customer_id,
    purchase_ts,
    -- Use DENSE_RANK to handle same-timestamp purchases (those are different items withing same order)
    DENSE_RANK() OVER (
      PARTITION BY customer_id 
      ORDER BY purchase_ts ASC
    ) AS order_rank
  FROM core.orders
  WHERE customer_id NOT IN (SELECT customer_id FROM one_time_customers)
),

-- Calculate days between first and second purchase for each customer
first_two_purch AS (
  SELECT
    customer_id,
    -- Calculate day difference between 2nd and 1st purchase
    DATE_DIFF(
      MAX(CASE WHEN order_rank = 2 THEN purchase_ts END), 
      MAX(CASE WHEN order_rank = 1 THEN purchase_ts END), 
      DAY
    ) AS days_between_purch
  FROM ranked_orders
  GROUP BY 1
)

-- Final calculation: average days between first and second purchase
SELECT 
  AVG(days_between_purch) AS avg_days_between_purchases
FROM first_two_purch;


/* 
══════════════════════════════════════════════════════════════════════════════
 QUERY 3: Cohort Analysis - Quarterly Customer Retention Rates
══════════════════════════════════════════════════════════════════════════════
*/

/*
Purpose: Analyze customer retention patterns by quarterly cohorts to understand 
         how well we maintain customer relationships over time

Methodology:
1. Create stable order IDs with null timestamp handling
2. Identify one-time customers (single order only) for exclusion
3. Group orders by customer and purchase timestamp to handle potential duplicates
4. Establish customer cohorts based on first purchase quarter
5. Calculate time intervals (days and quarters) since first purchase
6. Compute active users and retention rates by cohort and time period
7. Filter to relevant timeframe (0-8 quarters) for practical analysis
*/

WITH order_data AS (
  SELECT
    -- Create unique order ID handling null timestamps
    COALESCE(
      CONCAT(customer_id, '_', CAST(purchase_ts AS STRING)),
      CAST(customer_id AS STRING)
    ) AS order_id,
    customer_id,
    product_name,
    usd_price
  FROM core.orders 
),

one_time_customers AS (
  SELECT 
    customer_id
  FROM order_data
  GROUP BY 1
  HAVING COUNT(DISTINCT order_id) = 1  -- Single order customers
),

-- Group orders for RETURNING customers only (remove potential duplicates)
orders_grouped AS (
  SELECT
    customer_id,
    purchase_ts
  FROM core.orders
  WHERE customer_id NOT IN (SELECT customer_id FROM one_time_customers)
  GROUP BY 1, 2
), 

-- Identify first order date and assign customers to quarterly cohorts
first_orders AS (
  SELECT
    customer_id,
    MIN(purchase_ts) AS first_order_date,
    DATE_TRUNC(DATE(MIN(purchase_ts)), QUARTER) AS cohort_quarter
  FROM orders_grouped
  GROUP BY customer_id
),

-- Calculate time intervals since first purchase for all orders
orders_bucketed AS (
  SELECT
    o.customer_id,
    f.cohort_quarter,
    DATE_DIFF(DATE(o.purchase_ts), DATE(f.first_order_date), DAY) AS days_since_first,
    DATE_DIFF(DATE(o.purchase_ts), DATE(f.first_order_date), QUARTER) AS quarter_since_first
  FROM orders_grouped o
  JOIN first_orders f ON o.customer_id = f.customer_id
)

-- Calculate retention rates by cohort and quarters since first purchase
SELECT
  cohort_quarter,
  quarter_since_first,
  COUNT(DISTINCT customer_id) AS active_users,
  ROUND(
    COUNT(DISTINCT customer_id) * 100.0 / 
    MAX(COUNT(DISTINCT customer_id)) OVER (PARTITION BY cohort_quarter), 
    1
  ) AS retention_rate
FROM orders_bucketed
WHERE quarter_since_first BETWEEN 0 AND 8  -- Focus on practical timeframe (2 years)
GROUP BY 1, 2
ORDER BY cohort_quarter, quarter_since_first;


/* 
═══════════════════════════════════════
 QUERY 4: Delivery Time Analysis 
═══════════════════════════════════════
*/

/*
Purpose: Calculate average delivery time (purchase to delivery) for one-time (returning) customers

Methodology:
1. Create stable order IDs with null timestamp handling
2. Identify one-time customers (single order only) for focused analysis
3. Join orders with order_status to get delivery timestamps
4. Calculate day difference between purchase and delivery dates
5. Filter out negative day differences (data quality control)
6. Compute average delivery time for one-time customers
*/

WITH order_data AS (
  SELECT
    -- Create unique order ID handling null timestamps
    COALESCE(
      CONCAT(customer_id, '_', CAST(purchase_ts AS STRING)),
      CAST(customer_id AS STRING)
    ) AS order_id,
    customer_id,
    product_name,
    usd_price
  FROM core.orders 
),

one_time_customers AS (
  SELECT 
    customer_id
  FROM order_data
  GROUP BY 1
  HAVING COUNT(DISTINCT order_id) = 1  -- Single order customers
)

-- Calculate average delivery time for one-time (returning) customers
SELECT
  AVG(
    DATE_DIFF(
      order_status.delivery_ts, 
      order_status.purchase_ts, 
      DAY
    )
  ) AS avg_delivery_time_days
FROM core.orders 
LEFT JOIN core.order_status 
  ON orders.id = order_status.order_id
WHERE 
  -- use "customer_id NOT IN" to query stats for returning customers
  customer_id IN (SELECT customer_id FROM one_time_customers) 
  -- Exclude negative day differences (data quality)
  AND DATE_DIFF(order_status.delivery_ts, order_status.purchase_ts, DAY) > 0;
