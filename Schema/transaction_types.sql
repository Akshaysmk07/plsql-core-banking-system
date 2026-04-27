/* ============================================================
   MODULE:       Core Banking - Transaction Type Master
   OBJECT:       TRANSACTION_TYPES
   DESCRIPTION:  Stores supported transaction channels along with
                 limits and descriptions (UPI / IMPS / NEFT)
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE TRANSACTION_TYPES TABLE
   ============================================================ */

CREATE TABLE transaction_types (
    
    -- Transaction type identifier (Primary Key)
    txn_type        VARCHAR2(20) PRIMARY KEY,
    
    -- Maximum allowed limit per transaction
    max_limit       NUMBER(12,2),
    
    -- Description of transaction type
    description     VARCHAR2(100)
);


/* ============================================================
   STEP 2: INSERT MASTER DATA
   ============================================================ */

-- UPI: Instant small transactions
INSERT INTO transaction_types 
VALUES ('UPI', 100000, 'Instant small transfers');

-- IMPS: Instant medium transactions
INSERT INTO transaction_types 
VALUES ('IMPS', 200000, 'Instant medium transfers');

-- NEFT: Batch large transactions
INSERT INTO transaction_types 
VALUES ('NEFT', 1000000, 'Batch large transfers');


/* ============================================================
   STEP 3: COMMIT TRANSACTION
   ============================================================ */

-- Persist master data
COMMIT;