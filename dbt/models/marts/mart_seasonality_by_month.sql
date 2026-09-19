-- Sales volume and price per m2 by calendar month, aggregated across all years in scope
-- to avoid single-year noise.

with sales as (

    select * from {{ ref('int_dvf_sales_enriched') }}

),

by_month as (

    select
        department_code,
        property_type,
        sale_month,
        count(*)                    as nb_sales,
        round(avg(price_per_m2), 2) as avg_price_per_m2
    from sales
    group by 1, 2, 3

)

select
    *,
    round(
        100.0 * nb_sales / sum(nb_sales) over (
            partition by department_code, property_type
        ),
        1
    ) as pct_of_annual_sales
from by_month
order by department_code, property_type, sale_month
