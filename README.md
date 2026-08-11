# Enterprise Data Quality & Reconciliation Dashboard — PaySim

## Business Scenario
As a Data Analyst supporting a digital payments company, this project validates
whether transactions recorded by a **Payment Gateway** system agree with the
same transactions recorded by a **Bank Settlement** system, identifies where
they diverge, categorizes the type and severity of each break, and reports a
reconciliation rate — the kind of check a Finance/Risk Ops team relies on daily.

## Dataset
- Source: [PaySim — Synthetic Financial Datasets for Fraud Detection (Kaggle)](https://www.kaggle.com/datasets/ealaxi/paysim1)
- Sample used: 200,000 randomly sampled rows from the original ~6.3M-row dataset,
  selected for performance reasons. A random sample (not the first N rows) was
  used to preserve a representative distribution of transaction types and fraud
  rate across the full simulation time range.

## Tools
SQL (MySQL) + Power BI

## Project Structure

```
paysim-data-quality-reconciliation/
├── README.md
├── sql/
│   ├── 01_setup_and_load.sql
│   ├── 02_create_two_systems.sql
│   ├── 03_data_corruption.sql
│   ├── 04_business_key_and_reconciliation.sql
│   ├── 05_exception_report.sql
│   ├── 06_reconciliation_status.sql
│   └── 07_reporting_views.sql
├── documentation/
│   ├── Data_Dictionary.md
│   ├── Business_Rules.md
│   └── Corruption_Log.md
├── powerbi/
│   └── Paysim_reconciliation_dashboard.pbix
└── screenshots/
    ├── overview_page.png
    └── exception_details_page.png
```

## Methodology

1. Loaded a 200,000-row random sample of PaySim into MySQL.
2. Profiled the data (nulls, duplicates, transaction type distribution, fraud rate).
3. Split the data into two simulated systems: `payment_system` (source of truth)
   and `bank_system` (an identical copy representing an independent settlement system).
4. Deliberately injected 8 categories of realistic data quality issues into
   `bank_system` only — missing records, duplicates, amount mismatches, nulls,
   inconsistent casing, whitespace, invalid category values, and corrupted flags.
5. Built a shared business transaction key to match records between the two systems.
6. Ran reconciliation queries to classify every transaction as Matched, Mismatch, or Missing.
7. Built a consolidated exception report with a severity rating (High/Medium/Low) per rule.
8. Visualized the results in a two-page Power BI dashboard.

## Key Design Decision: The Business Key
The join key between the two systems (`business_txn_id`) is built from
`step + nameOrig + nameDest` — deliberately **excluding** `amount`. An earlier
version of this project included `amount` in the key, which caused genuine
amount mismatches to be misclassified as "missing" records, since changing the
amount also changed the key itself. This was identified during testing and
corrected — a practical example of why business keys should only be built from
immutable, identifying fields, not fields expected to vary between systems.

## Key Findings

| Metric | Value |
|---|---|
| Total transactions (Payment System) | 200,000 |
| Total transactions (Bank System) | 199,800 |
| Reconciliation Rate | 99.35% |
| Matched Transactions | 198,692 |
| Missing in Bank System | 910 |
| Amount Mismatches | 398 |
| Total Exceptions (all rule violations) | 18,258 |

**Exception Type Breakdown:**

| Rule Violated | Count | % of Exceptions | Severity |
|---|---|---|---|
| Invalid Type Value | 8,110 | 44.42% | Low |
| Inconsistent Casing/Whitespace | 7,911 | 43.33% | Low |
| Missing in Bank System | 910 | 4.98% | High |
| Amount Mismatch | 398 | 2.18% | Medium |
| Duplicate Transaction | ~284 | ~1.5% | Medium |
| Null Amount in Bank | 381 | ~2% | High |

*(Note: exception categories are not mutually exclusive — a single transaction
can trigger more than one rule violation, e.g., a row with a NULL sender ID is
counted both under "Missing" via the business key AND under a null-value check.)*

## Dashboard
Two-page Power BI dashboard:
- **Overview** — KPI cards (Total Transactions, Reconciliation Rate, Total
  Exceptions), Reconciliation Status breakdown, Exception Type distribution,
  Transaction Volume by Type.
- **Exception Details** — filterable, row-level detail table with slicers for
  Transaction Type, Reconciliation Status, and Fraud Flag.

See `/screenshots/` for dashboard images and `/powerbi/` for the full `.pbix` file.

## Documentation
- [Data Dictionary](documentation/Data_Dictionary.md)
- [Business Rules](documentation/Business_Rules.md)
- [Corruption Log](documentation/Corruption_Log.md)

## Limitations
- Uses a 200,000-row random sample rather than the full ~6.3M-row dataset.
- PaySim is synthetic data; balance/fraud patterns may not reflect real-world
  payment system behavior.
- Corruption was injected programmatically for demonstration purposes; real
  reconciliation breaks would need to be discovered, not engineered.
