/* ============================================================
   MODULE:       Core Banking - Transaction Charges Master
   OBJECT:       TRANSACTION_CHARGES
   DESCRIPTION:  Stores transaction charges based on payment
                 channels (UPI / IMPS / NEFT)
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE TRANSACTION_CHARGES TABLE
   ============================================================ */

CREATE TABLE transaction_charges (
    
    -- Transaction channel identifier (Primary Key)
    txn_channel    VARCHAR2(20) PRIMARY KEY,
    
    -- Charge amount applied per transaction
    charge_amount  NUMBER(10,2)
);


/* ============================================================
   STEP 2: INSERT MASTER DATA
   ============================================================ */

-- UPI: No charge (free transactions)
INSERT INTO transaction_charges 
VALUES ('UPI', 0);

-- IMPS: Fixed charge per transaction
INSERT INTO transaction_charges 
VALUES ('IMPS', 5);

-- NEFT: Fixed charge per transaction
INSERT INTO transaction_charges 
VALUES ('NEFT', 10);


/* ============================================================
   STEP 3: COMMIT TRANSACTION
   ============================================================ */

-- Persist master data
COMMIT;