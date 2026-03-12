drop table df_orders

create table df_orders(
	[order_id] int primary key,
	[order_date] date,
	[ship_mode] varchar(20),
	[segment] varchar(20),
	[country] varchar(20),
	[city] varchar(20),
	[state] varchar(20),
	[postal_code] varchar(20),
	[region] varchar(20),
	[category] varchar(20),
	[sub_category] varchar(20),
	[product_id] varchar(50),
	[quantity] int,
	[discount] decimal(7,2),
	[sales_price] decimal(7,2),
	[profit] decimal(7,2),
	[total_sales] decimal(7,2),
	[total_profit] decimal(7,2))



select * from df_orders



-- top 10 revenue generating products

select top 10 product_id,SUM(total_sales) as [sum of sales]
from df_orders
group by product_id
order by [sum of sales] desc



-- top 5 highest selling products from each region

with cte as(select region,product_id, SUM(total_sales) as [sales]
from df_orders
group by region,product_id)

select * from
(select
*, ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5



-- find the month over month growth comparison for year 2022 & 2023 sales 

with cte as(
select year(order_date) as year_ ,month(order_date) as month_, sum(total_sales) as sales_ from df_orders
group by year(order_date),month(order_date)
)
select month_ ,
	sum(case when year_=2022 then sales_ else 0 end) as sl_2022,
	sum(case when year_=2023 then sales_ else 0 end) as sl_2023
from cte
group by month_
order by month_



-- for each category which month had the highest sales

with cte as(
select category,year(order_date) as year_,month(order_date) as month_ , sum(total_sales) as sales_ from df_orders
group by category,year(order_date), month(order_date)
--order by category,year(order_date), month(order_date)
)

select * from
(select *, ROW_NUMBER() over(partition by category order by sales_ desc) as rn
from cte) B
where rn=1



-- which sub-category shows the highest profit growth from year 2022 to year 2023

with cte as(
select sub_category,year(order_date) as year_ , sum(total_sales) as sales_ from df_orders
group by sub_category,year(order_date)
),
cte2 as(
select sub_category ,
	sum(case when year_=2022 then sales_ else 0 end) as sl_2022,
	sum(case when year_=2023 then sales_ else 0 end) as sl_2023
from cte
group by sub_category
)

select top 1 *,(sl_2023-sl_2022) as [profits_increased] from cte2
