/* ============================================================
   MODULE:       Core Banking - Account Master Table
   OBJECT:       ACCOUNTS
   DESCRIPTION:  Stores customer account details including
                 balance, account type, and status.
   AUTHOR:       Akshay
   CREATED ON:   (Use BANK during execution)
   ============================================================ */


/* ============================================================
   STEP 1: CREATE ACCOUNTS TABLE
   ============================================================ */

CREATE TABLE accounts (
    
    -- Unique account identifier (Primary Key)
    account_id      NUMBER PRIMARY KEY,
    
    -- Name of the account holder
    customer_name   VARCHAR2(100),
    
    -- Current account balance (2 decimal precision for currency)
    balance         NUMBER(12,2) DEFAULT 0,
    
    -- Type of account (SAVINGS / CURRENT)
    account_type    VARCHAR2(20),
    
    -- Account status (ACTIVE / INACTIVE)
    status          VARCHAR2(10) DEFAULT 'ACTIVE',
    
    -- Date when account was created
    created_date    DATE DEFAULT SYSDATE
);


/* ============================================================
   STEP 2: ADD CONSTRAINTS (DATA VALIDATION RULES)
   ============================================================ */

-- Ensure account status is only ACTIVE or INACTIVE
ALTER TABLE accounts 
ADD CONSTRAINT chk_status 
CHECK (status IN ('ACTIVE', 'INACTIVE'));


-- Ensure account type is only SAVINGS or CURRENT
ALTER TABLE accounts 
ADD CONSTRAINT chk_acc_type 
CHECK (account_type IN ('SAVINGS', 'CURRENT'));


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

-- Save changes permanently (Durability - ACID property)
COMMIT;


/* ============================================================
   STEP 5: VERIFY DATA
   ============================================================ */

-- Retrieve all records from accounts table
SELECT * FROM accounts;
