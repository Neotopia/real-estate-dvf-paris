-- ============================================================
-- Intermediate model: int_dvf_sales_enriched
-- ============================================================
-- Sits between staging and marts. Adds business-level enrichment
-- columns derived from stg_dvf_mutations, computed ONCE here so
-- marts don't each re-derive the same logic (which is what
-- happened before with the Paris/petite couronne CASE WHEN,
-- duplicated inline in mart_paris_vs_petite_couronne.sql).
--
-- Adds:
--   - zone              : Paris vs Petite couronne (dvf_zone macro)
--   - surface_bucket     : studio / T2 / T3 / T4 / T5+ (dvf_surface_bucket macro)
--   - sale_month         : calendar month of the sale (1-12)
--   - sale_quarter        : calendar quarter of the sale (1-4)
-- ============================================================

with sales as (

    select * from {{ ref('stg_dvf_mutations') }}

)

select
    *,
    {{ dvf_zone('department_code') }} as zone,
    {{ dvf_surface_bucket('built_surface_m2') }} as surface_bucket,
    extract(month from sale_date) as sale_month,
    extract(quarter from sale_date) as sale_quarter
from sales
