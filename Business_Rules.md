# Business Rules — PaySim Reconciliation Project

Each rule below is enforced by a specific SQL check in `sql/04_business_key_and_reconciliation.sql`
and `sql/05_exception_report.sql`.

## Completeness
1. `amount` must never be NULL.
2. `nameOrig` must never be NULL or blank.
3. `nameDest` must never be NULL or blank.

## Validity
4. `amount` cannot be negative or zero.
5. `type` must be one of exactly five values: PAYMENT, TRANSFER, CASH_OUT, CASH_IN, DEBIT.
6. `isFraud` must be either 0 or 1 only.
7. `isFlaggedFraud` must be either 0 or 1 only.
8. Balance fields (`oldbalanceOrg`, `newbalanceOrig`, `oldbalanceDest`, `newbalanceDest`) cannot be negative.
9. `nameOrig` must always start with the letter `C`.
10. `nameDest` must start with either `M` (merchant) or `C` (customer).
11. `step` must be a positive integer within the simulation's valid range.

## Consistency / Formatting
12. `type` values must use consistent casing (no lowercase or mixed case entries).
13. `type` and ID fields must have no leading or trailing whitespace.

## Uniqueness
14. No duplicate transactions — defined as identical `nameOrig`, `nameDest`,
    `amount`, and `step` appearing more than once.

## Reconciliation (Cross-System)
15. Every transaction present in `payment_system` should have a matching
    record in `bank_system` (same `business_txn_id`).
16. The `amount` for a matched transaction should be identical in both systems.
17. `bank_system` should not contain unexplained duplicate records for the
    same business transaction.

## Severity Assignment Logic
- **High** — the transaction cannot be reconciled at all, or a required field
  needed to reconcile it is missing (Missing in Bank System, Null Amount).
- **Medium** — the transaction exists and can be identified, but a value
  disagrees between systems or appears more than once (Amount Mismatch,
  Duplicate Transaction).
- **Low** — cosmetic or formatting issues that don't block identification or
  reconciliation, but should still be cleaned upstream (Invalid Type Value,
  Inconsistent Casing/Whitespace).
