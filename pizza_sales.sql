-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizza_types_copy.name, pizzas.price
FROM
    pizza_types_copy
        JOIN
    pizzas ON pizza_types_copy.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size, SUM(o.quantity) AS Total_quantity_ordered
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY SUM(o.quantity) DESC;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    p1.name, SUM(o.quantity)
FROM
    pizza_types_copy p1
        JOIN
    pizzas p ON p1.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY p1.name
ORDER BY SUM(o.quantity) DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    p1.category, SUM(o.quantity) AS quantity
FROM
    pizza_types_copy p1
        JOIN
    pizzas p ON p1.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY p1.category
ORDER BY SUM(o.quantity) DESC;



-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) from pizza_types_copy
group by category;



-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    DAY(order_date) AS Date, ROUND(AVG(qty), 0) AS Avg_Count
FROM
    (SELECT 
        order_date, SUM(quantity) AS qty
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) AS a
GROUP BY DAY(order_date);



-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types_copy.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types_copy join pizzas 
on pizzas.pizza_type_id = pizza_types_copy.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types_copy.name 
order by revenue desc limit 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types_copy.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types_copy
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types_copy.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types_copy.category
ORDER BY revenue DESC;



-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cum_rev
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;




-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name , revenue from
(select category ,name , revenue,
rank() over(partition by category order by revenue desc) as rn
from (
select pizza_types_copy.name,pizza_types_copy.category,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types_copy join pizzas 
on pizzas.pizza_type_id = pizza_types_copy.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types_copy.name ,pizza_types_copy.category) as a ) as b
where rn<=3;
