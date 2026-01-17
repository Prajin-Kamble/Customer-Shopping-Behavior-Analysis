-- Handling null values present in review_rating columns
select * from customer_shopping_behavior where review_rating is null;

update customer_shopping_behavior main_table
set review_rating = sub_table.median_rating
from (
	select category,
	percentile_cont(0.5) within group (order by review_rating) as median_rating
	from customer_shopping_behavior
	where review_rating is not null
	group by category
) sub_table
where main_table.category = sub_table.category and main_table.review_rating is null;


-- Adding age_group column in the table
alter table customer_shopping_behavior add column age_group VARCHAR(30);

-- inserting value in the age_group column
with age_bins as (
	select customer_id,
	ntile(4) over (order by age) as quartile
	from customer_shopping_behavior
)
update customer_shopping_behavior main_table
set age_group = case sub_table.quartile
when 1 then 'Young Adult'
when 2 then 'Adult'
when 3 then 'Middle-aged'
when 4 then 'Senior'
end
from age_bins sub_table
where main_table.customer_id = sub_table.customer_id;

select age, age_group from customer_shopping_behavior limit 5;



-- Adding frequency_purchase_days column in the table

alter table customer_shopping_behavior add column frequency_purchase_days INT;


-- inserting value in the frequency_purchase_days column
update customer_shopping_behavior
set frequency_purchase_days = case frequency_of_purchases
when 'Fortnightly' then 14
when 'Weekly' then 7
when 'Monthly' then 30
when 'Quarterly' then 90
when 'Bi-Weekly' then 14
when 'Annually' then 365
when 'Every 3 Months' then 90
end;

select frequency_of_purchases, frequency_purchase_days from customer_shopping_behavior;

-- removing promo_code_used column bcause both the discount_applied and promo_code_used have the same values
-- it save the memory space while analysis

select promo_code_used, discount_applied from customer_shopping_behavior limit 5;

alter table customer_shopping_behavior drop column promo_code_used;

