-- ============================================================
-- Mart: mart_price_per_m2_by_commune
-- ============================================================
-- Business question: what's the average / median price per m² in
-- each commune (Paris arrondissements + petite couronne cities)?
-- ============================================================

with sales as (

    select * from {{ ref('stg_dvf_mutations') }}

)

select
    department_code,
    commune_code,
    commune_name,
    property_type,
    count(*)                                        as nb_sales,
    round(avg(price_per_m2), 2)                      as avg_price_per_m2,
    round(approx_quantiles(price_per_m2, 100)[offset(50)], 2) as median_price_per_m2,
    round(min(price_per_m2), 2)                      as min_price_per_m2,
    round(max(price_per_m2), 2)                      as max_price_per_m2
from sales
group by 1, 2, 3, 4
order by department_code, avg_price_per_m2 desc
