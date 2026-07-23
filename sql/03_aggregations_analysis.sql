-- ============================================================
-- FILE 03: Aggregations & Behavioral analysis
-- ============================================================
-- Dataset: fictional banking transactions (5 clients, 3 months) (CTE)
-- Objective: use GROUP BY, HAVING, subqueries, and CTEs to
--            answer concrete business questions.
--
-- Concepts covered:
--   GROUP BY (simple, multi-column, ROLLUP)
--   Aggregate functions: SUM, AVG, COUNT, MAX, MIN
--   HAVING — filtering on aggregates
--   Scalar subqueries and chained CTEs
--   Calculated rates and ratios (% of budget, savings rate)
--
-- 💡 To run: copy the "transactions" CTE from file 01,
--    then paste ONE query at a time below it and click Run.
-- ============================================================

WITH transactions AS (
  SELECT 'TXN001' AS transaction_id, 'C001' AS client_id, DATE '2024-01-05' AS transaction_date,  2800.00 AS amount, 'incoming_transfer' AS transaction_type, 'salary'       AS category UNION ALL
  SELECT 'TXN002', 'C001', DATE '2024-01-07',  -950.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN003', 'C001', DATE '2024-01-12',   -85.40, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN004', 'C001', DATE '2024-01-18',   -42.00, 'card_payment',      'transport'     UNION ALL
  SELECT 'TXN005', 'C001', DATE '2024-01-25',  -120.00, 'card_payment',      'leisure'       UNION ALL
  SELECT 'TXN006', 'C001', DATE '2024-02-05',  2800.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN007', 'C001', DATE '2024-02-08',  -950.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN008', 'C001', DATE '2024-02-14',   -67.20, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN009', 'C001', DATE '2024-02-20',   -35.90, 'card_payment',      'subscription'  UNION ALL
  SELECT 'TXN010', 'C001', DATE '2024-03-05',  2800.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN011', 'C002', DATE '2024-01-03',  3500.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN012', 'C002', DATE '2024-01-06', -1200.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN013', 'C002', DATE '2024-01-10',  -210.50, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN014', 'C002', DATE '2024-01-15',  -580.00, 'card_payment',      'leisure'       UNION ALL
  SELECT 'TXN015', 'C002', DATE '2024-01-22',   -89.00, 'card_payment',      'transport'     UNION ALL
  SELECT 'TXN016', 'C002', DATE '2024-02-03',  3500.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN017', 'C002', DATE '2024-02-09', -1200.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN018', 'C002', DATE '2024-02-16',  -145.00, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN019', 'C002', DATE '2024-03-03',  3500.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN020', 'C002', DATE '2024-03-07', -1200.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN021', 'C003', DATE '2024-01-02',  1800.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN022', 'C003', DATE '2024-01-05',  -700.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN023', 'C003', DATE '2024-01-11',   -55.30, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN024', 'C003', DATE '2024-01-19',  -200.00, 'withdrawal',        'leisure'       UNION ALL
  SELECT 'TXN025', 'C003', DATE '2024-02-02',  1800.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN026', 'C003', DATE '2024-02-06',  -700.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN027', 'C003', DATE '2024-02-13',   -48.90, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN028', 'C003', DATE '2024-02-21',   -25.00, 'card_payment',      'subscription'  UNION ALL
  SELECT 'TXN029', 'C003', DATE '2024-03-02',  1800.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN030', 'C003', DATE '2024-03-10',  -300.00, 'card_payment',      'leisure'       UNION ALL
  SELECT 'TXN031', 'C004', DATE '2024-01-04',  4200.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN032', 'C004', DATE '2024-01-08', -1500.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN033', 'C004', DATE '2024-01-13',  -320.00, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN034', 'C004', DATE '2024-01-20',  -850.00, 'card_payment',      'leisure'       UNION ALL
  SELECT 'TXN035', 'C004', DATE '2024-01-28',  -200.00, 'card_payment',      'transport'     UNION ALL
  SELECT 'TXN036', 'C004', DATE '2024-02-04',  4200.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN037', 'C004', DATE '2024-02-10', -1500.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN038', 'C004', DATE '2024-02-17',  -410.00, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN039', 'C004', DATE '2024-02-24',  -980.00, 'card_payment',      'leisure'       UNION ALL
  SELECT 'TXN040', 'C004', DATE '2024-03-04',  4200.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN041', 'C005', DATE '2024-01-06',  2200.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN042', 'C005', DATE '2024-01-09',  -800.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN043', 'C005', DATE '2024-01-14',   -92.10, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN044', 'C005', DATE '2024-01-23',   -55.00, 'card_payment',      'subscription'  UNION ALL
  SELECT 'TXN045', 'C005', DATE '2024-02-06',  2200.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN046', 'C005', DATE '2024-02-10',  -800.00, 'outgoing_transfer', 'rent'          UNION ALL
  SELECT 'TXN047', 'C005', DATE '2024-02-18',  -110.40, 'card_payment',      'groceries'     UNION ALL
  SELECT 'TXN048', 'C005', DATE '2024-02-25',  -480.00, 'card_payment',      'leisure'       UNION ALL
  SELECT 'TXN049', 'C005', DATE '2024-03-06',  2200.00, 'incoming_transfer', 'salary'        UNION ALL
  SELECT 'TXN050', 'C005', DATE '2024-03-12',  -800.00, 'outgoing_transfer', 'rent'
)


