-- ============================================================
-- Staging model: stg_dvf_mutations
-- ============================================================
-- Cleans the raw DVF export: keeps only real residential sales with a
-- valid price and surface, renames columns to clear English names, and
-- casts types. This is the equivalent of a "clean.py" step, but written
-- as a SQL transformation that dbt runs and tests automatically.
-- ============================================================

with source as (

    select * from {{ source('dvf_raw', 'raw_mutations_idf') }}

),

renamed as (

    select
        id_mutation                    as mutation_id,
        safe_cast(date_mutation as date)        as sale_date,
        nature_mutation                as mutation_nature,
        safe_cast(valeur_fonciere as float64)    as sale_price,
        adresse_numero                 as street_number,
        adresse_nom_voie                as street_name,
        code_postal                    as postal_code,
        code_commune                   as commune_code,
        nom_commune                    as commune_name,
        code_departement                as department_code,
        type_local                     as property_type,
        safe_cast(surface_reelle_bati as float64) as built_surface_m2,
        safe_cast(nombre_pieces_principales as int64) as nb_rooms,
        safe_cast(longitude as float64)          as longitude,
        safe_cast(latitude as float64)           as latitude

    from source

),

filtered as (

    select *
    from renamed
    where
        mutation_nature = 'Vente'
        and property_type in ('Appartement', 'Maison')
        and sale_price > 0
        and built_surface_m2 > 0
        and sale_date is not null

),

deduplicated as (

    -- geo-DVF can repeat the same mutation on multiple lines (one per lot).
    -- Keep a single row per mutation + address + surface combination.
    select
        *,
        row_number() over (
            partition by mutation_id, street_number, street_name, built_surface_m2
            order by sale_date
        ) as row_num
    from filtered

)

select
    mutation_id,
    sale_date,
    extract(year from sale_date) as sale_year,
    mutation_nature,
    sale_price,
    street_number,
    street_name,
    postal_code,
    commune_code,
    commune_name,
    department_code,
    property_type,
    built_surface_m2,
    nb_rooms,
    round(sale_price / nullif(built_surface_m2, 0), 2) as price_per_m2,
    longitude,
    latitude
from deduplicated
where row_num = 1
