--Number of Crime Incidents from 2020 - now (2024)
select 
    count(distinct dr_no) as num_of_crimes
from 
    crime;

--Number of Crimes Incidents by Type
select 
    count(distinct dr_no) as num_of_crimes,
    crime_code
from
    crime
group by
    crime_code
order by
    num_of_crimes desc;

-- The time, location, and most frequent crime type with the highest number of incidents
with crime_data as (
    select
        extract(hour from time_occured) as hour,
        crime_code as most_crime_type,
        location,
        count(*) as num_of_crimes,
        rank() over (partition by extract(hour from time_occured), location order by count(*) desc) as crime_rank
    from
        crime
    group by
        hour, location, most_crime_type
)

select
    hour, most_crime_type, num_of_crimes, location
from
    crime_data
where 
    crime_rank = 1
order by
    num_of_crimes desc;

--Most Common Weapon Used
select 
	weapon,
	count(*) as num_of_crimes
from
	crime
group by
	weapon
order by
	num_of_crimes desc
limit 1

--Crime Incidents that Used Firearms
select
	count(*) as crimes_with_firearms
from
	crime
where
	weapon ilike '%gun%' or
	weapon ilike '%rifle%' or
	weapon ilike '%pistol%' or
	weapon ilike '%machine%' or
	weapon ilike '%assault%' or
	weapon ilike '%weapon%' or
	weapon ilike '%firearms%' 

--Most Used Weapon for Each Crime Type
with weapon_data as (
	select crime_code,weapon,
	count(*) as num_of_crimes,
	rank() over (partition by crime_code order by count(*) desc) as rank
from
	crime
group by
	crime_code, weapon
)

select
	crime_code,
	weapon as most_used_weapon,
	num_of_crimes
from
	weapon_data
where
	rank = 1

--Crime Type with Most Used Firearms Weapon
with firearms as (
	select
	crime_code,
	weapon,
	count(*) as num_of_crimes,
	rank() over (partition by crime_code order by count(*) desc) as rank
from	
	crime
where
	weapon ilike '%gun%' or
	weapon ilike '%rifle%' or
	weapon ilike '%pistol%' or
	weapon ilike '%machine%' or
	weapon ilike '%assault%' or
	weapon ilike '%shotgun' or
	weapon ilike '%firearms%'
group by
	crime_code, weapon
)

select
	crime_code,
	weapon as most_used_weapon,
	num_of_crimes
from
	firearms
where
	rank =1 
order by
	num_of_crimes desc

--Crime type and the Victim Sex
with vict as (
    select
        crime_code,
        victim_sex,
        count(*) as num_of_crimes,
        rank() over (partition by crime_code, victim_sex order by count(*) desc) as rank
    from 
        crime
    group by
        crime_code, victim_sex
)

select
    crime_code as most_crime_type,
    victim_sex,
    num_of_crimes
from
    vict
where
    rank = 1
order by
    num_of_crimes desc;
	

--Crime Type and Victim Descent
with descent as(
    select
        crime_code,
        victim_descent,
        weapon,
        count(*) num_of_crimes,
        rank() over (partition by crime_code, victim_descent, weapon order by count(*) desc) as rank
    from
        crime
    group by
        crime_code, victim_descent, weapon
)

select
    crime_code,
    victim_descent,
    weapon,
    num_of_crimes
from
    descent
where
    rank = 1
order by
    num_of_crimes desc;

--Crime Incidents by Age Group
select 
    case
        when victim_age = 0 then 'Babies (0 yo)'
        when victim_age between 1 and 5 then 'Toddlers (1 - 5 yo)'
        when victim_age between 6 and 10 then 'Kids (6 - 10 yo)'
        when victim_age between 11 and 18 then 'Teenagers (11 - 18 yo)'
        when victim_age between 19 and 25 then 'Young Adults (19 - 25 yo)'
        when victim_age between 26 and 60 then 'Adults (26 - 60 yo)'
        else 'Senior (60+)'
    end as age_group,
    count(*) as crime_incidents
from
    crime
where 
    victim_age >= 0
group by
    age_group
order by
    crime_incidents desc;

--Crime Incidents by Age Group in Detail
with data as (
    select
        crime_code,
        victim_descent,
        count(*) as num_of_crimes,
        case
            when victim_age = 0 then 'Babies (0 yo)'
            when victim_age between 1 and 5 then 'Toddlers (1 - 5 yo)'
            when victim_age between 6 and 10 then 'Kids (6 - 10 yo)'
            when victim_age between 11 and 18 then 'Teenagers (11 - 18 yo)'
            when victim_age between 19 and 25 then 'Young Adults (19 - 25 yo)'
            when victim_age between 26 and 60 then 'Adults (26 - 60 yo)'
            else 'Senior (60+)'
        end as age_group
    from
        crime
    where
        victim_age >= 0
    group by
        crime_code, age_group, victim_descent
),
ranked_data as(
    select
        crime_code,
        victim_descent,
        num_of_crimes,
        age_group,
        rank() over (partition by age_group order by num_of_crimes desc) as rank
    from
        data
)

select
    age_group,
    victim_descent,
    crime_code as top_crime_incidents,
    num_of_crimes
from
    ranked_data
where 
    rank = 1
order by
    num_of_crimes desc;

--Daily Crime Trend
select
    date_trunc('day', date_occured) as date,
    count(*) num_of_crimes
from 
    crime
group by
    date
order by
    date asc;

--Status Percentage
select
    status,
    count(*) as num_of_crimes,
    (select count(*) from crime) as total_crimes,
    (100 * count(*) / (select count(*) from crime)) as percentage
from 
    crime
group by
    status
order by
    percentage desc;

--