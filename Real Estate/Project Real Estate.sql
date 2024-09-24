--Houses sold from 2001-2022
select count(*) from estate

--Town with the largest sales in unit houses
select 
	town, 
	count(*) total_houses_sold 
from 
	estate
group by 
	town
order by 
	total_houses_sold desc

--Total revenue
select sum(sale_amount) as revenue from estate

--Average revenue, unit sold, lowest price, and highest price by house age
with data_house as (
	select sale_amount, list_year, 
	abs(2022-list_year) as house_age from estate
)

select 
	house_age, 
	count(*) as unit_sold, 
	round(sum(sale_amount)/count(*),4) as avg_revenue, min(sale_amount) as lowest_price,
	max(sale_amount) as highest_price
from 
	data_house
group by 
	house_age
order by 
avg_revenue desc

--Average revenue, unit sold, and most popular property type by town
with data as (select
	town,
	sale_amount,
	property_type,
	round(sum(sale_amount) over (partition by town)/count(*) over (partition by town),4) as avg_revenue,
	count(*) over (partition by town) as unit_sold
from 
	estate
)

select
	town,
	avg_revenue,
	unit_sold,
	property_type as property_type
from (select
	town,
	avg_revenue,
	unit_sold,
	property_type,
	row_number() over (partition by town order by count(*) desc) as rank
from 
	data
group by 	
	town, avg_revenue, unit_sold, property_type
) ranked_types
where rank = 1
order by 
	avg_revenue desc



