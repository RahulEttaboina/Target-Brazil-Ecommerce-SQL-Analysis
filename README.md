# \# Target Brazil E-Commerce SQL Analysis

# 

# A business-oriented SQL analysis of the Target Brazil E-Commerce dataset using \*\*Google BigQuery\*\*. This project explores order trends, customer geography, payment values, freight costs, delivery performance, and payment behavior, and translates the findings into practical business recommendations.

# 

# \## Project Objectives

# 

# The analysis covers six areas:

# 

# 1\. \*\*Initial Exploration\*\* – Customer table schema, order date range, and the cities and states represented among customers who placed orders.

# 2\. \*\*Order Trends\*\* – Yearly order counts, monthly order distribution, and order placement by time of day.

# 3\. \*\*Regional Patterns\*\* – Month-on-month orders by state and customer-record distribution by state.

# 4\. \*\*Payment Value and Freight\*\* – January–August payment-value comparison for 2017 and 2018, along with state-level payment values and freight costs.

# 5\. \*\*Delivery Performance\*\* – Delivery duration, actual versus estimated delivery dates, and state-level delivery and freight comparisons.

# 6\. \*\*Payment Behavior\*\* – Monthly orders by payment type and order counts by installment count.

# 

# \## Tools and SQL Skills

# 

# \- Google BigQuery

# \- SQL joins and subqueries

# \- Common Table Expressions (CTEs)

# \- Aggregations using `COUNT`, `SUM`, and `AVG`

# \- Date functions such as `DATE\_DIFF`, `DATE\_TRUNC`, and `EXTRACT`

# \- Conditional logic using `CASE`

# \- Grouping, ranking, and sorting

# \- Data validation and business interpretation

# 

# \## Dataset and Tables

# 

# The analysis uses four tables from the `Target\_sql` dataset in Google BigQuery:

# 

# \- `customers`

# \- `orders`

# \- `order\_items`

# \- `payments`

# 

# The queries reference the BigQuery project path `sql-scaler-390716.Target\_sql`. Access to the underlying dataset may be required to reproduce the results.

# 

# \## Key Findings

# 

# \### 1. Order Volume

# 

# | Year | Total Orders |

# |---|---:|

# | 2016 | 329 |

# | 2017 | 45,101 |

# | 2018 | 54,011 |

# 

# The dataset covers the period from \*\*September 4, 2016, to October 17, 2018\*\*.

# 

# Since 2016 and 2018 are partial years, their total order counts should not be directly compared with the full year of 2017. Comparing matching months across years provides a fairer view of order growth.

# 

# \### 2. Payment Value: January–August Comparison

# 

# | Period | Total Payment Value |

# |---|---:|

# | January–August 2017 | R$ 3,669,022.12 |

# | January–August 2018 | R$ 8,694,733.84 |

# 

# The total payment value increased by \*\*136.96%\*\*, representing an increase of approximately \*\*R$ 5.03 million\*\* between January–August 2017 and January–August 2018.

# 

# This figure represents payment value, not necessarily recognized net revenue. Refunds, cancellations, and accounting treatment should be considered before interpreting it as revenue growth.

# 

# \### 3. Customer Distribution by State

# 

# The customer table query returned \*\*95,418 customer records across 27 states\*\*.

# 

# The states with the highest customer-record counts were:

# 

# | State | Customer Records |

# |---|---:|

# | São Paulo (SP) | 41,746 |

# | Rio de Janeiro (RJ) | 12,852 |

# | Minas Gerais (MG) | 11,635 |

# 

# São Paulo had the largest customer-record count by a considerable margin, followed by Rio de Janeiro and Minas Gerais.

# 

# These figures represent `customer\_id` records in the customer table, not necessarily unique individuals or only customers who placed orders.

# 

# \### 4. Freight and Delivery Performance

# 

# The state-level analysis highlighted differences in freight costs and delivery times.

# 

# \- \*\*Average freight:\*\* SP had an average freight value of R$ 17.37 per order among the lowest-average states, while RR had the highest average at R$ 48.59.

# \- \*\*Average delivery time:\*\* SP had one of the shortest average delivery times at 8.70 days, while RR had the longest at 29.34 days.

# \- \*\*Delivery estimate differences:\*\* The states with the most negative average differences between actual and estimated delivery dates were AC (-20.72 days), RO (-20.10 days), AP (-19.69 days), AM (-19.57 days), and RR (-17.29 days).

# 

# Negative differences indicate that orders were delivered earlier than estimated on average.

# 

# These results identify regions for further investigation, but the differences alone do not establish why freight costs or delivery times vary.

# 

# \### 5. Order Placement and Payment Behavior

# 

# \- \*\*Busiest time of day:\*\* Afternoon (13:00–18:59) recorded 38,135 orders in the time-of-day analysis.

# \- \*\*Most common installment count:\*\* One installment was the most common, with 49,060 orders.

# \- \*\*Payment methods:\*\* Credit card was the most frequently represented payment type in the monthly payment-type results reviewed.

# 

# The full payment-type output and unusual labels, such as `UPI`, should be checked against the source data before drawing final conclusions. The two records with zero installments should also be validated rather than automatically treated as errors.

# 

# \## Project Screenshots

# 

# The screenshots below show the SQL queries and their BigQuery outputs.

# 

# \### 1. Initial Exploration

# 

# !\[Initial Exploration](Images/01\_Initial\_Exploration.jpeg)

# 

# \### 2. Order Trends and Monthly Patterns

# 

# \*\*Monthly order patterns – Part 1\*\*

# 

# !\[Monthly Order Patterns Part 1](Images/02\_Monthly\_Order\_Patterns\_Part1.jpeg)

# 

# \*\*Monthly order patterns – Part 2\*\*

# 

