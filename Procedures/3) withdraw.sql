

/* ============================================================
   MODULE:       Core Banking - Withdraw Procedure
   OBJECT:       WITHDRAW
   DESCRIPTION:  Deducts amount from account with production-grade
                 validation and exception handling
   ============================================================ */

CREATE OR REPLACE PROCEDURE withdraw (
    p_account_id   IN NUMBER,
    p_amount       IN NUMBER
)
IS
    v_balance NUMBER;
BEGIN
    -- Step 1: Input validations
    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Account ID cannot be NULL');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'Withdrawal amount must be greater than zero');
    END IF;

    -- Step 2: Get current balance
    SELECT balance
    INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id;

    -- Step 3: Check sufficient balance
    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient balance');
    END IF;

    -- Step 4: Deduct balance
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_account_id;

    -- Step 5: Insert transaction  
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

    -- Step 6: Commit
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Withdrawal successful');

EXCEPTION
    -- Account not found
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Account does not exist');

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
   TEST CASE 1: VALID WITHDRAWAL
   ============================================================ */

BEGIN
    withdraw(101, 1000);
END;
/

/* ============================================================
   VERIFY BALANCE
   ============================================================ */

SELECT balance FROM accounts WHERE account_id = 101;
/

/* ============================================================
   TEST CASE 2: INSUFFICIENT BALANCE (SHOULD FAIL)
   ============================================================ */

BEGIN
    withdraw(101, 999999);
END;
/

/* ============================================================
   TEST CASE 3: INVALID ACCOUNT (SHOULD FAIL)
   ============================================================ */

BEGIN
    withdraw(999, 500);
END;
/