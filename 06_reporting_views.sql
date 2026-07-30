-- ============================================================
-- 06_reporting_views.sql
-- Purpose: Create the summary and detail views that Power BI
--          will connect to directly. These pre-aggregate data
--          in MySQL so Power BI never has to import raw,
--          row-level tables at full scale.
-- ============================================================

## Dashboard View

-- Summary of exceptions by rule

CREATE OR REPLACE VIEW recon_summary AS
SELECT rule_violated, COUNT(*) AS total_exceptions
FROM exception_report
GROUP BY rule_violated;

 
-- Summary of exceptions by severity

CREATE OR REPLACE VIEW severity_summary AS
SELECT severity, COUNT(*) AS total_exceptions
FROM exception_report
GROUP BY severity;
 

-- Full reconciliation dashboard view (row-level detail)

CREATE OR REPLACE VIEW reconciliation_dashboard AS
SELECT p.business_txn_id, p.type, p.amount AS payment_amount, b.amount AS bank_amount,
CASE WHEN b.business_txn_id IS NULL THEN 'Missing'
     WHEN ROUND(p.amount,2) <> ROUND(b.amount,2) THEN 'Mismatch'
     ELSE 'Matched'
     END AS reconciliation_status
FROM payment_system p
LEFT JOIN bank_system b ON p.business_txn_id = b.business_txn_id;
 


