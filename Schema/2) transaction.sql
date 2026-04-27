/* ============================================================
   MODULE:       Core Banking - Transaction Processing
   OBJECT:       TRANSACTIONS
   DESCRIPTION:  Stores all financial transactions such as
                 deposits, withdrawals, and transfers between accounts.
   AUTHOR:       Akshay
   CREATED ON:   (Use BANK during execution)
   ============================================================ */


/* ============================================================
   STEP 1: CREATE TRANSACTIONS TABLE
   ============================================================ */

CREATE TABLE transactions (
    
    -- Unique transaction identifier (Primary Key)
    txn_id         NUMBER PRIMARY KEY,
    
    -- Source account (NULL for deposits)
    from_account   NUMBER,
    
    -- Destination account (NULL for withdrawals)
    to_account     NUMBER,
    
    -- Transaction amount (currency with 2 decimal precision)
    amount         NUMBER(12,2) NOT NULL,
    
    -- Type of transaction (DEPOSIT / WITHDRAW / TRANSFER)
    txn_type       VARCHAR2(20),
    
    -- Date and time of transaction
    txn_date       DATE DEFAULT SYSDATE,
    
    -- Transaction status (SUCCESS / FAILED)
    status         VARCHAR2(10)
);


/* ============================================================
   STEP 2: ADD FOREIGN KEY CONSTRAINTS
   ============================================================ */

-- Link source account to ACCOUNTS table
ALTER TABLE transactions 
ADD CONSTRAINT fk_from_acc 
FOREIGN KEY (from_account) 
REFERENCES accounts(account_id);

-- Link destination account to ACCOUNTS table
ALTER TABLE transactions 
ADD CONSTRAINT fk_to_acc 
FOREIGN KEY (to_account) 
REFERENCES accounts(account_id);


/* ============================================================
   STEP 3: ADD BUSINESS RULE CONSTRAINTS
   ============================================================ */


ALTER TABLE transactions 
MODIFY txn_type NOT NULL;

ALTER TABLE transactions 
MODIFY txn_channel NOT NULL;

ALTER TABLE transactions 
ADD CONSTRAINT chk_txn_type_v2
CHECK (txn_type IN ('DEPOSIT', 'WITHDRAW', 'TRANSFER', 'REVERSAL'));

ALTER TABLE transactions 
ADD CONSTRAINT chk_txn_channel
CHECK (txn_channel IN ('UPI', 'IMPS', 'NEFT', 'ATM', 'CASH'));

-- Restrict transaction status to valid values
ALTER TABLE transactions 
ADD CONSTRAINT chk_status_txn 
CHECK (status IN ('SUCCESS', 'FAILED'));


/* ============================================================
   STEP 4: INSERT SAMPLE DATA
   ============================================================ */

-- Example: Deposit into account 101
INSERT INTO transactions (
    txn_id, 
    from_account, 
    to_account, 
    amount, 
    txn_type, 
    status
) 
VALUES (
    1, 
    NULL,        -- No source account for deposit
    101,         -- Destination account
    1000, 
    'DEPOSIT', 
    'SUCCESS'
);


/* ============================================================
   STEP 5: COMMIT TRANSACTION
   ============================================================ */

-- Persist transaction (Durability - ACID property)
COMMIT;


/* ============================================================
   STEP 6: TEST FAILURE SCENARIO
   ============================================================ */

-- This should FAIL due to invalid foreign key (account 999 does not exist)
INSERT INTO transactions 
VALUES (
    2, 
    999,         -- Invalid source account
    101, 
    500, 
    'TRANSFER', 
    SYSDATE, 
    'SUCCESS'
);


/* ============================================================
   STEP 7: VERIFY DATA
   ============================================================ */

-- Retrieve all transaction records
SELECT * FROM transactions;



ALTER TABLE transactions 
ADD charge_amount NUMBER(10,2);

ALTER TABLE transactions 
ADD (
    reference_txn_id NUMBER,
    txn_direction    VARCHAR2(10)
);

