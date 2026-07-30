-- ============================================================
-- 05_exception_report.sql
-- Purpose: Build a single consolidated exception report,
--          combining every data quality rule violation with
--          a severity rating, for use in the Power BI dashboard.
-- ============================================================

## 13. Exception Report

CREATE TABLE exception_report AS
SELECT
    p.business_txn_id,
    'Missing in Bank System' AS rule_violated,
    'High' AS severity
FROM payment_system p
LEFT JOIN bank_system b
ON p.business_txn_id = b.business_txn_id
WHERE b.business_txn_id IS NULL

UNION ALL

SELECT
    p.business_txn_id,
    'Amount Mismatch' as rule_violated,
    'Medium' AS severity
FROM payment_system p
JOIN bank_system b
ON p.business_txn_id = b.business_txn_id
WHERE ROUND(p.amount,2) <> ROUND(b.amount,2)

UNION ALL

SELECT
    business_txn_id,
    'Null Amount in Bank' as rule_violated,
    'High' AS severity
FROM bank_system
WHERE amount IS NULL

UNION ALL

SELECT
    business_txn_id,
    'Invalid Type Value' as rule_violated,
    'Low' AS severity
FROM bank_system
WHERE TRIM(UPPER(type))
      NOT IN ('PAYMENT','TRANSFER','CASH_OUT','CASH_IN','DEBIT')
   OR type <> TRIM(type)

UNION ALL
SELECT
    business_txn_id,
    'Inconsistent Casing/ WhiteSpace' as rule_violated,
    'Low' AS severity
FROM bank_system
WHERE type <> TRIM(type) OR type <> UPPER(type)

UNION ALL
SELECT business_txn_id, 'Duplicate Transaction' AS rule_violated, 'Medium' AS severity
FROM bank_system
WHERE (step, type, amount, nameOrig, nameDest) IN (    
 SELECT step, type, amount, nameOrig, nameDest    
 FROM bank_system     
 GROUP BY step, type, amount, nameOrig, nameDest   
 HAVING COUNT(*) > 1);

SELECT count(*) FROM exception_report;
-- 18258 rows

-- Add audit timestamp
ALTER TABLE exception_report
ADD COLUMN detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Check totals
 SELECT rule_violated, severity, COUNT(*) AS cnt
 FROM exception_report
 GROUP BY rule_violated, severity
 ORDER BY FIELD(severity,'High','Medium','Low');
/*
rule_violated                  severity cnt
Missing in Bank System	        High	910
Null Amount in Bank	        High	381
Amount Mismatch	                Medium	398
Duplicate Transaction	        Medium	548
Invalid Type Value	        Low	8110
Inconsistent Casing/ WhiteSpace	Low	7911
*/
