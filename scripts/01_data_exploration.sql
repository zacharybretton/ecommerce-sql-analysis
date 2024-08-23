-- 01_data_exploration.sql
-- This script explores the E-commerce Order Dataset to understand its structure, 
-- the range of data, and initial insights into orders, products, customers, and payments.

-- Display structure of Orders Table
PRAGMA table_info(orders);

-- Display structure of Order Items Table
PRAGMA table_info(order_items);

-- Display structure of Customers Table
PRAGMA table_info(customers);

-- Display structure of Payments Table
PRAGMA table_info(payments);

-- Display structure of Products Table
PRAGMA table_info(products);

-- Check the date range in orders
SELECT MIN(order_purchase_timestamp) AS earliest_order, 
       MAX(order_purchase_timestamp) AS latest_order 
FROM orders;

-- Count null values in each column
SELECT COUNT(*) AS null_count FROM orders WHERE order_purchase_timestamp IS NULL;
-- Data doesnt have NULL issues

-- Count orders by status
SELECT order_status, COUNT(*) AS order_count
FROM orders 
GROUP BY order_status 
ORDER BY order_count DESC;

-- Total order count
SELECT COUNT(*) AS order_count
FROM orders;

-- Count null values in important date columns using conditional aggregation
SELECT 
  SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved,
  SUM(CASE WHEN order_delivered_timestamp IS NULL THEN 1 ELSE 0 END) AS null_delivered,
  SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated
FROM orders;

-- Total number of distinct customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers;

-- Total number of distinct products
SELECT COUNT(DISTINCT product_id) AS total_products
FROM products;


-- Get basic statistics on product prices
SELECT MIN(price) AS min_price, 
       MAX(price) AS max_price, 
       AVG(price) AS avg_price 
FROM order_items;

-- Get basic statistics on shipping charges
SELECT MIN(shipping_charges) AS min_shipping, 
       MAX(shipping_charges) AS max_shipping, 
       AVG(shipping_charges) AS avg_shipping 
FROM order_items;


-- Count customers by city and state
SELECT customer_city, customer_state, COUNT(*) AS customer_count 
FROM customers 
GROUP BY customer_city, customer_state 
ORDER BY customer_count DESC;

-- Count customers by zip code prefix
SELECT customer_zip_code_prefix, COUNT(*) AS customer_count 
FROM customers 
GROUP BY customer_zip_code_prefix 
ORDER BY customer_count DESC;

-- Count payments by type
SELECT payment_type, COUNT(*) AS payment_count 
FROM payments 
GROUP BY payment_type 
ORDER BY payment_count DESC;

-- Count payment installments
SELECT payment_installments, COUNT(*) AS installment_count 
FROM payments 
GROUP BY payment_installments 
ORDER BY installment_count DESC;

-- Get basic statistics on payment values
SELECT MIN(payment_value) AS min_payment, 
       MAX(payment_value) AS max_payment, 
       AVG(payment_value) AS avg_payment 
FROM payments;

-- Count unique products by category
SELECT product_category_name, COUNT(DISTINCT product_id) AS unique_product_count 
FROM products 
GROUP BY product_category_name 
ORDER BY unique_product_count DESC;

-- Count products by category
SELECT product_category_name, COUNT(*) AS product_count 
FROM products 
GROUP BY product_category_name 
ORDER BY product_count DESC;

-- Get basic statistics on product dimensions
SELECT MIN(product_weight_g) AS min_weight, 
       MAX(product_weight_g) AS max_weight, 
       AVG(product_weight_g) AS avg_weight,
       MIN(product_length_cm) AS min_length, 
       MAX(product_length_cm) AS max_length, 
       AVG(product_length_cm) AS avg_length,
       MIN(product_height_cm) AS min_height, 
       MAX(product_height_cm) AS max_height, 
       AVG(product_height_cm) AS avg_height,
       MIN(product_width_cm) AS min_width, 
       MAX(product_width_cm) AS max_width, 
       AVG(product_width_cm) AS avg_width
FROM products;

-- Top-selling products by quantity sold
SELECT product_id, COUNT(*) AS total_sold
FROM order_items
GROUP BY product_id
ORDER BY total_sold DESC
LIMIT 10;

-- Top-selling product categories by quantity sold
SELECT p.product_category_name, COUNT(oi.product_id) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sold DESC
LIMIT 10;


-- Check for matching order_ids between orders and order_items
SELECT o.order_id, COUNT(oi.order_id) AS item_count
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING item_count = 0;

-- Verify that all orders have corresponding payments
SELECT o.order_id, COUNT(p.order_id) AS payment_count
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id
HAVING payment_count = 0;


-- =============================================================
-- SUMMARY OF DATA EXPLORATION
-- =============================================================

-- Orders Table:
-- - Date Range: The orders span from 2016-09-04 to 2018-09-03.
-- - Order Status: The most common order status is 'delivered', with 87428 occurrences out of 89316 total unique orders.
-- - 9 NULL values found in 'approved', 1889 NULL found in 'delivered', 0 in 'estimated'

-- Order Items Table:
-- - Price Range: Product prices range from R$0.85 to R$6735.0, with an average price of R$340.90.
-- - Shipping Charges: Shipping costs range from R$0.0 to R$409.68, with an average cost of R$44.28.

-- Customers Table:
-- - Customer Distribution: The largest number of customers are from Sao Paulo (14,352), followed by Rio de Janeiro (6,248).
-- - Zip Code Distribution: The most common zip code prefix is 46550, with 184 customers.

-- Payments Table:
-- - Payment Types: The most frequent payment type is by Credit Card, followed by Cash (wallet).
-- - Payment Installments: The most common installment plan has 1 payment installment (which is just a full purchase), the next most common installment plan has 2 payment installments.
-- - Payment Value: Payments range from R$0.0 to R$7274.88, with an average value of R$268.66.

-- Products Table:
-- - Unique Product Categories: The most common product category is Toys, with 20,609 unique products. The next most common product category is Bed/Bath Table, with 654 unqiue products. There are a total of 27451 unique products.
-- - Product Categories: The most common product category is Toys, with 67,027 products. The next most common product category is Health/Beauty, with 2351 products.
-- - Product Dimensions: Products have the following dimension ranges:
--   - Weight: 0.0 g to 40,425 g, Avg: 2087.07 g
--   - Length: 7.0 cm to 105.0 cm, Avg: 30.22 cm
--   - Height: 2.0 cm to 105.0 cm, Avg: 16.56 cm
--   - Width: 6.0 cm to 118.0 cm, Avg: 23.03 cm
-- - Top Product: The top three product ID's were 0vbEvli2JYJu, UgkSjxoiV9Ev, 9NwzO0Pm0fDM with 405, 383 and 383 total sales respectively.
-- - Top Product Category: The top category sold were Toys at 1,869,621 total sales, the second most were Health/Beauty with 161,543 total sales.


-- Data Integrity:
-- - All orders have corresponding items and payments, indicating strong data integrity.
