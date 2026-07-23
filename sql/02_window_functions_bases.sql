-- ============================================================
-- FILE 02: Window Functions – The basics
-- ============================================================
-- Dataset: fictional banking transactions (5 clients, 3 months) (CTE)
-- Objective: use window functions on concrete financial use cases.
--
-- 💡 To run: copy ONE query at a time into BigQuery,
--    starting from the "transactions" CTE available in file 01_dataset_transactions.sql
--    down to the final SELECT available in this file.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Enrich each client's banking transaction data using window functions
-- ─────────────────────────────────────────────────────────────
-- Use case:
--    - Sort and count each client's transactions to study their spending behavior
--    - Identify each client's first and last transaction date to study relationship duration
--    - Running balance at the time of each transaction to detect spending spikes
--    - Client spending rhythm (days between 2 transactions) to detect inactive clients or behavior changes




SELECT
  client_id,
  transaction_id,
  transaction_date,
  amount,

  -- Position of the transaction in the client's history (1 = oldest)
  ROW_NUMBER() OVER w_client AS transaction_number,

  -- Total number of known transactions for this client
  COUNT(*) OVER w_client_total AS nb_transactions,

  -- First and last transaction dates
  MIN(transaction_date) OVER w_client_total AS first_transaction_date,
  MAX(transaction_date) OVER w_client_total AS last_transaction_date,

  -- Running balance transaction by transaction, to detect spending spikes
  ROUND(SUM(amount) OVER w_balance, 2) AS running_balance,

  -- Amount of the same client's previous transaction (to detect jumps)
  LAG(amount) OVER w_client AS previous_amount,

  -- Days elapsed since the previous transaction (spending rhythm)
  DATE_DIFF(
    transaction_date,
    LAG(transaction_date) OVER w_client,
    DAY
  ) AS days_since_previous_txn

FROM transactions

WINDOW
  w_client       AS (PARTITION BY client_id ORDER BY transaction_date ASC),
  w_client_total AS (PARTITION BY client_id),
  w_balance      AS (PARTITION BY client_id ORDER BY transaction_date ASC
                     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)

ORDER BY client_id, transaction_date;
