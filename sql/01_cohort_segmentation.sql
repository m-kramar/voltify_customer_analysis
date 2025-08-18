/* 
══════════════════════════════════════
 QUERY 1: Customer segmentation 
══════════════════════════════════════
*/

/*
Purpose: Classify customers as new vs. returning and calculate:
  - Customer count
  - Order volume
  - Item sales
  - Revenue contribution

Methodology:
1. Create unique order IDs handling null timestamps
2. Classify customers based on order count
3. Aggregate metrics by customer type
*/

WITH order_data AS (
  SELECT
    -- Create unique order ID handling null timestamps
    COALESCE(
      CONCAT(customer_id, '_', CAST(purchase_ts AS STRING)), 
      CAST(customer_id AS STRING)
    ) AS order_id,
    customer_id,
    id AS line_item_id,
    usd_price
  FROM core.orders 
),

customer_classification AS (
  SELECT
    customer_id,
    -- Flag customers with only one order as new
    CASE WHEN COUNT(DISTINCT order_id) = 1 
         THEN 'new_customer' 
         ELSE 'returning_customer' 
    END AS customer_type
  FROM order_data
  GROUP BY customer_id
)

SELECT
  cc.customer_type,
  COUNT(DISTINCT od.customer_id) AS num_customers,
  COUNT(DISTINCT od.order_id) AS num_orders,
  COUNT(od.line_item_id) AS num_items,
  ROUND(SUM(od.usd_price),2) AS total_revenue
FROM order_data od
JOIN customer_classification cc 
  ON od.customer_id = cc.customer_id
GROUP BY 1;

/* 
══════════════════════════════════════
 QUERY 2: Customer metrics 
══════════════════════════════════════
*/

/*
Purpose: Calculate key e-commerce metrics by customer type:
  - Average Order Value (AOV)
  - Orders per customer
  - Items per order
  - Revenue per customer

Methodology:
1. Create unique order IDs handling null timestamps
2. Classify customers based on order count
3. Aggregate metrics by customer type
*/

WITH order_data AS (
  SELECT
    -- Create unique order ID handling null timestamps
    COALESCE(
      CONCAT(customer_id, '_', CAST(purchase_ts AS STRING)),
      CAST(customer_id AS STRING)
    ) AS order_id,
    customer_id,
    id AS line_item_id,
    usd_price
  FROM core.orders  
),

customer_classification AS (
  SELECT
    customer_id,
    -- Flag customers with only one order as new
    CASE WHEN COUNT(DISTINCT order_id) = 1 
         THEN 'new_customer' 
         ELSE 'returning_customer' 
    END AS customer_type
  FROM order_data
  GROUP BY customer_id
)

SELECT
  cc.customer_type,
  -- Key metric calculations
  ROUND(SUM(od.usd_price) / COUNT(DISTINCT od.order_id), 2) AS aov,
  ROUND(COUNT(DISTINCT od.order_id) / COUNT(DISTINCT od.customer_id), 2) AS orders_per_customer,
  ROUND(COUNT(od.line_item_id) / COUNT(DISTINCT od.order_id), 2) AS items_per_order,
  ROUND(SUM(od.usd_price) / COUNT(DISTINCT od.customer_id), 2) AS revenue_per_customer
FROM order_data od
JOIN customer_classification cc 
  ON od.customer_id = cc.customer_id
GROUP BY 1;

/* 
══════════════════════════════════════
 QUERY 3: Product metrics by user type 
══════════════════════════════════════
*/

/*
VOLTIFY PRODUCT ANALYSIS: ONE-TIME CUSTOMERS | RETURNING CUSTIMERS
Purpose: Analyze purchasing patterns by product and customer type:
  - Items purchased
  - Total revenue
  - Average price

Methodology:
1. Create stable order IDs with null handling
2. Identify one-time customers (single order only)
3. Standardize product names
4. Calculate metrics with efficient subqueries
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

product_cleanup AS (
  SELECT
    -- Standardize product names
    CASE 
      WHEN LOWER(product_name) = '27in"" 4k gaming monitor' 
        THEN '27in 4K gaming monitor'
      ELSE product_name 
    END AS clean_product_name,
    usd_price,
    customer_id
  FROM order_data
)

SELECT
  p.clean_product_name AS product_name,
  COUNT(*) AS items_purchased,
  ROUND(SUM(p.usd_price), 2) AS total_revenue,
  ROUND(AVG(p.usd_price), 2) AS avg_price_usd
FROM product_cleanup p
WHERE p.customer_id IN (SELECT customer_id FROM one_time_customers) -- use "NOT IN" for filtering returning customer's stats 
GROUP BY 1
ORDER BY avg_price_usd DESC;

/* 
═════════════════════════════════════════════════════════════════
 QUERY 4: Returning Users – First vs. Subsequent Purchase Metrics
═════════════════════════════════════════════════════════════════
*/

/*
VOLTIFY PURCHASE ANALYSIS: RETURNING USERS
Purpose: Analyze first-purchase vs. subsequent purchase behavior of customers who become returning buyers
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

-- Rank purchases for RETURNING customers only
ranked_orders AS (
  SELECT 
    customer_id,
    purchase_ts,
    product_name,
    usd_price,
    -- DENSE_RANK ensures all items in same order get same rank
    -- (Critical for multi-item orders)
    DENSE_RANK() OVER (
      PARTITION BY customer_id 
      ORDER BY purchase_ts ASC
    ) AS order_rank
  FROM core.orders
  WHERE customer_id NOT IN (SELECT customer_id FROM one_time_customers)
)

-- Final product metrics for first purchases
SELECT
  -- Standardize monitor naming
  CASE 
    WHEN product_name = '27in"" 4k gaming monitor' 
      THEN '27in 4K gaming monitor' 
    ELSE product_name 
  END AS product_name,
  
  COUNT(product_name) AS items_purchased,
  ROUND(SUM(usd_price), 2) AS total_price,
  ROUND(AVG(usd_price), 2) AS avg_price_usd
 
FROM ranked_orders 
WHERE order_rank = 1  -- use "> 1" for 2nd & subsequent orders
GROUP BY 1
ORDER BY avg_price_usd DESC;
