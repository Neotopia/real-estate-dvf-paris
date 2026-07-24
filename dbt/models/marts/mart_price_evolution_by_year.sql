-- ============================================================
-- Mart: mart_price_evolution_by_year
-- ============================================================
-- Business question: is the price per m² rising or falling year
-- over year, by department?
-- ============================================================

with sales as (

    select * from {{ ref('stg_dvf_mutations') }}

),

by_year as (

    select
        department_code,
        sale_year,
        property_type,
        count(*)                    as nb_sales,
        round(avg(price_per_m2), 2) as avg_price_per_m2
    from sales
    group by 1, 2, 3

)

select
    *,
    round(
        avg_price_per_m2 - lag(avg_price_per_m2) over (
            partition by department_code, property_type
            order by sale_year
        ),
        2
    ) as price_change_vs_previous_year,
    round(
        (avg_price_per_m2 / nullif(lag(avg_price_per_m2) over (
            partition by department_code, property_type
            order by sale_year
        ), 0) - 1) * 100,
        1
    ) as price_change_pct_vs_previous_year
from by_year
order by department_code, property_type, sale_year
