/* ============================================================
   MODULE:       Core Banking - Error Logging System
   OBJECT:       ERROR_LOGS
   DESCRIPTION:  Stores runtime errors occurring during
                 transaction processing (e.g., insufficient balance,
                 invalid account, system failures).
   AUTHOR:       Akshay
   CREATED ON:   (Use BANK during execution)
   ============================================================ */


/* ============================================================
   STEP 1: CREATE ERROR_LOGS TABLE
   ============================================================ */

CREATE TABLE error_logs (
    
    -- Unique error identifier (Primary Key)
    error_id        NUMBER PRIMARY KEY,
    
    -- Detailed error message (supports large text)
    error_message   VARCHAR2(4000),
    
    -- Date and time when error occurred
    error_date      DATE DEFAULT SYSDATE,
    
    -- Name of procedure/module where error occurred
    procedure_name  VARCHAR2(100),
    
    -- Related account (if applicable)
    account_id      NUMBER
);


/* ============================================================
   STEP 2: INSERT SAMPLE ERROR DATA
   ============================================================ */

-- Example: Insufficient balance during transfer
INSERT INTO error_logs (
    error_id, 
    error_message, 
    procedure_name, 
    account_id
) 
VALUES (
    1, 
    'Insufficient balance', 
    'TRANSFER_FUNDS', 
    101
);


/* ============================================================
   STEP 3: COMMIT TRANSACTION
   ============================================================ */

-- Persist error log (important for audit & debugging)
COMMIT;


/* ============================================================
   STEP 4: VERIFY DATA
   ============================================================ */

-- Retrieve all logged errors
SELECT * FROM error_logs;
