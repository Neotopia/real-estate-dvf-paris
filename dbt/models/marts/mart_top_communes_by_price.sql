-- Communes ranked by price per m2 and by sales volume within their department.
-- Filtered to nb_sales >= 20 below to avoid low-volume communes ranking as "most expensive".

with sales as (

    select * from {{ ref('int_dvf_sales_enriched') }}

),

by_commune as (

    select
        department_code,
        commune_code,
        commune_name,
        property_type,
        count(*)                    as nb_sales,
        round(avg(price_per_m2), 2) as avg_price_per_m2
    from sales
    group by 1, 2, 3, 4

),

ranked as (

    select
        *,
        rank() over (
            partition by department_code, property_type
            order by avg_price_per_m2 desc
        ) as price_rank_in_department,
        rank() over (
            partition by department_code, property_type
            order by nb_sales desc
        ) as volume_rank_in_department
    from by_commune

)

select *
from ranked
where nb_sales >= 20
order by department_code, property_type, price_rank_in_department
