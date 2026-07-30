-- ============================================================
-- 03_data_corruption.sql
-- Purpose: Deliberately inject realistic data quality issues
--          into bank_system, simulating the kinds of breaks
--          that occur between two independent financial systems.
-- ============================================================

## Simulate Real-World Reconciliation Issues

--- Missing Transactions 

DELETE FROM bank_system
ORDER BY RAND()
LIMIT 500;

SELECT COUNT(*) FROM bank_system;
-- 199500 rows

---- Duplicate Transactions for 300 rows

INSERT INTO bank_system
(step, type, amount, nameOrig, oldbalanceOrg, newbalanceOrig,
 nameDest, oldbalanceDest, newbalanceDest, isFraud, isFlaggedFraud)
SELECT
step, type, amount, nameOrig, oldbalanceOrg, newbalanceOrig,
nameDest, oldbalanceDest, newbalanceDest, isFraud, isFlaggedFraud
FROM bank_system
ORDER BY RAND()
LIMIT 300;

SELECT COUNT(*) FROM bank_system;
-- 199800 rows

-- Alter amount for Amount Mismatches

UPDATE bank_system
SET amount = amount * 0.99
WHERE transaction_id % 500 = 0;
-- 399 rows affected


--- Inserting Null Amounts randomly

UPDATE bank_system
SET amount = NULL
WHERE RAND() < 0.002;
-- 381 rows affected

UPDATE bank_system
SET nameOrig = NULL
WHERE RAND() < 0.002;
-- 411 rows affected

--- Inconsistent Casing - Lowercase Transaction Types

UPDATE bank_system
SET type = LOWER(type)
WHERE RAND() < 0.02;
-- 3954 rows affected

### Leading / Trailing Spaces

UPDATE bank_system
SET type = CONCAT('  ', type, '  ')
WHERE RAND() < 0.02;
 -- 4064 or 3939 rows affected


-- Invalid Transaction Type

UPDATE bank_system
SET type = 'PAYMENNT'
WHERE RAND() < 0.001;
-- 199 rows affected

-- Invalid Fraud Flag

UPDATE bank_system
SET isFraud = 5
WHERE RAND() < 0.001;
-- 211 rows affected



