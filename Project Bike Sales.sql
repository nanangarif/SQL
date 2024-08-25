--Conversion rate
select count(distinct c.customer_id) as total_customers,
count(distinct o.customer_id) as active_customers,
round(100*count(distinct o.customer_id)/count(distinct c.customer_id),2) as conversion_rate
from customers c
left join orders o
on c.customer_id = o.customer_id

--Num of Transactions
select count(order_id) from orders

--Most frequent customers
select c.customer_id, c.first_name, c.last_name, c.state, c.city, count(o.customer_id) as order_freq
from customers as c
inner join orders as o
on c.customer_id = o.customer_id
group by c.customer_id, c.first_name, c.last_name, c.state, c.city
having count(o.customer_id) > 1
order by order_freq desc

--Monthly sales trend ovetime
select date_trunc('month', o.order_date), sum(oi.quantity) as monthly_sales
from orders o
inner join order_items oi
on o.order_id = oi.order_id
group by 1
order by 1 asc

--Sales by City
select c.city, sum(oi.quantity) as total_sales
from customers c
inner join orders o
on o.customer_id = c.customer_id
inner join order_items oi
on oi.order_id = o.order_id
group by 1 
order by 2 desc










