/* ============================================================
   MODULE:       Core Banking - Ledger Management
   OBJECT:       LEDGER_ENTRIES
   DESCRIPTION:  Stores double-entry bookkeeping records for
                 each transaction (DEBIT / CREDIT entries)
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE LEDGER_ENTRIES TABLE
   ============================================================ */

CREATE TABLE ledger_entries (

    -- Unique ledger entry identifier (Primary Key)
    ledger_id      NUMBER PRIMARY KEY,

    -- Account associated with the entry
    account_id     NUMBER,

    -- Reference to transaction (link to TRANSACTIONS table)
    txn_id         NUMBER,

    -- Entry type (DEBIT / CREDIT)
    entry_type     VARCHAR2(10),

    -- Entry amount (currency precision)
    amount         NUMBER(12,2),

    -- Record creation timestamp
    created_date   DATE DEFAULT SYSDATE
);


/* ============================================================
   STEP 2: ADD CONSTRAINTS (DATA VALIDATION)
   ============================================================ */

-- Restrict entry_type to valid values
ALTER TABLE ledger_entries 
ADD CONSTRAINT chk_entry_type
CHECK (entry_type IN ('DEBIT', 'CREDIT'));


/* ============================================================
   STEP 3: TEST CASE - GENERATE LEDGER ENTRIES
   ============================================================ */

-- Perform a sample transfer (should create ledger entries)
BEGIN
    transfer_funds(201, 202, 1000, 'IMPS');
END;
/


/* ============================================================
   STEP 4: VERIFY LEDGER ENTRIES
   ============================================================ */

-- Retrieve latest ledger entries
SELECT * FROM ledger_entries 
ORDER BY ledger_id DESC;


/* ============================================================
   STEP 5: RECONCILIATION QUERY
   ============================================================ */

-- Calculate balance using ledger entries
SELECT 
    account_id,
    SUM(
        CASE 
            WHEN entry_type = 'CREDIT' THEN amount
            ELSE -amount
        END
    ) AS calculated_balance
FROM ledger_entries
GROUP BY account_id;
/