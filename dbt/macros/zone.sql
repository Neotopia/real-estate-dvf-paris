{#
    Maps department_code to zone label: 'Paris' (75) or 'Petite couronne' (else).
    Usage: {{ dvf_zone('department_code') }} as zone
#}

{% macro dvf_zone(department_code_column) %}
    case
        when {{ department_code_column }} = '75' then 'Paris'
        else 'Petite couronne'
    end
{% endmacro %}
