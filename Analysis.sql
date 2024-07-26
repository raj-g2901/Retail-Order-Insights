Create database my_db;
use  my_db;
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);
select * from df_orders;

-- find top 10 highest reveue generating products 
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

-- find top 5 highest selling products in each region
WITH cte AS (
  select region, product_id, sum(sale_price) as sales
  from df_orders
  group by region, product_id
),
ranked AS (
   SELECT *, row_number() over(partition by region order by sales desc) as rn
   FROM cte
)
SELECT *
FROM ranked
WHERE rn <= 5
-- this is a better solution 


-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
	)
    
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month 
order by order_month


-- for each category which month had highest sales 
with cte as (
select category, DATE_FORMAT(order_date, '%Y%m') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,DATE_FORMAT(order_date, '%Y%m')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1


-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category, sum((CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END ) ) as sales_2022,
					 sum((CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END ) ) as sales_2023
from df_orders
group by sub_category
)

select *, (sales_2023 - sales_2022)*100/sales_2022 as percent_growth
from cte
order by percent_growth desc
limit 1

