## Create Database

CREATE DATABASE pay_project;
USE pay_project;

## Create Table (Payment System)

-- sql
CREATE TABLE payment_system (
    step INT,
    type VARCHAR(20),
    amount DECIMAL(18,2),
    nameOrig VARCHAR(30),
    oldbalanceOrg DECIMAL(18,2),
    newbalanceOrig DECIMAL(18,2),
    nameDest VARCHAR(30),
    oldbalanceDest DECIMAL(18,2),
    newbalanceDest DECIMAL(18,2),
    isFraud TINYINT,
    isFlaggedFraud TINYINT
);


## Load PaySim Dataset

USE pay_project;

LOAD DATA LOCAL INFILE 'C:/Users/Sethupathi/Downloads/Paysim/paysim_200k_random.csv'
INTO TABLE payment_system
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


SELECT COUNT(*) AS total_transactions
FROM payment_system;
-- 200000


- Data profiling / exploration
-- ------------------------------------------------------------

--- Transaction Type Distribution
SELECT
    type,
    COUNT(*) AS transaction_count,
    ROUND(AVG(amount),2) AS average_amount
FROM payment_system
GROUP BY type
ORDER BY transaction_count DESC;
/*
type      transaction_count  average_amount
CASH_OUT	70539	       175239.43
PAYMENT	        67692	       13070.60
CASH_IN	        43741	       168568.85
TRANSFER	16728	       914744.98
DEBIT	        1300	       5951.44
*/

--- Null Value Check

SELECT
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS null_type,
    SUM(CASE WHEN nameOrig IS NULL THEN 1 ELSE 0 END) AS null_nameOrig,
    SUM(CASE WHEN nameDest IS NULL THEN 1 ELSE 0 END) AS null_nameDest
FROM payment_system;
-- no null values


--- Duplicate Check

SELECT
    nameOrig,
    nameDest,
    amount,
    step,
    COUNT(*) AS duplicate_count
FROM payment_system
GROUP BY nameOrig, nameDest, amount, step
HAVING COUNT(*) > 1;
-- no rows


--- Fraud Distribution
SELECT
    isFraud,
    COUNT(*) AS transaction_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM payment_system),
        2
    ) AS percentage
FROM payment_system
GROUP BY isFraud;
/*
isfraud transaction_count percentage
0	199727	             99.86
1	273	             0.14
*/


 
-- ------------------------------------------------------------
-- Add indexes for query performance
-- ------------------------------------------------------------
CREATE INDEX idx_type ON payment_system(type);
CREATE INDEX idx_nameOrig ON payment_system(nameOrig);
CREATE INDEX idx_nameDest ON payment_system(nameDest);
CREATE INDEX idx_isFraud ON payment_system(isFraud);