# !\[Monthly Order Patterns Part 2](Images/02\_Monthly\_Order\_Patterns\_Part2.jpeg)

# 

# \### 3. Customer Distribution by State

# 

# \*\*Part 1\*\*

# 

# !\[Customer Distribution Part 1](Images/03\_Customer\_Distribution\_Part1.jpeg)

# 

# \*\*Part 2\*\*

# 

# !\[Customer Distribution Part 2](Images/03\_Customer\_Distribution\_Part2.jpeg)

# 

# \*\*Part 3\*\*

# 

# !\[Customer Distribution Part 3](Images/03\_Customer\_Distribution\_Part3.jpeg)

# 

# \### 4. Payment Value and Freight Analysis

# 

# \*\*Part 1\*\*

# 

# !\[Payment Analysis Part 1](Images/04\_Payment\_Analysis\_Part1.jpeg)

# 

# \*\*Part 2\*\*

# 

# !\[Payment Analysis Part 2](Images/04\_Payment\_Analysis\_Part2.jpeg)

# 

# \*\*Part 3\*\*

# 

# !\[Payment Analysis Part 3](Images/04\_Payment\_Analysis\_Part3.jpeg)

# 

# \### 5. Delivery Performance

# 

# \*\*Part 1\*\*

# 

# !\[Delivery Performance Part 1](Images/05\_Delivery\_Performance\_Part1.jpeg)

# 

# \*\*Part 2\*\*

# 

# !\[Delivery Performance Part 2](Images/05\_Delivery\_Performance\_Part2.jpeg)

# 

# \*\*Part 3\*\*

# 

# !\[Delivery Performance Part 3](Images/05\_Delivery\_Performance\_Part3.jpeg)

# 

# \## Business Recommendations

# 

# Based on the findings, the following actions could be explored:

# 

# 1\. \*\*Investigate regional delivery delays:\*\* Review carrier performance, dispatch timing, distance, and last-mile coverage in states with longer delivery times.

# 2\. \*\*Review high-freight regions:\*\* Compare carrier rates, shipment distances, parcel characteristics, and order volumes before considering rate negotiations or regional fulfilment changes.

# 3\. \*\*Validate payment-value growth:\*\* Separate the impact of order volume and average order value, and confirm how payment records, refunds, and cancellations are represented.

# 4\. \*\*Improve delivery estimates:\*\* Compare promised and actual delivery dates by state and carrier to identify opportunities to improve customer-facing delivery estimates.

# 5\. \*\*Plan for demand patterns:\*\* Compare equivalent periods across years before making seasonal inventory or staffing decisions.

# 6\. \*\*Review payment preferences:\*\* Maintain reliable checkout options for commonly used payment methods and assess installment behavior alongside order value and conversion data before changing payment options.

# 

# \## Limitations

# 

# \- The dataset covers partial calendar years at the beginning and end of the analysis period.

# \- Calendar-month totals aggregated across multiple years should not be treated as a chronological month-on-month trend.

# \- Customer-table `customer\_id` counts represent records or IDs, not necessarily distinct people.

# \- Payment value should not automatically be interpreted as net revenue.

# \- State-level averages may be influenced by outliers, shipping distances, parcel sizes, and differences in order mix.

# \- The results identify patterns but do not independently establish their causes.

# \- The `UPI` payment-type label and the two orders with zero installments require validation against the source data.

# 

# \## Repository Structure

# 

# ```text

# Target-Brazil-Ecommerce-SQL-Analysis/

# ├── README.md

# ├── Target\_SQL\_Analysis.sql

# ├── Target\_Brazil\_Ecommerce\_SQL\_Analysis.docx

# ├── Target\_Brazil\_Ecommerce\_SQL\_Analysis.pdf

# ├── Images/

# │   ├── 01\_Initial\_Exploration.jpeg

# │   ├── 02\_Monthly\_Order\_Patterns\_Part1.jpeg

# │   ├── 02\_Monthly\_Order\_Patterns\_Part2.jpeg

# │   ├── 03\_Customer\_Distribution\_Part1.jpeg

# │   ├── 03\_Customer\_Distribution\_Part2.jpeg

# │   ├── 03\_Customer\_Distribution\_Part3.jpeg

# │   ├── 04\_Payment\_Analysis\_Part1.jpeg

# │   ├── 04\_Payment\_Analysis\_Part2.jpeg

# │   ├── 04\_Payment\_Analysis\_Part3.jpeg

# │   ├── 05\_Delivery\_Performance\_Part1.jpeg

# │   ├── 05\_Delivery\_Performance\_Part2.jpeg

# │   └── 05\_Delivery\_Performance\_Part3.jpeg

# └── Dataset/

# ```

# 

# \## How to Use This Project

# 

# 1\. Open `Target\_SQL\_Analysis.sql` to review the queries.

# 2\. Run the queries individually in Google BigQuery against a dataset you are authorized to access.

# 3\. Compare your outputs with the findings documented in this README.

# 4\. Refer to the PDF or Word report for the detailed analysis and interpretation.

# 

# The reported figures are based on the query outputs documented during the project. Running the SQL script against the available dataset is recommended to independently reproduce and validate the results.

# 

# \## Future Enhancements

# 

# \- Build a Power BI or Tableau dashboard for order, payment, freight, and delivery KPIs.

# \- Add state-level visual comparisons and year-over-year metrics using matching periods.

# \- Investigate delivery outliers and carrier-level performance if the required data is available.

# \- Add automated data-quality checks for missing dates, unusual installment counts, and unexpected payment labels.

# 

# \## Author

# 

# \*\*Rahul Ettaboina\*\*

# 

# Data Analyst | SQL | Python | Power BI | Tableau

# 

# \[LinkedIn](https://www.linkedin.com/in/rahul-ettaboina-5b259122a/)



