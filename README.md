# Enterprise Data Quality & Reconciliation — PaySim Project

## Business Scenario
As a Data Analyst supporting a digital payments company, this project validates
whether transactions recorded by a **Payment Gateway** system agree with the
same transactions recorded by a **Bank Settlement** system, identifies where
they diverge, and quantifies the scale and severity of each type of break.

## Dataset
- Source: [PaySim — Synthetic Financial Datasets for Fraud Detection (Kaggle)](https://www.kaggle.com/datasets/ealaxi/paysim1)
- Sample used: 200,000 randomly sampled rows from the original ~6.3M-row dataset
  (sampled for performance; a random sample was used instead of the first N rows
  to preserve a representative distribution of transaction types and fraud rate
  across the full simulation time range).

## Tools
SQL (MySQL) + Power BI

## Project Structure

| File | Description |
|---|---|
| [01_setup_and_load.sql](01Setup_and_load.sql) | Database setup, data import, profiling, indexes |
| [02_create_two_systems.sql](02_create_two_systems.sql) | Creates the Payment Gateway vs Bank Settlement table pair |
| [03_data_corruption.sql](03_data_corruption.sql) | Injects realistic data quality issues into the Bank system |
| [04_business_key_and_reconciliation.sql](04_business_key_and_reconciliation.sql) | Builds the shared business key and runs core reconciliation checks |
| [05_exception_report.sql](05_exception_report.sql) | Consolidated exception report with severity ratings |
| [06_reporting_views.sql](07_reporting_views.sql) | Power BI–ready summary and detail views |

## Key Design Decision: The Business Key
The join key between the two systems (`business_txn_id`) is built from
`step + nameOrig + nameDest` — deliberately **excluding** `amount`. An earlier
version of this project included `amount` in the key, which caused genuine
amount mismatches to be misclassified as "missing" records (since changing the
amount changed the key itself). This was identified and corrected — a good
example of why business keys should only use immutable, identifying fields. 
And I have ran update of leading and trailing spaces twice by mistake so 
mismatches will be greater than 500 because of double trailing space.

## Key Findings

| Metric | Value |
|---|---|
| Total transactions (Payment System) | 200,000 |
| Missing in Bank System | 910 |
| Amount Mismatches | 398 |
| Null Amounts (Bank) | 381 |
| Null nameOrig (Bank) | 411 |
| Invalid Type Values | 203 |  ----
| Duplicate Transactions | 274 |
| Casing/Whitespace Issues | ~7,800 |
| Reconciliation Rate | 99.31 |

## Dashboard
See `/powerbi/reconciliation_dashboard.pbix` and `/screenshots/` for the final
Power BI dashboard covering: Overview KPIs, Exception Breakdown, Severity
Distribution, Drill-through Detail, and Trend over time.

## Documentation
- [Data Dictionary](documentation/Data_Dictionary.md)
- [Business Rules](documentation/Business_Rules.md)
- [Corruption Log](documentation/Corruption_Log.md)
