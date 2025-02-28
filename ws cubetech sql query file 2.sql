-- Basic Queries
-- 1. List all unique cities where customers are located.

SELECT Distinct customer_city from customers;

-- 2. Count the number of orders placed in 2017.
SELECT COUNT(*) AS total_orders_2017
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2017;

-- 3. Find the total sales per category.
SELECT 
    p.product_category, 
    ROUND(SUM(oi.price),2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'  -- Ensuring only completed sales are counted
GROUP BY p.product_category
ORDER BY total_sales DESC;

-- 4. Calculate the percentage of orders that were paid in installments.

SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN payment_installments > 1 THEN order_id END) 
         * 100.0) / COUNT(DISTINCT order_id), 2
    ) AS percentage_paid_in_installments
FROM payments;

SELECT 
    ROUND(
        (SUM(CASE WHEN payment_installments > 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(DISTINCT order_id), 
        2
    ) AS percentage_paid_in_installments
FROM payments;

-- 5.Count the number of customers from each state.

select customer_state, count(customer_id) as customer_count
from customers
group by customer_state
order by customer_count desc;

-- 6. Intermediate Queries 1. Calculate the number of orders per month in 2018.
select monthname(order_purchase_timestamp) as months, 
count(order_id) as order_count 
from orders 
where year(order_purchase_timestamp) =2018
group by months;

-- alternate method
SELECT 
    MONTH(order_purchase_timestamp) AS month_number,
    MONTHNAME(order_purchase_timestamp) AS months, 
    COUNT(order_id) AS order_count 
FROM orders 
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY month_number, months
ORDER BY month_number;

-- 7.  Find the average number of products per order, grouped by customer city. 
with count_per_order as 
(select orders.order_id, orders.customer_id, count(order_items.order_id) as oc
from orders join order_items
on orders.order_id = order_items.order_id
group by orders.order_id, orders.customer_id)

select customers.customer_city, round(avg(count_per_order.oc),2) average_orders
from customers join count_per_order
on customers.customer_id = count_per_order.customer_id
group by customers.customer_city order by average_orders desc;

-- 8. 3. Calculate the percentage of total revenue contributed by each product category.
SELECT 
    p.product_category, 
    ROUND(
        (SUM(oi.price) * 100.0) / 
        (SELECT SUM(price) FROM order_items), 
        2
    ) AS revenue_percentage
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue_percentage DESC;

-- 9. 4. Identify the correlation between product price and the number of times a product has been purchased.
select 
	p.product_id, product_category, 
    round(avg(oi.price), 2) as avg_price,
    count(oi. product_id) as purchase_count
    FROM order_items oi
JOIN products p on oi.product_id = p.product_id
GROUP BY p.product_id, p.product_category
order by purchase_count desc;  

-- 5. Calculate the total revenue generated by each seller, and rank them by revenue.
select oi.seller_id, 
s.seller_city,
ROUND(sum(oi.price),2) as total_revenue,
RANK() over (order by sum(oi.price) desc) as revenue_rank
from order_items oi
join sellers s on oi.seller_id = s.seller_id
group by oi.seller_id, s.seller_city 
order by total_revenue desc; 

-- 6. Advanced Queries 1. Calculate the moving average of order values for each customer over their order history. 

WITH order_values AS (
    SELECT 
        o.customer_id,
        o.order_id,
        o.order_purchase_timestamp,
        SUM(oi.price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id, o.order_purchase_timestamp
)
SELECT 
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_value,
    ROUND(AVG(order_value) OVER (
        PARTITION BY customer_id 
        ORDER BY order_purchase_timestamp 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_order_value
FROM order_values
ORDER BY customer_id, order_purchase_timestamp;
 
 -- 7. Calculate the cumulative sales per month for each year. 
 SELECT 
    years, 
    months, 
    payment, 
    SUM(payment) OVER (ORDER BY years, months) AS cumulative_sales
FROM (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS years,
        MONTH(o.order_purchase_timestamp) AS months,
        ROUND(SUM(p.payment_value), 2) AS payment
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY years, months
    ORDER BY years, months
) AS a;

-- 8. Calculate the year over year growth rate of total sales. 

WITH a AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS years,
        ROUND(SUM(p.payment_value), 2) AS payment 
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY years 
    ORDER BY years
)
SELECT 
    years, 
    ((payment - LAG(payment) OVER (ORDER BY years)) / 
    LAG(payment) OVER (ORDER BY years)) * 100 AS growth_rate
FROM a;

-- 9. Calculate the retention rate of customers, defined as the percentage of customers who make another purchase within 6 months of their first purchase.

WITH first_purchase AS (
    -- Find the first purchase date for each customer
    SELECT 
        o.customer_id,
        MIN(o.order_purchase_timestamp) AS first_order
    FROM orders o
    GROUP BY o.customer_id
),

repeat_customers AS (
    -- Find customers who made at least one more purchase within 6 months of their first purchase
    SELECT 
        fp.customer_id
    FROM first_purchase fp
    JOIN orders o 
        ON fp.customer_id = o.customer_id
        AND o.order_purchase_timestamp > fp.first_order
        AND o.order_purchase_timestamp <= DATE_ADD(fp.first_order, INTERVAL 6 MONTH)
    GROUP BY fp.customer_id
)

-- Calculate the retention rate
SELECT 
    100 * COUNT(DISTINCT rc.customer_id) / COUNT(DISTINCT fp.customer_id) AS retention_rate
FROM first_purchase fp
LEFT JOIN repeat_customers rc 
    ON fp.customer_id = rc.customer_id;
    
   -- 10. Identify the top 3 customers who spent the most money in each year.
   
 WITH ranked_customers AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS years,
        o.customer_id,
        SUM(p.payment_value) AS payment,
        DENSE_RANK() OVER (
            PARTITION BY YEAR(o.order_purchase_timestamp) 
            ORDER BY SUM(p.payment_value) DESC
        ) AS d_rank
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY YEAR(o.order_purchase_timestamp), o.customer_id
)

SELECT years, customer_id, payment, d_rank
FROM ranked_customers
WHERE d_rank <= 3
ORDER BY years, d_rank;


    
    
