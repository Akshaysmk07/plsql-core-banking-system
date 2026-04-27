/* ============================================================
   MODULE:       Core Banking - Deposit Procedure
   OBJECT:       DEPOSIT
   DESCRIPTION:  Adds amount to account with production-grade
                 validation and exception handling
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE PROCEDURE
   ============================================================ */

CREATE OR REPLACE PROCEDURE deposit (
    p_account_id   IN NUMBER,
    p_amount       IN NUMBER
)
IS
    -- Variable to store account status
    v_status accounts.status%TYPE;

    -- Transaction ID for linking ledger
    v_txn_id NUMBER;
BEGIN
    /* ----------------------------------------------------------
       STEP 1: INPUT VALIDATION
       ---------------------------------------------------------- */

    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Account ID cannot be NULL');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Deposit amount must be greater than zero');
    END IF;


    /* ----------------------------------------------------------
       STEP 2: FETCH ACCOUNT STATUS
       ---------------------------------------------------------- */

    SELECT status
    INTO v_status
    FROM accounts
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 3: VALIDATE STATUS
       ---------------------------------------------------------- */

    IF v_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20022, 'Account is not ACTIVE');
    END IF;


    /* ----------------------------------------------------------
       STEP 4: UPDATE BALANCE
       ---------------------------------------------------------- */

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 5: INSERT TRANSACTION
       ---------------------------------------------------------- */

    v_txn_id := transactions_seq.NEXTVAL;

    INSERT INTO transactions (
        txn_id,
        from_account,
        to_account,
        amount,
        txn_type,
        txn_channel,
        charge_amount,
        status
    ) VALUES (
        v_txn_id,
        NULL,
        p_account_id,
        p_amount,
        'DEPOSIT',
        'CASH',        -- or SYSTEM / UPI based on design
        0,
        'SUCCESS'
    );


    /* ----------------------------------------------------------
       STEP 6: INSERT LEDGER ENTRY 
       ---------------------------------------------------------- */

    INSERT INTO ledger_entries (
        ledger_id,
        account_id,
        txn_id,
        entry_type,
        amount
    ) VALUES (
        ledger_seq.NEXTVAL,
        p_account_id,
        v_txn_id,
        'CREDIT',
        p_amount
    );


    /* ----------------------------------------------------------
       STEP 7: COMMIT
       ---------------------------------------------------------- */

    COMMIT;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Account does not exist');

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20023, 'Deposit failed: ' || SQLERRM);
END;
/


/* ============================================================
   TEST SETUP
   ============================================================ */

-- Enable output display
SET SERVEROUTPUT ON;
/


/* ============================================================
   TEST CASE 1: VALID DEPOSIT
   ============================================================ */

-- Deposit into valid account
BEGIN
    deposit(301, 20000);
END;
/


/* ============================================================
   VERIFY BALANCE
   ============================================================ */

-- Check updated balance
SELECT balance FROM accounts WHERE account_id = 101;
/


/* ============================================================
   TEST CASE 2: INVALID ACCOUNT (SHOULD FAIL)
   ============================================================ */

-- Attempt deposit into non-existing account
BEGIN
    deposit(999, 1000);
END;
/


/* ============================================================
   TEST CASE 3: INACTIVE ACCOUNT (SHOULD FAIL)
   ============================================================ */

-- Set account status to INACTIVE
UPDATE accounts 
SET status = 'INACTIVE' 
WHERE account_id = 201;

-- Attempt deposit into inactive account
BEGIN
    deposit(201, 1000);
END;
/