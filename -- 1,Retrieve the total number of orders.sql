-- 1,Retrieve the total number of orders placed:
--

SELECT COUNT(*) AS total_orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales:
--

SELECT SUM(o.total_amount) AS total_revenue
FROM orders o;

-- 3. Identify the highest-priced pizza:
--

SELECT p.pizza_name, MAX(oi.price) AS highest_price
FROM order_items oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
GROUP BY p.pizza_name
ORDER BY highest_price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered:
--

SELECT oi.size, COUNT(*) AS size_count
FROM order_items oi
GROUP BY oi.size
ORDER BY size_count DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities:
--

SELECT p.pizza_name, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
GROUP BY p.pizza_name
ORDER BY total_quantity DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered:
--
Copy code
SELECT p.category, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
GROUP BY p.category;
-- 7. Determine the distribution of orders by hour of the day:
--

SELECT EXTRACT(HOUR FROM o.order_date) AS order_hour, COUNT(*) AS orders_count
FROM orders o
GROUP BY order_hour
ORDER BY order_hour;

-- 8. Join relevant tables to find the category-wise distribution of pizzas:
--

SELECT p.category, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
GROUP BY p.category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day:
--

SELECT DATE(o.order_date) AS order_date, AVG(oi.quantity) AS avg_pizzas_per_day
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_date;

-- 10. Determine the top 3 most ordered pizza types based on revenue:
--

SELECT p.pizza_name, SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi
JOIN pizzas p ON oi.pizza_id = p.pizza_id
GROUP BY p.pizza_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue:
--

WITH pizza_revenue AS (
  SELECT p.pizza_name, SUM(oi.quantity * oi.price) AS total_revenue
  FROM order_items oi
  JOIN pizzas p ON oi.pizza_id = p.pizza_id
  GROUP BY p.pizza_name
),
total_revenue AS (
  SELECT SUM(oi.quantity * oi.price) AS total_revenue
  FROM order_items oi
)
SELECT pr.pizza_name, (pr.total_revenue / tr.total_revenue) * 100 AS revenue_percentage
FROM pizza_revenue pr, total_revenue tr
ORDER BY revenue_percentage DESC;

-- 12. Analyze the cumulative revenue generated over time:
--

SELECT DATE(o.order_date) AS order_date, SUM(oi.quantity * oi.price) AS cumulative_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_date
ORDER BY order_date;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category:
--


WITH pizza_revenue AS (
  SELECT p.category, p.pizza_name, SUM(oi.quantity * oi.price) AS total_revenue
  FROM order_items oi
  JOIN pizzas p ON oi.pizza_id = p.pizza_id
  GROUP BY p.category, p.pizza_name
)
SELECT category, pizza_name, total_revenue
FROM (
  SELECT category, pizza_name, total_revenue,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rn
  FROM pizza_revenue
) AS ranked_pizzas
WHERE rn <= 3
ORDER BY category, total_revenue DESC;