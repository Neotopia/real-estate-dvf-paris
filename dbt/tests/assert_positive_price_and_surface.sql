-- ============================================================
-- Singular test: assert_positive_price_and_surface
-- ============================================================
-- A dbt test "passes" when the query returns ZERO rows.
-- This one fails the build if any cleaned mutation has a
-- non-positive price or surface — a regression check on the
-- staging model's filtering logic (should never happen, since
-- stg_dvf_mutations already filters these out; this test exists
-- to catch a future change that accidentally breaks that filter).
-- ============================================================

select *
from {{ ref('stg_dvf_mutations') }}
where sale_price <= 0
   or built_surface_m2 <= 0
