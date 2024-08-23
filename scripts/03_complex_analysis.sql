-- 03_complex_analysis.sql

-- Analyze sales trends over time, such as monthly sales growth and seasonal trends.

-- Step 1: Calculate total sales per month
WITH monthly_sales AS (
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        SUM(p.payment_value) AS total_sales
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY STRFTIME('%Y-%m', o.order_purchase_timestamp)
    ORDER BY month
)
SELECT * FROM monthly_sales;

-- Step 2: Calculate month-over-month growth
WITH monthly_sales AS (
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        SUM(p.payment_value) AS total_sales
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY STRFTIME('%Y-%m', o.order_purchase_timestamp)
    ORDER BY month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales, 1) OVER (ORDER BY month) AS previous_month_sales,
    (total_sales - LAG(total_sales, 1) OVER (ORDER BY month)) * 100.0 / LAG(total_sales, 1) OVER (ORDER BY month) AS month_over_month_growth
FROM monthly_sales;

-- Step 3: Analyze seasonal trends by month
WITH monthly_sales AS (
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        STRFTIME('%m', o.order_purchase_timestamp) AS month_only,
        SUM(p.payment_value) AS total_sales
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY STRFTIME('%Y-%m', o.order_purchase_timestamp)
    ORDER BY month
)
SELECT 
    month_only AS month,
    AVG(total_sales) AS avg_monthly_sales
FROM monthly_sales
GROUP BY month_only
ORDER BY month;

-- Step 4: Compare yearly performance
WITH yearly_sales AS (
    SELECT 
        STRFTIME('%Y', o.order_purchase_timestamp) AS year,
        SUM(p.payment_value) AS total_sales
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY STRFTIME('%Y', o.order_purchase_timestamp)
    ORDER BY year
)
SELECT 
    year,
    total_sales,
    LAG(total_sales, 1) OVER (ORDER BY year) AS previous_year_sales,
    (total_sales - LAG(total_sales, 1) OVER (ORDER BY year)) * 100.0 / LAG(total_sales, 1) OVER (ORDER BY year) AS year_over_year_growth
FROM yearly_sales;

-- Step 5: Calculate the monthly order completion rate
WITH monthly_orders AS (
    SELECT 
        STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS completed_orders
    FROM orders
    GROUP BY month
)
SELECT 
    month,
    total_orders,
    completed_orders,
    (CAST(completed_orders AS FLOAT) / total_orders) * 100 AS completion_rate
FROM monthly_orders
ORDER BY month;

-- Step 6: Calculate the average shipping cost by month for delivered orders
WITH monthly_shipping AS (
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        AVG(oi.shipping_charges) AS avg_shipping_cost
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT * FROM monthly_shipping
ORDER BY month;

-- Step 7: Combine monthly completion rates with average shipping costs
WITH monthly_orders AS (
    SELECT 
        STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS completed_orders
    FROM orders
    GROUP BY month
),
monthly_shipping AS (
    SELECT 
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        AVG(oi.shipping_charges) AS avg_shipping_cost
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT 
    mo.month,
    mo.total_orders,
    mo.completed_orders,
    (CAST(mo.completed_orders AS FLOAT) / mo.total_orders) * 100 AS completion_rate,
    ms.avg_shipping_cost
FROM monthly_orders mo
JOIN monthly_shipping ms ON mo.month = ms.month
ORDER BY mo.month;