-- ─────────────────────────────────────────────────────────────
-- QUERY 1: Total spending by category (all expenses combined)
-- ─────────────────────────────────────────────────────────────
-- Business question: where does clients' money go, overall?
-- Technique: simple GROUP BY + SUM + filter on negative amount (= expenses)

SELECT
  category,
  COUNT(*)                        AS nb_transactions,
  ROUND(SUM(ABS(amount)), 2)      AS total_spending,
  ROUND(AVG(ABS(amount)), 2)      AS avg_spending,
  ROUND(MAX(ABS(amount)), 2)      AS max_spending
FROM transactions
WHERE amount < 0
GROUP BY category
ORDER BY total_spending DESC;

-- ✅ Expected result: 6 spending categories, rent at the top


-- ─────────────────────────────────────────────────────────────
-- QUERY 2: Financial profile per client
-- ─────────────────────────────────────────────────────────────
-- Business question: who are the biggest spenders?
--                    What is their apparent savings rate?
-- Technique: GROUP BY + conditional aggregation (CASE WHEN inside SUM)

SELECT
  client_id,
  COUNT(*)                                                        AS nb_transactions,
  ROUND(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 2)     AS total_inflows,
  ROUND(SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END), 2) AS total_outflows,
  ROUND(SUM(amount), 2)                                           AS net_balance,
  ROUND(
    SUM(amount) / NULLIF(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 0) * 100,
    1
  )                                                               AS savings_rate_pct
FROM transactions
GROUP BY client_id
ORDER BY net_balance DESC;

-- ✅ Expected result: 5 clients, a positive savings rate = a client who is saving money
-- 💡 NULLIF avoids division by zero if a client has no inflows


-- ─────────────────────────────────────────────────────────────
-- QUERY 3: Spending by client and category
-- ─────────────────────────────────────────────────────────────
-- Business question: which category weighs most in each client's budget?
-- Technique: multi-column GROUP BY

SELECT
  client_id,
  category,
  COUNT(*)                        AS nb_transactions,
  ROUND(SUM(ABS(amount)), 2)      AS total_spending
FROM transactions
WHERE amount < 0
GROUP BY client_id, category
ORDER BY client_id, total_spending DESC;

-- ✅ Expected result: ~20 rows — rent dominant for each client


-- ─────────────────────────────────────────────────────────────
-- QUERY 4: HAVING — clients with leisure spending > €500
-- ─────────────────────────────────────────────────────────────
-- Business question: target clients with a high leisure budget
--                     (premium profile, loyalty programs, targeted offers)
-- Technique: HAVING to filter on an aggregate (≠ WHERE, which filters row by row)

