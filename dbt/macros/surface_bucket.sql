{#
    Buckets a built surface (m²) column into studio/T2/T3/T4/T5+ categories.
    Usage: {{ dvf_surface_bucket('built_surface_m2') }} as surface_bucket
#}

{% macro dvf_surface_bucket(surface_column) %}
    case
        when {{ surface_column }} < 30 then 'Studio (< 30 m2)'
        when {{ surface_column }} < 50 then 'T2 (30-50 m2)'
        when {{ surface_column }} < 70 then 'T3 (50-70 m2)'
        when {{ surface_column }} < 100 then 'T4 (70-100 m2)'
        else 'T5+ (100 m2+)'
    end
{% endmacro %}
