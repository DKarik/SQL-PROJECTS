-- 1. Total revenue from completed orders
SELECT
    ROUND(SUM(i.quantity * i.unit_price_kes), 2) AS order_revenue
FROM orders o
INNER JOIN order_items i
ON o.order_id= i.order_id
WHERE o.order_status = 'Completed'
ORDER BY order_revenue DESC;

-- 2. Product that generates the highest revenue
SELECT
    p.product_name,
    p.product_id,
    ROUND(SUM(i.quantity * i.unit_price_kes), 2) AS total_revenue
FROM orders o
JOIN order_items i
ON o.order_id= i.order_id
JOIN products p
ON p.product_id = i.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 1;

-- findings #Power Bank with total revenue 3275180.43

-- 3. Product category with the most revenue
SELECT
    p.category,
    ROUND(SUM(i.quantity * i.unit_price_kes), 2) AS total_revenue
FROM orders o
JOIN order_items i
ON o.order_id= i.order_id
JOIN products p
ON p.product_id = i.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY total_revenue DESC
LIMIT 1;

-- findings #Electronics category with total revenue 3275180.43
-- 4. Finding the sales_channel that had the most revenue
SELECT
    o.sales_channel,
    ROUND(SUM(i.quantity * i.unit_price_kes), 2) AS total_channel_revenue
FROM orders o
INNER JOIN order_items i
ON o.order_id= i.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.sales_channel
ORDER BY total_channel_revenue DESC
LIMIT 1;
-- Findings Retail Store led with total_channel_revenue of 10656054

-- 5. Which payment method is most commonly used
SELECT payment_method, COUNT(*) AS method_count
FROM orders
GROUP BY  payment_method
ORDER BY method_count DESC
LIMIT 1;
-- Findings most commonly used method id cash by 320

-- 6. which five cites generated the highest revenue
SELECT
    c.city,
    ROUND(SUM(i.quantity * i.unit_price_kes), 2) AS total_revenue
FROM orders o
JOIN order_items i
ON o.order_id= i.order_id
JOIN customers c
ON o.customer_id= c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY total_revenue DESC
LIMIT 5;

-- 7. Which customers placed more than one completed order?
SELECT
    c.customer_id,
    COUNT(o.order_id) AS num_completed_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id
HAVING COUNT(o.order_id) > 1
ORDER BY num_completed_orders DESC;

-- 8. What percentage of orders are cancelled or returned?
SELECT 
    ROUND(
        100.0 * COUNT(CASE WHEN order_status IN ('Cancelled', 'Returned') THEN 1 END) 
        / COUNT(*), 
        2
    ) AS cancelled_or_returned_percentage
FROM orders;

-- actual figures of cancelled or returned orders 
SELECT order_status, COUNT(*)
FROM orders
WHERE order_status IN ('Cancelled', 'Returned')
GROUP BY order_status;

 







