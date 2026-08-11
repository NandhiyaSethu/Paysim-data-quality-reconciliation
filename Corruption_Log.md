# Corruption Log — Injected Data Quality Issues

All corruption was applied only to `bank_system`, leaving `payment_system` as
the untouched source of truth. This simulates realistic divergence between two
independent systems recording the same events.

| # | Issue Injected | Method | Rows Affected |
|---|---|---|---|
| 1 | Missing records | Deleted ~500 random rows | 500 |
| 2 | Duplicate records | Duplicated ~300 random rows | 300 |
| 3 | Amount mismatch | Reduced amount by 1% on a subset (`transaction_id % 500 = 0`) | 399 |
| 4 | Null amount | Set `amount = NULL` on ~0.2% of rows | 412 |
| 4b | Null sender ID | Set `nameOrig = NULL` on ~0.2% of rows | 419 |
| 5 | Inconsistent casing | Lowercased `type` on ~2% of rows | 3,992 |
| 6 | Leading/trailing whitespace | Added spaces around `type` on ~2% of rows (run twice by mistake, compounding on some rows) | ~3,900–4,000 |
| 7 | Invalid category value | Set `type = 'PAYMENNT'` (typo) on ~0.1% of rows | 203 |
| 8 | Corrupted fraud flag | Set `isFraud = 5` (invalid value) on ~0.1% of rows | 160 |

## Combined / Downstream Effects
- Steps 5 and 6 together are captured under a single **"Inconsistent
  Casing/Whitespace"** rule in the exception report (since a row can have
  either or both issues), producing a combined total of **7,911** flagged rows.
- Step 4b (null `nameOrig`) has a secondary effect: since `business_txn_id` is
  built from `step + nameOrig + nameDest`, a null `nameOrig` breaks the join
  key, causing that row to also appear under **"Missing in Bank System"** even
  though the row physically still exists in `bank_system`. This raised the
  observed "Missing" count from the expected ~500 (genuine deletions) to 910.
  This is a realistic finding: a corrupted identifier genuinely does cause a
  downstream reconciliation failure, and is documented as such rather than
  treated as a bug.

## Final Verified Counts (post-correction)
| Metric | Count |
|---|---|
| bank_system row count | 199,800 |
| Missing in Bank System (via business key) | 910 |
| Amount Mismatch | 398 |
| Null Amount | 381 |
| Null nameOrig | 411 |
| Duplicate Transaction | 274 |
| Invalid Type Value | 8,110 |
| Inconsistent Casing/Whitespace | 7,911 |
| **Total exception rows (exception_report_enhanced)** | **18,258** |
