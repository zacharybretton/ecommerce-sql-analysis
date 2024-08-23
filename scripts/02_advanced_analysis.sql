-- 02_advanced_analysis.sql


-- Part 1:
-- Assess how well the supply chain is meeting estimated delivery times by calculating the average actual delivery time,
-- comparing it to the estimated delivery dates

-- Calculate the actual delivery time in days
SELECT 
    order_id,
    order_approved_at,
    order_delivered_timestamp,
    JULIANDAY(order_delivered_timestamp) - JULIANDAY(order_approved_at) AS actual_delivery_time_days
FROM orders
WHERE order_delivered_timestamp IS NOT NULL
  AND order_approved_at IS NOT NULL;

-- Calculate the delivery delay in days
SELECT 
    order_id,
    order_estimated_delivery_date,
    order_delivered_timestamp,
    JULIANDAY(order_delivered_timestamp) - JULIANDAY(order_estimated_delivery_date) AS delivery_delay_days
FROM orders
WHERE order_delivered_timestamp IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
ORDER BY delivery_delay_days DESC;

-- Calculate the average delivery time and delay
SELECT 
    AVG(JULIANDAY(order_delivered_timestamp) - JULIANDAY(order_approved_at)) AS avg_delivery_time_days,
    AVG(JULIANDAY(order_delivered_timestamp) - JULIANDAY(order_estimated_delivery_date)) AS avg_delivery_delay_days
FROM orders
WHERE order_delivered_timestamp IS NOT NULL
  AND order_approved_at IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

  
-- Analysis of Delivery data:
-- - Average Delivery Time (days): 12.00
-- - Average Delivery Delay from Estimate: -11.4346250247851
-- 		- This means that on average items are being shipped and recieved faster than the estimated time
--############################################################################################################--

-- Part 2:
-- Explore the distribution of payment types and their impact on order value.

-- Calculate the distribution of payment types for delivered orders
SELECT 
    p.payment_type,
    COUNT(*) AS payment_count,
    SUM(p.payment_value) AS total_payment_value,
    AVG(p.payment_value) AS avg_payment_value
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_payment_value DESC;

-- Calculate the average order value by payment type for delivered orders
SELECT 
    p.payment_type,
    AVG(p.payment_value) AS avg_order_value
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY avg_order_value DESC;

-- Analyze payment type impact on product categories for delivered orders
SELECT 
    p.payment_type,
    pr.product_category_name,
    SUM(p.payment_value) AS total_spent,
    COUNT(DISTINCT oi.order_id) AS order_count,
    AVG(p.payment_value) AS avg_spent_per_order
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN order_items oi ON p.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type, pr.product_category_name
ORDER BY order_count DESC;

-- Calculate total spending per payment type for delivered orders
SELECT 
    p.payment_type,
    SUM(p.payment_value) AS total_spent
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type;


-- Step 3: 
-- Segment customers based on order frequency and total spending.

-- Calculate total spending for each customer (only for delivered orders)
SELECT 
    c.customer_id,
    SUM(p.payment_value) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- Segment customers into spending tiers (high, medium, low)
SELECT 
    c.customer_id,
    SUM(p.payment_value) AS total_spent,
    CASE 
        WHEN SUM(p.payment_value) >= 5000 THEN 'High Spender'
        WHEN SUM(p.payment_value) BETWEEN 1000 AND 4999.99 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_tier
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- Analyze product preferences by spending tier
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        SUM(p.payment_value) AS total_spent,
        CASE 
            WHEN SUM(p.payment_value) >= 5000 THEN 'High Spender'
            WHEN SUM(p.payment_value) BETWEEN 1000 AND 4999.99 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spending_tier
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
)
SELECT 
    cs.spending_tier,
    pr.product_category_name,
    COUNT(oi.product_id) AS product_count
FROM customer_spending cs
JOIN orders o ON cs.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY cs.spending_tier, pr.product_category_name
ORDER BY cs.spending_tier, product_count DESC;
