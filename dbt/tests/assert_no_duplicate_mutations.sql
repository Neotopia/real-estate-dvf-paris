-- ============================================================
-- Singular test: assert_no_duplicate_mutations
-- ============================================================
-- Fails if the same mutation_id + address + surface combination
-- appears more than once in the staging model — a regression check
-- on the deduplication logic in stg_dvf_mutations.sql.
-- ============================================================

select
    mutation_id,
    street_number,
    street_name,
    built_surface_m2,
    count(*) as nb_rows
from {{ ref('stg_dvf_mutations') }}
group by 1, 2, 3, 4
having count(*) > 1
