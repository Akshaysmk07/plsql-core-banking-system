

/* ============================================================
   MODULE:       Core Banking - Deposit Procedure
   OBJECT:       DEPOSIT
   DESCRIPTION:  Adds amount to account with production-grade
                 validation and exception handling
   ============================================================ */

CREATE OR REPLACE PROCEDURE deposit (
    p_account_id   IN NUMBER,
    p_amount       IN NUMBER
)
IS
    v_count NUMBER;
BEGIN
    -- Step 1: Input validations
    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Account ID cannot be NULL');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Deposit amount must be greater than zero');
    END IF;

    -- Step 2: Check if account exists
    SELECT COUNT(*)
    INTO v_count
    FROM accounts
    WHERE account_id = p_account_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Account does not exist');
    END IF;

    -- Step 3: Update balance
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    -- Step 4: Insert transaction record
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

    -- Step 5: Commit
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Deposit successful');

EXCEPTION
    -- No data found (extra safety)
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Account not found');

    -- Invalid numeric / conversion issues
    WHEN VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid input format');

    -- Any unexpected error
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE || ' | Message: ' || SQLERRM
        );
END;
/

/* ============================================================
   TEST SETUP
   ============================================================ */

SET SERVEROUTPUT ON;
/

/* ============================================================
   TEST CASE 1: VALID DEPOSIT
   ============================================================ */

BEGIN
    deposit(101, 2000);
END;
/

/* ============================================================
   VERIFY BALANCE
   ============================================================ */

SELECT balance FROM accounts WHERE account_id = 101;
/

/* ============================================================
   TEST CASE 2: INVALID ACCOUNT (SHOULD FAIL)
   ============================================================ */

BEGIN
    deposit(999, 1000);
END;
/