/* 
══════════════════════════════════════
 QUERY 1: CUSTOMER SEGMENTATION 
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
 QUERY 2: CUSTOMER METRICS 
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
