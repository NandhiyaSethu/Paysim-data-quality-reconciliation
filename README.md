# Enterprise Data Quality & Reconciliation — PaySim Project

## Business Scenario
As a Data Analyst supporting a digital payments company, this project validates
whether transactions recorded by a **Payment Gateway** system agree with the
same transactions recorded by a **Bank Settlement** system, identifies where
they diverge, and quantifies the scale and severity of each type of break, and reports a reconciliation rate — the kind of check a Finance/Risk Ops team relies on daily.

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
paysim-data-quality-reconciliation/
├── README.md
├── sql/
│   ├── [01_setup_and_load.sql](01Setup_and_load.sql) | Database setup, data import, profiling, indexes |
│   ├── [02_create_two_systems.sql](02_create_two_systems.sql) | Creates the Payment Gateway vs Bank Settlement table pair |
│   ├── [03_data_corruption.sql](03_data_corruption.sql) | Injects realistic data quality issues into the Bank system |
│   ├── [04_business_key_and_reconciliation.sql](04_business_key_and_reconciliation.sql) | Builds the shared business key and runs core reconciliation checks |
│   ├── [05_exception_report.sql](05_exception_report.sql) | Consolidated exception report with severity ratings |
│   ├── [06_reporting_views.sql](07_reporting_views.sql) | Power BI–ready summary and detail views |
├── documentation/
│   ├── Data_Dictionary.md
│   ├── Business_Rules.md
│   └── Corruption_Log.md
├── powerbi/
│   └── Paysim_reconciliation_dashboard.pbix
└── screenshots/
    ├── overview_page.png
    └── exception_details_page.png

## Key Design Decision: The Business Key
The join key between the two systems (`business_txn_id`) is built from
`step + nameOrig + nameDest` — deliberately **excluding** `amount`. An earlier
version of this project included `amount` in the key, which caused genuine
amount mismatches to be misclassified as "missing" records (since changing the
amount changed the key itself). This was identified and corrected — a good
example of why business keys should only use immutable, identifying fields. 

## Key Findings

| Metric | Value |
|---|---|
| Total transactions (Payment System) | 2,00,000 |
| Total transactions (Bank System) | 1,99,800 |
| Matched Transactions | 198,692 |
| Missing in Bank System | 910 |
| Amount Mismatches | 398 |
| Total Exceptions (all rule violations) | 	18,258 |

## Exception Type Breakdown

| Rule Violated | Value |
|---|---|
| Null Amount in Bank | 381 |
| Null nameOrig (Bank) | 411 |
| Invalid Type Value | 8,110 |  
| Duplicate Transaction | ~ 284 |
| Inconsistent Casing/Whitespace | ~7,911 |
| Missing in Bank System | 910 |
| Amount Mismatch | 398 |


## Dashboard
See /dashboard/ and `/screenshots/` for the final
Power BI dashboard covering: Overview KPIs, Exception Breakdown, Severity
Distribution, Drill-through Detail, and Trend over time.
<img width="1920" height="1080" alt="Screenshot (52) (1)" src="https://github.com/user-attachments/assets/540194d8-8ee9-4128-8a51-fe6c7c85d8e5" />
<img width="1920" height="1080" alt="Screenshot (53) (1)" src="https://github.com/user-attachments/assets/ca91d71d-01fa-494b-a1a6-930ce3082434" />



## Documentation
- [Data Dictionary](documentation/Data_Dictionary.md)
- [Business Rules](documentation/Business_Rules.md)
- [Corruption Log](documentation/Corruption_Log.md)
