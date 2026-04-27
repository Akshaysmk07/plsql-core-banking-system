/* ============================================================
   MODULE:       Core Banking - Withdraw Procedure
   OBJECT:       WITHDRAW
   DESCRIPTION:  Deducts amount from account with production-grade
                 validation and exception handling
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE PROCEDURE
   ============================================================ */

CREATE OR REPLACE PROCEDURE withdraw (
    p_account_id   IN NUMBER,
    p_amount       IN NUMBER
)
IS
    -- Variable to store account balance
    v_balance NUMBER;

    -- Variable to store account status
    v_status  accounts.status%TYPE;
BEGIN
    /* ----------------------------------------------------------
       STEP 2: INPUT VALIDATION
       ---------------------------------------------------------- */

    -- Validate account ID
    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Account ID cannot be NULL');
    END IF;

    -- Validate withdrawal amount
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'Withdrawal amount must be greater than zero');
    END IF;


    /* ----------------------------------------------------------
       STEP 3: FETCH BALANCE AND STATUS
       ---------------------------------------------------------- */

    -- Retrieve account balance and status
    SELECT balance, status
    INTO v_balance, v_status
    FROM accounts
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 4: CHECK ACCOUNT STATUS
       ---------------------------------------------------------- */

    -- Ensure account is active
    IF v_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20032, 'Account is not ACTIVE');
    END IF;


    /* ----------------------------------------------------------
       STEP 5: CHECK SUFFICIENT BALANCE
       ---------------------------------------------------------- */

    -- Ensure sufficient funds are available
    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient balance');
    END IF;


    /* ----------------------------------------------------------
       STEP 6: UPDATE ACCOUNT BALANCE
       ---------------------------------------------------------- */

    -- Deduct withdrawal amount from balance
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 7: INSERT TRANSACTION RECORD
       ---------------------------------------------------------- */

    -- Log withdrawal transaction
    INSERT INTO transactions (
        txn_id,
        from_account,
        to_account,
        amount,
        txn_type,
        status
    ) VALUES (
        transactions_seq.NEXTVAL,
        p_account_id,
        NULL,
        p_amount,
        'WITHDRAW',
        'SUCCESS'
    );


    /* ----------------------------------------------------------
       STEP 8: COMMIT TRANSACTION
       ---------------------------------------------------------- */

    -- Persist changes (Durability - ACID property)
    COMMIT;


/* ============================================================
   STEP 9: EXCEPTION HANDLING
   ============================================================ */

EXCEPTION
    -- Handle case where account does not exist
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Account does not exist');

    -- Handle unexpected system errors
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20033, 'Withdrawal failed: ' || SQLERRM);
END;
/


/* ============================================================
   TEST CASE 1: VALID WITHDRAWAL
   ============================================================ */

-- Withdraw from valid account
BEGIN
    withdraw(101, 1000);
END;
/


/* ============================================================
   VERIFY BALANCE
   ============================================================ */

-- Check updated balance
SELECT balance FROM accounts WHERE account_id = 101;
/


/* ============================================================
   TEST CASE 2: INSUFFICIENT BALANCE (SHOULD FAIL)
   ============================================================ */

-- Attempt withdrawal exceeding balance
BEGIN
    withdraw(101, 999999);
END;
/


/* ============================================================
   TEST CASE 3: INVALID ACCOUNT (SHOULD FAIL)
   ============================================================ */

-- Attempt withdrawal from non-existing account
BEGIN
    withdraw(999, 500);
END;
/


/* ============================================================
   TEST CASE 4: INACTIVE ACCOUNT (SHOULD FAIL)
   ============================================================ */

-- Set account status to INACTIVE
UPDATE accounts 
SET status = 'INACTIVE' 
WHERE account_id = 201;

-- Attempt withdrawal from inactive account
BEGIN
    withdraw(201, 500);
END;
/