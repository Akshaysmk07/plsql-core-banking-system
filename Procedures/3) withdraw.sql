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
    -- Variables
    v_balance NUMBER;
    v_status  accounts.status%TYPE;

    -- Transaction ID
    v_txn_id NUMBER;
BEGIN
    /* ----------------------------------------------------------
       STEP 1: INPUT VALIDATION
       ---------------------------------------------------------- */

    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Account ID cannot be NULL');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'Withdrawal amount must be greater than zero');
    END IF;


    /* ----------------------------------------------------------
       STEP 2: FETCH BALANCE + STATUS
       ---------------------------------------------------------- */

    SELECT balance, status
    INTO v_balance, v_status
    FROM accounts
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 3: VALIDATE STATUS
       ---------------------------------------------------------- */

    IF v_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20032, 'Account is not ACTIVE');
    END IF;


    /* ----------------------------------------------------------
       STEP 4: CHECK BALANCE
       ---------------------------------------------------------- */

    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient balance');
    END IF;


    /* ----------------------------------------------------------
       STEP 5: UPDATE BALANCE
       ---------------------------------------------------------- */

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_account_id;


    /* ----------------------------------------------------------
       STEP 6: INSERT TRANSACTION
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
        p_account_id,
        NULL,
        p_amount,
        'WITHDRAW',
        'ATM',      -- or CASH / UPI depending on case
        0,
        'SUCCESS'
    );


    /* ----------------------------------------------------------
       STEP 7: INSERT LEDGER ENTRY 🔥
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
        'DEBIT',
        p_amount
    );


    /* ----------------------------------------------------------
       STEP 8: COMMIT
       ---------------------------------------------------------- */

    COMMIT;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Account does not exist');

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
    withdraw(301, 1000);
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