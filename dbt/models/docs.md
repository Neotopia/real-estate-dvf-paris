{#
    Shared doc blocks, referenced from model .yml files via
    {{ doc("block_name") }}. Keeps longer descriptions out of YAML
    and makes them reusable/renderable in `dbt docs generate`.
#}

{% docs int_dvf_sales_enriched %}
Business-enriched version of `stg_dvf_mutations`: one row per cleaned
residential sale, with derived columns (`zone`, `surface_bucket`,
`sale_month`, `sale_quarter`) computed once so downstream marts don't
each re-implement the same logic. All marts should build on top of
this model rather than on `stg_dvf_mutations` directly whenever they
need zone or surface-bucket segmentation.
{% enddocs %}

{% docs __overview__ %}
# DVF Paris + petite couronne — dbt project

Transforms raw geo-DVF property-sale data (loaded as-is into BigQuery
by `scripts/download_and_load.py`) into tested, analysis-ready tables
covering Paris and the petite couronne (departments 75, 92, 93, 94).

**Layers**

- `staging` — `stg_dvf_mutations`: cleans, renames, filters to real
  residential sales, deduplicates.
- `intermediate` — `int_dvf_sales_enriched`: adds `zone`,
  `surface_bucket`, `sale_month`, `sale_quarter`.
- `marts` — business-facing aggregated tables (price per m² by
  commune, year-over-year evolution, Paris vs petite couronne, top
  communes, price by surface bucket, seasonality by month).

**Generate this documentation site**

```bash
cd dbt
dbt docs generate
dbt docs serve
```

See the repo's `README.md` for the full setup and run instructions.
{% enddocs %}