SELECT
  client_id,
  ROUND(SUM(ABS(amount)), 2) AS leisure_spending
FROM transactions
WHERE amount < 0
  AND category = 'leisure'
GROUP BY client_id
HAVING SUM(ABS(amount)) > 500
ORDER BY leisure_spending DESC;

-- ✅ Expected result: clients C002 and C004 (big leisure budgets)
-- 💡 HAVING is applied AFTER GROUP BY — WHERE cannot filter on SUM()


-- ─────────────────────────────────────────────────────────────
-- QUERY 5: Monthly spending trend per client
-- ─────────────────────────────────────────────────────────────
-- Business question: is spending increasing or decreasing each month?
-- Technique: FORMAT_DATE to extract the month + multi-column GROUP BY

SELECT
  client_id,
  FORMAT_DATE('%Y-%m', transaction_date)  AS month,
  COUNT(*)                                AS nb_transactions,
  ROUND(SUM(ABS(amount)), 2)              AS total_spending
FROM transactions
WHERE amount < 0
GROUP BY client_id, month
ORDER BY client_id, month;

-- ✅ Expected result: 3 months x 5 clients = ~15 rows


-- ─────────────────────────────────────────────────────────────
-- QUERY 6: Subquery — transactions above the client's average spending
-- ─────────────────────────────────────────────────────────────
-- Business question: detect unusually high spending for each client
--                     (fraud signals or atypical behavior)
-- Technique: join on a subquery vs correlated subquery in WHERE

SELECT
  t.client_id,
  t.transaction_id,
  t.transaction_date,
  t.category,
  t.amount,
  ROUND(avg_client.avg_spending, 2) AS client_avg_spending
FROM transactions t
JOIN (
  SELECT
    client_id,
    AVG(ABS(amount)) AS avg_spending
  FROM transactions
  WHERE amount < 0
  GROUP BY client_id
) AS avg_client
  ON t.client_id = avg_client.client_id
WHERE t.amount < 0
  AND ABS(t.amount) > avg_client.avg_spending
ORDER BY t.client_id, ABS(t.amount) DESC;

-- ✅ Expected result: transactions whose amount exceeds the client's average
-- 💡 Joining on a subquery is more readable than a correlated subquery in WHERE


-- ─────────────────────────────────────────────────────────────
-- QUERY 7: Chained CTEs — budget vs actual spending summary
-- ─────────────────────────────────────────────────────────────
-- Business question: a synthetic view for each client:
--                     income, fixed spending (rent), variable spending, net savings
-- Technique: 3 chained CTEs + final join

WITH income AS (
  SELECT client_id, ROUND(SUM(amount), 2) AS total_income
  FROM transactions
  WHERE amount > 0
  GROUP BY client_id
),

fixed_expenses AS (
  SELECT client_id, ROUND(SUM(ABS(amount)), 2) AS fixed_costs
  FROM transactions
  WHERE amount < 0 AND category = 'rent'
  GROUP BY client_id
),

variable_expenses AS (
  SELECT client_id, ROUND(SUM(ABS(amount)), 2) AS variable_costs
  FROM transactions
  WHERE amount < 0 AND category != 'rent'
  GROUP BY client_id
)

SELECT
  r.client_id,
  r.total_income,
  fe.fixed_costs,
  ve.variable_costs,
  ROUND(r.total_income - fe.fixed_costs - ve.variable_costs, 2)  AS net_savings,
  ROUND(fe.fixed_costs / r.total_income * 100, 1)                 AS pct_rent,
  ROUND(ve.variable_costs / r.total_income * 100, 1)              AS pct_variable
FROM income r
LEFT JOIN fixed_expenses    fe ON r.client_id = fe.client_id
LEFT JOIN variable_expenses ve ON r.client_id = ve.client_id
ORDER BY net_savings DESC;

-- ✅ Expected result: 5 rows — C004 should have the highest net savings (high income)
-- 💡 CTEs make the logic readable step by step, ideal for documentation
