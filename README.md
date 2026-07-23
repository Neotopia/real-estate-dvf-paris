# BigQuery SQL – Fintech Analytics

SQL queries on simulated financial data, written and commented in English.  
Project built as part of an upskilling path toward **Data Analyst / Analytics Engineer** roles.

**Stack:** Google BigQuery · Standard SQL · Window Functions

---

## Repo structure

```
bigquery-sql-fintech/
└── sql/
    ├── 01_dataset_transactions.sql   → Dataset creation (inline, no table)
    ├── 02_window_functions_bases.sql → Enrich the table using Window functions
    ├── 03_aggregations_analysis.sql  → GROUP BY, HAVING, subqueries, and CTEs
```

---

## How to use these queries

1. Open [BigQuery Sandbox](https://console.cloud.google.com/bigquery)
2. Create a new project if needed
3. Copy-paste the dataset from `01_dataset_transactions.sql` into the BigQuery editor. This makes the queries self-contained (the data is defined directly in `WITH` CTEs, no table to create or import)
4. In the same editor, paste the query you want from `02_window_functions_bases.sql` **below** the WITH block from file 01
5. Click **Run**

---

## Concepts covered

| File | SQL functions |
|------|--------------|
| `01_dataset_transactions.sql` | 50 fictional transactions for 5 clients, 3 months, fintech theme (salary, rent, leisure...) — self-contained, no table to create |
| `02_window_functions_bases.sql` | Sorting and enriching the transaction table with window functions |
| `03_aggregations_analysis.sql` | GROUP BY, HAVING, subqueries, and chained CTEs for behavioral analysis |

---

## Author

**Lisa Momas** – Digital Analytics & Data  
[LinkedIn](https://www.linkedin.com/in/lisa-momas)
