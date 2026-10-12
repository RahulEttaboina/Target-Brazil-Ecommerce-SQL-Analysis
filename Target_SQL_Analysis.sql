/*
Project: Target Brazil E-Commerce SQL Analysis
Platform: Google BigQuery
Dataset: `sql-scaler-390716.Target_sql`

Purpose:
Answer the six sections of the Target Brazil E-Commerce case study.
Run each numbered query separately in BigQuery.

Important interpretation notes:
- The order dataset spans partial calendar years; compare equivalent date ranges when measuring growth.
- Q3(b) counts customer_id records in the customers table, not necessarily unique people or only customers who ordered.
- Q4(b) aggregates payment rows to order level before calculating state-level totals and averages.
- Q4(c) aggregates item freight to order level before calculating state-level totals and averages.
- Q5(a) and Q5(d) use actual delivery date minus estimated delivery date: positive = late, negative = early, zero = on estimate.
- Q6(a) counts distinct orders within each payment type. An order may appear in more than one payment type if it has multiple payment records.
*/

-- ============================================================
-- 1. INITIAL EXPLORATION
-- ============================================================

-- Q1(a): Data types of all columns in the customers table
SELECT
  column_name,
  data_type
FROM `sql-scaler-390716.Target_sql.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'customers'
ORDER BY ordinal_position;

-- Q1(b): First and last order purchase timestamps and span in days
SELECT
  MIN(order_purchase_timestamp) AS first_order_timestamp,
  MAX(order_purchase_timestamp) AS last_order_timestamp,
  DATE_DIFF(
    DATE(MAX(order_purchase_timestamp)),
    DATE(MIN(order_purchase_timestamp)),
    DAY
  ) AS span_days
FROM `sql-scaler-390716.Target_sql.orders`
WHERE order_purchase_timestamp IS NOT NULL;

-- Q1(c): Distinct cities and states among customers who placed orders
SELECT
  COUNT(DISTINCT c.customer_city) AS unique_cities,
  COUNT(DISTINCT c.customer_state) AS unique_states
FROM `sql-scaler-390716.Target_sql.customers` AS c
WHERE c.customer_id IN (
  SELECT o.customer_id
  FROM `sql-scaler-390716.Target_sql.orders` AS o
  WHERE o.customer_id IS NOT NULL
);

-- ============================================================
-- 2. IN-DEPTH ORDER EXPLORATION
-- ============================================================

-- Q2(a): Number of orders by year
SELECT
  EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
  COUNT(*) AS total_orders
FROM `sql-scaler-390716.Target_sql.orders`
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY order_year
ORDER BY order_year;

-- Q2(b): Orders aggregated by calendar month across all available years
-- Note: this groups January from every year together, etc.; it is not chronological MoM.
SELECT
  EXTRACT(MONTH FROM order_purchase_timestamp) AS order_month,
  COUNT(*) AS total_orders
FROM `sql-scaler-390716.Target_sql.orders`
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY order_month
ORDER BY order_month;

-- Q2(c): Orders by time of day
-- Definitions: Dawn 00-06, Morning 07-12, Afternoon 13-18, Night 19-23.
SELECT
  CASE
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
  END AS time_of_day,
  COUNT(*) AS total_orders
FROM `sql-scaler-390716.Target_sql.orders`
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY time_of_day
ORDER BY
  CASE time_of_day
    WHEN 'Dawn' THEN 1
    WHEN 'Morning' THEN 2
    WHEN 'Afternoon' THEN 3
    WHEN 'Night' THEN 4
  END;

-- ============================================================
-- 3. STATE-LEVEL ORDER AND CUSTOMER DISTRIBUTION
-- ============================================================

-- Q3(a): Chronological month-on-month order count for each customer state
SELECT
  c.customer_state,
  DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `sql-scaler-390716.Target_sql.orders` AS o
JOIN `sql-scaler-390716.Target_sql.customers` AS c
  ON o.customer_id = c.customer_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY c.customer_state, order_month
ORDER BY c.customer_state, order_month;

-- Q3(b): Customer records by state (customer_id count)
SELECT
  customer_state,
  COUNT(DISTINCT customer_id) AS total_customer_records
FROM `sql-scaler-390716.Target_sql.customers`
GROUP BY customer_state
ORDER BY total_customer_records DESC;

-- ============================================================
-- 4. PAYMENT VALUE AND FREIGHT BY STATE
-- ============================================================

-- Q4(a): Jan-Aug payment value in 2017 vs Jan-Aug 2018 and percentage increase
WITH yearly_payments AS (
  SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    SUM(p.payment_value) AS total_payment_value
  FROM `sql-scaler-390716.Target_sql.orders` AS o
  JOIN `sql-scaler-390716.Target_sql.payments` AS p
    ON o.order_id = p.order_id
  WHERE EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
    AND EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
  GROUP BY order_year
),
pivoted AS (
  SELECT
    MAX(IF(order_year = 2017, total_payment_value, NULL)) AS payment_2017_jan_aug,
    MAX(IF(order_year = 2018, total_payment_value, NULL)) AS payment_2018_jan_aug
  FROM yearly_payments
)
SELECT
  ROUND(payment_2017_jan_aug, 2) AS payment_2017_jan_aug,
  ROUND(payment_2018_jan_aug, 2) AS payment_2018_jan_aug,
  ROUND(payment_2018_jan_aug - payment_2017_jan_aug, 2) AS absolute_increase,
  ROUND(SAFE_DIVIDE(payment_2018_jan_aug - payment_2017_jan_aug,
                    payment_2017_jan_aug) * 100, 2) AS percentage_increase
FROM pivoted;

-- Q4(b): Total payment value and average order payment value by state
-- Payments are summed per order first to avoid averaging individual payment rows.
WITH order_payments AS (
  SELECT
    order_id,
    SUM(payment_value) AS order_payment_value
  FROM `sql-scaler-390716.Target_sql.payments`
  GROUP BY order_id
), order_state_values AS (
  SELECT
    c.customer_state,
    o.order_id,
    op.order_payment_value
  FROM `sql-scaler-390716.Target_sql.orders` AS o
  JOIN `sql-scaler-390716.Target_sql.customers` AS c
    ON o.customer_id = c.customer_id
  JOIN order_payments AS op
    ON o.order_id = op.order_id
)
SELECT
  customer_state,
  ROUND(SUM(order_payment_value), 2) AS total_payment_value,
  ROUND(AVG(order_payment_value), 2) AS average_order_payment_value
FROM order_state_values
GROUP BY customer_state
ORDER BY total_payment_value DESC;

-- Q4(c): Total freight and average freight per order by state
WITH order_freight AS (
  SELECT
    order_id,
    SUM(freight_value) AS order_freight_value
  FROM `sql-scaler-390716.Target_sql.order_items`
  GROUP BY order_id
)
SELECT
  c.customer_state,
  ROUND(SUM(ofr.order_freight_value), 2) AS total_freight_value,
  ROUND(AVG(ofr.order_freight_value), 2) AS average_freight_per_order
FROM `sql-scaler-390716.Target_sql.orders` AS o
JOIN `sql-scaler-390716.Target_sql.customers` AS c
  ON o.customer_id = c.customer_id
JOIN order_freight AS ofr
  ON o.order_id = ofr.order_id
GROUP BY c.customer_state
ORDER BY total_freight_value DESC;

-- ============================================================
-- 5. DELIVERY AND FREIGHT PERFORMANCE
-- ============================================================

-- Q5(a): Delivery days per order and difference from estimated delivery date
-- Positive days_after_estimated_delivery = late; negative = early.
SELECT
  order_id,
  DATE_DIFF(
    DATE(order_delivered_customer_date),
    DATE(order_purchase_timestamp),
    DAY
  ) AS delivery_days,
  DATE_DIFF(
    DATE(order_delivered_customer_date),
    DATE(order_estimated_delivery_date),
    DAY
  ) AS days_after_estimated_delivery
FROM `sql-scaler-390716.Target_sql.orders`
WHERE order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
ORDER BY delivery_days DESC;

-- Q5(b): Five states with highest and lowest average freight per order
WITH order_freight AS (
  SELECT
    order_id,
    SUM(freight_value) AS order_freight_value
  FROM `sql-scaler-390716.Target_sql.order_items`
  GROUP BY order_id
), state_freight AS (
  SELECT
    c.customer_state,
    AVG(ofr.order_freight_value) AS avg_freight_per_order
  FROM `sql-scaler-390716.Target_sql.orders` AS o
  JOIN `sql-scaler-390716.Target_sql.customers` AS c
    ON o.customer_id = c.customer_id
  JOIN order_freight AS ofr
    ON o.order_id = ofr.order_id
  GROUP BY c.customer_state
), ranked AS (
  SELECT
    customer_state,
    ROUND(avg_freight_per_order, 2) AS avg_freight_per_order,
    ROW_NUMBER() OVER (ORDER BY avg_freight_per_order DESC) AS highest_rank,
    ROW_NUMBER() OVER (ORDER BY avg_freight_per_order ASC) AS lowest_rank
  FROM state_freight
)
SELECT
  customer_state,
  avg_freight_per_order,
  CASE
    WHEN highest_rank <= 5 THEN 'Highest average freight'
    WHEN lowest_rank <= 5 THEN 'Lowest average freight'
  END AS freight_group
FROM ranked
WHERE highest_rank <= 5 OR lowest_rank <= 5
ORDER BY
  CASE WHEN highest_rank <= 5 THEN 1 ELSE 2 END,
  CASE WHEN highest_rank <= 5 THEN avg_freight_per_order END DESC,
  CASE WHEN lowest_rank <= 5 THEN avg_freight_per_order END ASC;

-- Q5(c): Five states with highest and lowest average delivery time
WITH state_delivery AS (
  SELECT
    c.customer_state,
    AVG(DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_purchase_timestamp),
      DAY
    )) AS avg_delivery_days
  FROM `sql-scaler-390716.Target_sql.orders` AS o
  JOIN `sql-scaler-390716.Target_sql.customers` AS c
    ON o.customer_id = c.customer_id
  WHERE o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp IS NOT NULL
  GROUP BY c.customer_state
), ranked AS (
  SELECT
    customer_state,
    ROUND(avg_delivery_days, 2) AS avg_delivery_days,
    ROW_NUMBER() OVER (ORDER BY avg_delivery_days DESC) AS highest_rank,
    ROW_NUMBER() OVER (ORDER BY avg_delivery_days ASC) AS lowest_rank
  FROM state_delivery
)
SELECT
  customer_state,
  avg_delivery_days,
  CASE
    WHEN highest_rank <= 5 THEN 'Highest average delivery time'
    WHEN lowest_rank <= 5 THEN 'Lowest average delivery time'
  END AS delivery_group
FROM ranked
WHERE highest_rank <= 5 OR lowest_rank <= 5
ORDER BY
  CASE WHEN highest_rank <= 5 THEN 1 ELSE 2 END,
  CASE WHEN highest_rank <= 5 THEN avg_delivery_days END DESC,
  CASE WHEN lowest_rank <= 5 THEN avg_delivery_days END ASC;

-- Q5(d): Five states delivering earliest relative to estimated date
-- Negative values mean delivery was earlier than estimated.
SELECT
  c.customer_state,
  ROUND(
    AVG(DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_estimated_delivery_date),
      DAY
    )),
    2
  ) AS avg_days_after_estimated_delivery
FROM `sql-scaler-390716.Target_sql.orders` AS o
JOIN `sql-scaler-390716.Target_sql.customers` AS c
  ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_days_after_estimated_delivery ASC
LIMIT 5;

-- ============================================================
-- 6. PAYMENT METHOD AND INSTALLMENTS
-- ============================================================

-- Q6(a): Month-on-month orders by payment type
-- An order may be counted under multiple payment types if it has multiple payment rows.
SELECT
  DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
  p.payment_type,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `sql-scaler-390716.Target_sql.orders` AS o
JOIN `sql-scaler-390716.Target_sql.payments` AS p
  ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY order_month, p.payment_type
ORDER BY order_month, p.payment_type;

-- Q6(b): Number of orders by payment installment count
SELECT
  payment_installments,
  COUNT(DISTINCT order_id) AS total_orders
FROM `sql-scaler-390716.Target_sql.payments`
GROUP BY payment_installments
ORDER BY payment_installments;

/* =====================================================================
   DOCUMENTED RESULTS / ANSWER NOTES
   These notes record the results discussed and verified during the project.
   They are comments only; run the queries above to reproduce results.
   =====================================================================

   Q1(a) - customers schema:
     customer_id STRING
     customer_unique_id STRING
     customer_zip_code_prefix INT64
     customer_city STRING
     customer_state STRING

   Q1(b) - purchase timestamp coverage:
     First purchase: 2016-09-04 21:15:19 UTC
     Last purchase:  2018-10-17 17:30:18 UTC
     Span: 773 days

   Q1(c) - customers who placed orders:
     4,119 cities and 27 states.

   Q2(a) - orders by purchase year:
     2016: 329; 2017: 45,101; 2018: 54,011.
     Caution: the first and last calendar years are partial years, so raw
     annual totals are not a fair like-for-like growth comparison.

   Q2(b) - order totals grouped by calendar month across all years:
     Jan 8,069; Feb 8,508; Mar 9,893; Apr 9,343; May 10,573; Jun 9,412;
     Jul 10,318; Aug 10,843; Sep 4,305; Oct 4,959; Nov 7,544; Dec 5,674.
     This is month-of-year aggregation, not chronological month-on-month growth;
     partial-year coverage affects some months.

   Q2(c) - orders by time of day:
     Dawn 5,242; Morning 27,733; Afternoon 38,135; Night 28,331.

   Q3(a) - monthly orders by state:
     Query produces the full chronological state/month result set. No single
     summary figure was recorded in the project notes.

   Q3(b) - customer_id records by state (top states):
     SP 41,746; RJ 12,852; MG 11,635; RS 5,466; PR 5,045; SC 3,637;
     BA 3,380; DF 2,140; ES 2,033; GO 2,020.
     Total customer_id records: 95,418. These are table records/IDs, not
     necessarily distinct individual people.

   Q4(a) - Jan-Aug payment_value by purchase year:
     2017: R$3,669,022.12; 2018: R$8,694,733.84.
     Difference: R$5,025,711.72; increase: 136.96%.
     Payment value should not automatically be described as net revenue.

   Q4(b) - state payment value / average order payment value (top states):
     SP: R$5,998,226.96 / R$143.69
     RJ: R$2,144,379.69 / R$166.85
     MG: R$1,872,257.26 / R$160.92

   Q4(c) - state freight totals / average freight per order (top totals):
     SP: R$718,723.07 / R$17.37
     RJ: R$305,589.31 / R$23.95
     MG: R$270,853.46 / R$23.46
     Highest average freight states included RR R$48.59, PB R$48.35,
     RO R$46.22, AC R$45.52 and PI R$43.04.

   Q5(a) - delivery performance:
     delivery_days = actual delivery date minus purchase date.
     days_after_estimated_delivery = actual delivery date minus estimated date.
     Positive difference means late; negative means early; zero means on time.
     The longest-duration rows include outliers and should be investigated rather
     than treated as typical delivery performance. One discussed order had
     delivery_days 210 and was 181 days after the estimated delivery date.

   Q5(b) - average freight per order by state:
     Lowest averages included SP R$17.37, MG R$23.46, PR R$23.58,
     DF R$23.82 and RJ R$23.95. See query output for complete rankings.

   Q5(c) - average delivery days by state:
     Highest included RR 29.34 days, AP 27.18, AM 26.36, AL 24.50,
     PA 23.73. Lowest included SP 8.70, PR 11.94, MG 11.95,
     DF 12.90 and SC 14.91.

   Q5(d) - average actual-minus-estimated delivery days (earliest vs estimate):
     AC -20.72; RO -20.10; AP -19.69; AM -19.57; RR -17.29.
     Negative values mean delivery occurred earlier than the estimated date.

   Q6(a) - monthly orders by payment type:
     The query returns monthly counts by payment type. Counts are distinct
     orders within each payment type; an order can appear in multiple types if
     it has multiple payment rows. Credit card was the most frequently
     represented type in the rows reviewed. Verify the full output and source
     definition of unusual labels such as UPI before making final claims.

   Q6(b) - orders by payment installment count:
     0: 2; 1: 49,060; 2: 12,389; 3: 10,443; 4: 7,088; 5: 5,234;
     6: 3,916; 7: 1,623; 8: 4,253; 9: 644; 10: 5,315; 11: 23;
     12: 133; 13: 16; 14: 15; 15: 74; 16: 5; 17: 8; 18: 27;
     20: 17; 21: 3; 22: 1; 23: 1; 24: 18.
     Investigate the two zero-installment records before deciding whether they
     represent data issues.

   Notes:
   - Results above are project notes, not hard-coded query outputs.
   - State averages can be affected by outliers and differences in order mix.
   - This SQL project used customers, orders, order_items, and payments.
     geolocation, order_reviews, products, and sellers were not used in the
     completed case-study questions documented here.
   ===================================================================== */
