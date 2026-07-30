-- ============================================================
-- 04_business_key_and_reconciliation.sql
-- Purpose: Build the shared business key used to match records
--          between the two systems, then run the core
--          reconciliation queries.
-- ============================================================

## 11. Create Business Transaction Key

--Payment System
ALTER TABLE payment_system
ADD COLUMN business_txn_id VARCHAR(100);

UPDATE payment_system
SET business_txn_id = CONCAT(step,'_',nameOrig,'_',nameDest);

--Bank System
ALTER TABLE bank_system
ADD COLUMN business_txn_id VARCHAR(100);

UPDATE bank_system
SET business_txn_id = CONCAT(step,'_',nameOrig,'_',nameDest);

select count(*) from bank_system where business_txn_id is null;


## Reconciliation Queries

--- Missing In Bank system

SELECT
    p.business_txn_id
FROM payment_system p
LEFT JOIN bank_system b
ON p.business_txn_id = b.business_txn_id
WHERE b.business_txn_id IS NULL;
-- 910 rows has missing 


--- Duplicate Transactions in Bank

SELECT step, type, amount, nameOrig, nameDest, COUNT(*) AS duplicate_count
FROM bank_system
GROUP BY step, type, amount, nameOrig, nameDest
HAVING COUNT(*) > 1;
-- 274 rows has duplicate transactions

--- Amount Mismatches

SELECT
    p.business_txn_id,
    p.amount AS payment_amount,
    b.amount AS bank_amount,
    ROUND(b.amount - p.amount,2) AS amount_difference
FROM payment_system p
JOIN bank_system b
ON p.business_txn_id = b.business_txn_id
WHERE ROUND(p.amount,2) <> ROUND(b.amount,2);
-- 398 rows has amount mismatched

--- Null Values in Bank System

SELECT
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN nameOrig IS NULL THEN 1 ELSE 0 END) AS null_nameOrig
FROM bank_system;
-- 381 rows have null amount
-- 411 rows have null_nameorig


--- Invalid Transaction Types

SELECT DISTINCT
    type
FROM bank_system
WHERE TRIM(UPPER(type))
      NOT IN ('PAYMENT','TRANSFER','CASH_OUT','CASH_IN','DEBIT')
   OR type <> TRIM(type);
/*
  TYPE
    CASH_IN    
    CASH_OUT    
    DEBIT    
    PAYMENT    
    TRANSFER    
  CASH_IN  
  CASH_OUT  
  DEBIT  
  PAYMENT  
  TRANSFER  
PAYMENNT
*/


-- Reconciled transaction count

select count(*) as reconciled_transaction from payment_system p
join bank_system b on p.business_txn_id = b.business_txn_id
where round(p.amount,2) = round(b.amount,2);
-- 198611 rows

-- Reconciliation rate 

SELECT ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM payment_system), 2) AS reconciliation_rate
FROM payment_system p JOIN bank_system b 
ON p.business_txn_id = b.business_txn_id
WHERE ROUND(p.amount,2) = ROUND(b.amount,2);
-- 99.31
