-- select the database to use
use pizza_db;

-- 1. How many pizzas were ordered?
SELECT COUNT(order_id) AS Number_of_pizzas_ordered 
FROM new_customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS Number_of_pizzas_ordered 
FROM new_customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS delivered_orders
FROM runner_orders
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT pizza_id, COUNT(r.order_id) AS delivered_pizza
FROM runner_orders as r
INNER JOIN new_customer_orders as p
ON r.order_id = p.order_id
GROUP BY pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
s