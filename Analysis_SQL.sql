use satyamdb;

select * from `list_of_orders_38ef37c2f3`;

select * from `order_details_f6d252b2dd`;

select Category, sum(Amount) as total_sales
from `list_of_orders_38ef37c2f3` l
join `order_details_f6d252b2dd` o on l.`Order ID`=o.`Order ID`
group by Category
order by total_sales;

create table merged_order_sales as
select l.*, o.amount as amount, o.profit as profit, o.quantity as quantity, o.category as category
from `list_of_orders_38ef37c2f3` l
join `order_details_f6d252b2dd` o on l.`Order ID`=o.`Order ID`;

select category, avg(profit) as avg_profit, round((sum(profit)/sum(amount))*100, 2) as total_profit_margin
from merged_order_sales
group by category;


-- sales target analysis

select * from sales_target_1c8295ccde;

SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

update sales_target_1c8295ccde
set `Month of Order Date`=STR_TO_DATE(CONCAT('01-', `Month of Order Date`), '%d-%b-%y');

select date_format(`Month of Order Date`, '%Y-%m') as order_month, target, 
case
when lag(target) over (order by `Month of Order Date`) is null then 0
else round(((target-lag(target) over (order by `Month of Order Date`))/lag(target) over (order by `Month of Order Date`))*100, 2)
end as monthly_change
from sales_target_1c8295ccde
where category='furniture';


-- regional performance analysis

select state, count(`order id`) as order_count
from list_of_orders_38ef37c2f3
where state is not null and state<>''
group by state
order by order_count desc 
limit 5;

with cte as(
select state, count(`order id`) as order_count
from list_of_orders_38ef37c2f3
where state is not null and state<>''
group by state
order by order_count desc 
limit 5
)
select state, round(sum(amount), 2) as total_sales, round(avg(profit), 2) as avg_profit
from merged_order_sales
where state in (select state from cte)
group by state
order by total_sales desc;


