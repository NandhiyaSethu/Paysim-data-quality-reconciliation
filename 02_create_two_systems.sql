- ============================================================
-- 02_create_two_systems.sql
-- Purpose: Simulate two independent systems that should agree
--          on the same transactions - a Payment Gateway and a
--          Bank Settlement system. This is the foundation of
--          the reconciliation exercise.
-- ============================================================

 
-- Create an identical copy to represent the "Bank Settlement" system

CREATE TABLE bank_system LIKE payment_system;

INSERT INTO bank_system
SELECT *
FROM payment_system;


SELECT COUNT(*) AS bank_transactions
FROM bank_system;
-- 200000 rows