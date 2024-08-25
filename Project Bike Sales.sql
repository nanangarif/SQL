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

--Count the avg customers recency score for each city
with recency as (
select c.city, c.customer_id,
max(o.order_date) first_purchase,
min(o.order_date) last_purchase,
(max(o.order_date) - min(o.order_date)) recency_score
from customers c
inner join orders o
on o.customer_id = c.customer_id
group by 1,2
having (max(o.order_date) - min(o.order_date)) != 0
order by 5 asc
)

select 
city,
round(avg(recency_score),2) as avg_recency_score
from recency
group by 1
order by 2 asc

--Count the customer lifetime value (CLV)
select
c.customer_id,
c.first_name,
c.last_name,
c.state,
c.city,
sum(oi.quantity*oi.list_price*(1-oi.discount)) as CLV
from customers c
inner join orders o on c.customer_id = o.customer_id
inner join order_items oi on o.order_id = oi.order_id
group by 1,2,3,4,5
order by 6 desc

--What's the most popular brand for each city and state?
with city_sales as (
select 
c.city,
c.state,
b.brand_name,
p.product_name,
sum(oi.quantity) as total_quantity_sold
from customers c
inner join orders o on c.customer_id = o.customer_id
inner join order_items oi on o.order_id = oi.order_id
inner join products p on p.product_id = oi.product_id
inner join brands b on b.brand_id = p.brand_id
group by c.city, c.state, b.brand_name, p.product_name
),
max_sales as (
select 
city,
state,
brand_name,
max(total_quantity_sold) as max_quantity_sold
from city_sales
group by city, state, brand_name
)
select 
cs.city,
cs.state,
cs.brand_name,
cs.product_name,
cs.total_quantity_sold
from city_sales cs
inner join max_sales ms on cs.city = ms.city 
and cs.state = ms.state 
and cs.brand_name = ms.brand_name 
and cs.total_quantity_sold = ms.max_quantity_sold
order by cs.total_quantity_sold desc;









