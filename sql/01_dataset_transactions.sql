-- ============================================================
-- FILE 01: Simulated dataset – Banking transactions
-- ============================================================
-- Description: Creates a fictional financial transactions dataset
--              representing the movements of 5 clients over 6 months.
--              Used as the source in all other files.
--
-- Columns:
--   transaction_id    → unique transaction identifier
--   client_id         → client identifier (C001 to C005)
--   transaction_date  → transaction date
--   amount            → amount in euros (positive = credit, negative = debit)
--   transaction_type  → incoming_transfer, card_payment, withdrawal, outgoing_transfer
--   category          → salary, rent, groceries, transport, leisure, subscription
-- ============================================================

-- This CTE (Common Table Expression) defines the data directly in the query.
-- No need to create a real table – you can copy-paste and run it immediately.

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

-- Displays all transactions to check the dataset
SELECT *
FROM transactions
ORDER BY client_id, transaction_date;

-- ✅ Expected result: 50 rows, 5 clients, transactions from January to March 2024
-- 💡 This "transactions" CTE will be reused in files 02 and 03 as the base dataset
