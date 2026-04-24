/* ============================================================
   MODULE:       Core Banking - Audit Logging System
   OBJECT:       AUDIT_LOGS
   DESCRIPTION:  Tracks all changes made to account balances.
                 Maintains before and after values for auditing,
                 compliance, and traceability.
   AUTHOR:       Akshay
   CREATED ON:   (Use SYSDATE during execution)
   ============================================================ */


/* ============================================================
   STEP 1: CREATE AUDIT_LOGS TABLE
   ============================================================ */

CREATE TABLE audit_logs (
    
    -- Unique audit record identifier (Primary Key)
    audit_id       NUMBER PRIMARY KEY,
    
    -- Account on which action is performed
    account_id     NUMBER,
    
    -- Balance before transaction
    old_balance    NUMBER(12,2),
    
    -- Balance after transaction
    new_balance    NUMBER(12,2),
    
    -- Type of operation (INSERT / UPDATE)
    action_type    VARCHAR2(10),
    
    -- Date and time of action
    action_date    DATE DEFAULT SYSDATE
);


/* ============================================================
   STEP 2: ADD FOREIGN KEY CONSTRAINT
   ============================================================ */

-- Link audit logs to ACCOUNTS table
ALTER TABLE audit_logs
ADD CONSTRAINT fk_audit_account
FOREIGN KEY (account_id)
REFERENCES accounts(account_id);


/* ============================================================
   STEP 3: ADD BUSINESS RULE CONSTRAINT
   ============================================================ */

-- Restrict action type to valid operations
ALTER TABLE audit_logs
ADD CONSTRAINT chk_action_type
CHECK (action_type IN ('INSERT', 'UPDATE'));


/* ============================================================
   STEP 4: INSERT SAMPLE AUDIT DATA
   ============================================================ */

-- Example: Balance updated after withdrawal/transfer
INSERT INTO audit_logs (
    audit_id, 
    account_id, 
    old_balance, 
    new_balance, 
    action_type
) 
VALUES (
    1, 
    101, 
    5000, 
    4500, 
    'UPDATE'
);


/* ============================================================
   STEP 5: COMMIT TRANSACTION
   ============================================================ */

-- Persist audit record (critical for compliance & traceability)
COMMIT;


/* ============================================================
   STEP 6: VERIFY DATA
   ============================================================ */

-- Retrieve all audit records
SELECT * FROM audit_logs;
