-- ============================================================
-- Mart: mart_paris_vs_petite_couronne
-- ============================================================
-- Business question: how does Paris (75) compare to the petite
-- couronne (92, 93, 94) on price and market activity?
--
-- zone is computed once in int_dvf_sales_enriched (dvf_zone macro)
-- instead of being re-derived here.
-- ============================================================

with sales as (

    select * from {{ ref('int_dvf_sales_enriched') }}

)

select
    zone,
    sale_year,
    property_type,
    count(*)                          as nb_sales,
    round(avg(price_per_m2), 2)       as avg_price_per_m2,
    round(avg(sale_price), 2)         as avg_sale_price,
    round(avg(built_surface_m2), 1)   as avg_surface_m2
from sales
group by 1, 2, 3
order by zone, sale_year, property_type
