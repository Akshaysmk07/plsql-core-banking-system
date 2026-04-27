/* ============================================================
   MODULE:       Core Banking - Account Master Table
   OBJECT:       ACCOUNTS
   DESCRIPTION:  Stores customer account details including
                 balance, account type, and status.
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE ACCOUNTS TABLE
   ============================================================ */

CREATE TABLE accounts (
    
    -- Unique account identifier (Primary Key)
    account_id      NUMBER PRIMARY KEY,
    
    -- Name of the account holder (to be replaced by customer_id)
    customer_name   VARCHAR2(100),
    
    -- Current account balance (currency with 2 decimal precision)
    balance         NUMBER(12,2) DEFAULT 0,
    
    -- Type of account (SAVINGS / CURRENT)
    account_type    VARCHAR2(20),
    
    -- Account status (ACTIVE / INACTIVE)
    status          VARCHAR2(10) DEFAULT 'ACTIVE',
    
    -- Record creation date
    created_date    DATE DEFAULT SYSDATE
);


/* ============================================================
   STEP 2: ADD CONSTRAINTS (DATA VALIDATION RULES)
   ============================================================ */

-- Ensure account status is restricted to valid values
ALTER TABLE accounts 
ADD CONSTRAINT chk_status 
CHECK (status IN ('ACTIVE', 'INACTIVE'));

-- Ensure account type is restricted to valid values
ALTER TABLE accounts 
ADD CONSTRAINT chk_acc_type 
CHECK (account_type IN ('SAVINGS', 'CURRENT'));

ALTER TABLE accounts 
ADD CONSTRAINT fk_customer 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
/* ============================================================
   STEP 3: INSERT SAMPLE DATA
   ============================================================ */

-- Insert a sample account record for testing
INSERT INTO accounts (
    account_id, 
    customer_name, 
    balance, 
    account_type
) 
VALUES (
    101, 
    'Akshay', 
    5000, 
    'SAVINGS'
);


/* ============================================================
   STEP 4: COMMIT TRANSACTION
   ============================================================ */

-- Persist changes (Durability - ACID property)
COMMIT;


/* ============================================================
   STEP 5: VERIFY DATA
   ============================================================ */

-- Retrieve all records from accounts table
SELECT * FROM accounts;


/* ============================================================
   STEP 6: NORMALIZATION (REMOVE REDUNDANT COLUMN) VERSION 2 UPDATE
   ============================================================ */

-- Drop customer_name to avoid data duplication
ALTER TABLE accounts DROP COLUMN customer_name;

-- Add customer_id to establish relationship with customers table
ALTER TABLE accounts 
ADD customer_id NUMBER;


/* ============================================================
   STEP 7: ADD FOREIGN KEY CONSTRAINT
   ============================================================ */

-- Link accounts to customers using customer_id
ALTER TABLE accounts 
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


/* ============================================================
   STEP 8: INSERT DATA WITH CUSTOMER REFERENCE
   ============================================================ */

-- Insert account linked to existing customer
INSERT INTO accounts (
    account_id,
    customer_id,
    balance,
    account_type
) VALUES (
    210,
    1,
    5000,
    'SAVINGS'
);

-- Persist changes
COMMIT;


/* ============================================================
   STEP 9: JOIN QUERY (ACCOUNT + CUSTOMER DETAILS)
   ============================================================ */

-- Retrieve account details along with customer name
SELECT 
    a.account_id,
    c.customer_name,
    a.balance
FROM accounts a
JOIN customers c
ON a.customer_id = c.customer_id;


/* ============================================================
   STEP 10: FINAL VERIFICATION
   ============================================================ */

-- Retrieve all records from accounts table
SELECT * FROM accounts;


/* ============================================================
   ADD INTEREST RATE COLUMN
   ============================================================ */

-- Add interest_rate column with default value (4%)
ALTER TABLE accounts 
ADD interest_rate NUMBER(5,2) DEFAULT 4;
