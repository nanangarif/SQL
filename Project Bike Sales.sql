--How about customers conversion rate?
select count(distinct c.customer_id) as total_customers,
count(distinct o.customer_id) as active_customers,
round(100*count(distinct o.customer_id)/count(distinct c.customer_id),2) as conversion_rate
from customers c
left join orders o
on c.customer_id = o.customer_id

--Who are the most frequent customers?
select c.customer_id, c.first_name, c.last_name, c.state, c.city, count(o.customer_id) as order_freq
from customers as c
inner join orders as o
on c.customer_id = o.customer_id
group by c.customer_id, c.first_name, c.last_name, c.state, c.city
having count(o.customer_id) > 1
order by order_freq desc

--How about monthly sales peformance?
select date_trunc('month', o.order_date), sum(oi.quantity) as monthly_sales
from orders o
inner join order_items oi
on o.order_id = oi.order_id
group by 1
order by 1 asc

--How about sales by city?
select c.city, sum(oi.quantity) as total_sales
from customers c
inner join orders o
on o.customer_id = c.customer_id
inner join order_items oi
on oi.order_id = o.order_id
group by 1 
order by 2 desc

--What's month with the highest sales?
select extract(month from o.order_date) as month,
sum(oi.quantity) as total_sales
from orders o
inner join order_items oi
on o.order_id = oi.order_id
group by 1
order by 2 desc

--Count the revenue and net revenue
select round(sum(oi.quantity*oi.list_price),4) as revenue,
round(sum(oi.quantity*oi.list_price*(1-oi.discount)),4) as net_revenue
from order_items oi 

--How about order frequency distribution
with order_freq as (
select c.customer_id,
count(o.order_id) order_frequency
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by 1
)

select 
count(customer_id),
order_frequency
from order_freq
group by 2
order by 2 asc









