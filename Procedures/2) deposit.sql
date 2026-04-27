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
BEGIN
    /* ----------------------------------------------------------
       STEP 2: INPUT VALIDATION
       ---------------------------------------------------------- */

    -- Validate account ID
    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Account ID cannot be NULL');
    END IF;

    -- Validate deposit amount
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Deposit amount must be greater than zero');
    END IF;


    /* ----------------------------------------------------------
       STEP 3: FETCH ACCOUNT STATUS (VALIDATES EXISTENCE)
       ---------------------------------------------------------- */

    -- Retrieve account status
    SELECT status
    INTO v_status
    FROM accounts
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 4: CHECK ACCOUNT STATUS
       ---------------------------------------------------------- */

    -- Ensure account is active
    IF v_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20022, 'Account is not ACTIVE');
    END IF;


    /* ----------------------------------------------------------
       STEP 5: UPDATE ACCOUNT BALANCE
       ---------------------------------------------------------- */

    -- Add deposit amount to balance
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 6: INSERT TRANSACTION RECORD
       ---------------------------------------------------------- */

    -- Log deposit transaction
    INSERT INTO transactions (
        txn_id,
        from_account,
        to_account,
        amount,
        txn_type,
        status
    ) VALUES (
        transactions_seq.NEXTVAL,
        NULL,
        p_account_id,
        p_amount,
        'DEPOSIT',
        'SUCCESS'
    );


    /* ----------------------------------------------------------
       STEP 7: COMMIT TRANSACTION
       ---------------------------------------------------------- */

    -- Persist changes (Durability - ACID property)
    COMMIT;


/* ============================================================
   STEP 8: EXCEPTION HANDLING
   ============================================================ */

EXCEPTION
    -- Handle case where account does not exist
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Account does not exist');

    -- Handle unexpected system errors
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
    deposit(101, 2000);
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