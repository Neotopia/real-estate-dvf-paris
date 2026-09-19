-- Price per m2 by zone, property type and surface bucket (studio/T2/T3/T4/T5+).

with sales as (

    select * from {{ ref('int_dvf_sales_enriched') }}

)

select
    zone,
    property_type,
    surface_bucket,
    count(*)                            as nb_sales,
    round(avg(price_per_m2), 2)         as avg_price_per_m2,
    round(avg(sale_price), 2)           as avg_sale_price,
    round(avg(built_surface_m2), 1)     as avg_surface_m2
from sales
group by 1, 2, 3
order by
    zone,
    property_type,
    case surface_bucket
        when 'Studio (< 30 m2)' then 1
        when 'T2 (30-50 m2)' then 2
        when 'T3 (50-70 m2)' then 3
        when 'T4 (70-100 m2)' then 4
        else 5
    end
