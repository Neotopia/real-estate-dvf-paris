{#
    Overrides dbt's schema-naming: target "prod" uses the schema as-is,
    any other target gets a "dev_" prefix (isolates local builds).
#}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if target.name == 'prod' -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ ['dev', custom_schema_name | trim] | join('_') }}

    {%- endif -%}

{%- endmacro %}
