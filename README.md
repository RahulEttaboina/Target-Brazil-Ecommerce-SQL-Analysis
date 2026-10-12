# Target Brazil E-Commerce SQL Analysis

A business-oriented SQL analysis of the Target Brazil E-Commerce dataset using **Google BigQuery**. This project explores order trends, customer geography, payment values, freight costs, delivery performance, and payment behavior, then translates the results into practical recommendations.

## Project Objectives

The analysis addresses six areas:

1. **Initial exploration** — customer table schema, order date range, and cities/states represented among customers who placed orders.
2. **Order trends** — yearly order counts, monthly order distribution, and order placement by time of day.
3. **Regional patterns** — month-on-month orders by state and customer-record distribution by state.
4. **Payment value and freight** — January–August payment-value comparison for 2017 and 2018, plus state-level order payment value and freight.
5. **Delivery performance** — delivery duration, actual-versus-estimated delivery dates, and state-level freight/delivery comparisons.
6. **Payment behavior** — monthly orders by payment type and order counts by installment count.

## Tools and SQL Skills

- Google BigQuery
- SQL joins and subqueries
- Common Table Expressions (CTEs)
- Aggregations (`COUNT`, `SUM`, `AVG`)
- Date functions (`DATE_DIFF`, `DATE_TRUNC`, `EXTRACT`)
- Conditional logic with `CASE`
- Ranking and sorting
- Data validation and business interpretation

## Dataset and Tables

The analysis uses these tables in the BigQuery dataset `Target_sql`:

- `customers`
- `orders`
- `order_items`
- `payments`

The queries reference the project path `sql-scaler-390716.Target_sql`. Access to the underlying BigQuery dataset may be required to reproduce the results.

## Selected Findings

The following figures are from the query outputs documented for this project. They should be interpreted with the limitations listed below.

### Order volume

| Year | Orders |
|---:|---:|
| 2016 | 329 |
| 2017 | 45,101 |
| 2018 | 54,011 |

The dataset spans **September 4, 2016 to October 17, 2018**. Because 2016 and 2018 are partial years, annual totals should not be compared as if each year were complete. A fair year-over-year comparison should use matching months.

### Payment value: January–August comparison

| Period | Total payment value |
|---|---:|
| Jan–Aug 2017 | R$ 3,669,022.12 |
| Jan–Aug 2018 | R$ 8,694,733.84 |

The documented comparison shows an increase of **136.96%** (approximately **R$ 5.03 million**) from January–August 2017 to January–August 2018. This is payment value, not necessarily recognized net revenue; payment records and accounting treatment should be checked before interpreting it as revenue growth.

### Customer records by state

The customer table query returned **95,418 customer records across 27 states**. São Paulo (SP) had the most records (**41,746**), followed by Rio de Janeiro (RJ; **12,852**) and Minas Gerais (MG; **11,635**). These are `customer_id` records in the customer table, not necessarily counts of unique individuals or only customers who placed orders.

### Freight and delivery

- Average freight per order ranged from **R$ 17.37 in SP** among the five lowest-average states to **R$ 48.59 in RR** among the five highest-average states.
- Average delivery time ranged from **8.70 days in SP** among the five fastest states to **29.34 days in RR** among the five slowest states.
- The five states with the most negative average difference between actual and estimated delivery dates were AC (**−20.72 days**), RO (**−20.10**), AP (**−19.69**), AM (**−19.57**), and RR (**−17.29**). Negative values mean delivery occurred earlier than estimated on average.

These differences identify areas for further investigation; they do not, by themselves, establish why costs or delivery times differ.

### Order placement and payments

- Afternoon (13:00–18:59) was the busiest time-of-day category in the query output, with **38,135 orders**.
- One installment was the most common installment count, with **49,060 orders**.
- The monthly payment-type output showed credit card as the most frequently represented payment type in the rows reviewed. Verify the full result set and the source definition of any unusual labels, such as `UPI`, before drawing a final conclusion.

## Business Recommendations

1. **Investigate regional delivery delays.** Review carrier performance, dispatch timing, distance, and last-mile coverage in states with longer average delivery times.
2. **Review high-freight regions.** Compare carrier rates, shipment distances, parcel characteristics, and order volumes before considering negotiated rates or regional fulfillment changes.
3. **Validate payment-value growth.** Separate the impact of order volume and average order value, and confirm how payment records, refunds, and cancellations are represented.
4. **Improve delivery estimates.** Compare promised and actual delivery dates by state and carrier; use findings to improve the accuracy of customer-facing estimates.
5. **Plan for demand patterns.** Use comparable periods across years before making seasonal inventory or staffing decisions.
6. **Use payment preferences carefully.** Keep checkout reliable for commonly used methods and assess installment behavior alongside order value and conversion data before changing payment options.

## Important Limitations

- The available order data covers partial calendar years at the beginning and end of the period.
- Calendar-month totals aggregated across years are not a chronological month-on-month trend and may be affected by uneven month coverage.
- Customer-table `customer_id` counts represent records/IDs, not necessarily distinct people.
- Payment value should not automatically be described as net revenue.
- State-level averages can be influenced by outliers and differences in distance, shipment size, or order mix.
- The query outputs describe patterns; additional analysis is needed to establish causes.
- The documented payment-type label `UPI` and the two orders with zero installments should be checked against the source data before final interpretation.

## Repository Structure

Update the filenames below to match the files actually committed to this repository.

```text
Target-Brazil-Ecommerce-SQL-Analysis/
├── README.md
├── Target_SQL_Analysis.sql
├── Target_Brazil_Ecommerce_SQL_Analysis.pdf
├── Images/
└── Dataset/   # Include only if redistribution is permitted and file size is suitable
```

If you use different filenames in your repository, update this section so the links and structure remain accurate. Do not commit large raw data files unless their license/terms permit redistribution; linking to the original source is often preferable.

## How to Use

1. Open `Target_SQL_Analysis.sql` in an SQL editor or BigQuery.
2. Run each query section separately against a dataset you are authorized to access.
3. Compare the results with the documented outputs and investigate any differences.
4. Use the results and limitations above as a starting point for deeper analysis.

**Reproducibility note:** The figures in this README are based on the results documented during the project. The complete SQL script should be run against the available dataset to independently reproduce and validate them.

## Future Enhancements

- Build a Power BI or Tableau dashboard for order, payment, freight, and delivery KPIs.
- Add state-level visual comparisons and year-over-year metrics using matching periods.
- Investigate delivery outliers and carrier-level performance if the necessary fields are available.
- Add automated data-quality checks for missing dates, unusual installment counts, and unexpected payment labels.

## Author

**Rahul Ettaboina**  
Data Analyst | SQL | Python | Power BI | Tableau

[LinkedIn](https://www.linkedin.com/in/rahul-ettaboina-5b259122a/)
