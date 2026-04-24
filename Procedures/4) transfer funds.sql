/* ============================================================
   MODULE:       Core Banking - Fund Transfer (With Locking)
   OBJECT:       TRANSFER_FUNDS
   DESCRIPTION:  Transfers amount between two accounts using
                 row-level locking to prevent race conditions
   ============================================================ */

create or replace PROCEDURE transfer_funds (
    p_from_account IN NUMBER,
    p_to_account   IN NUMBER,
    p_amount       IN NUMBER
)
IS
    v_balance NUMBER;
BEGIN
    -- Step 1: Validate accounts are different
    IF p_from_account = p_to_account THEN
        RAISE_APPLICATION_ERROR(-20003, 'Sender and receiver cannot be same');
    END IF;

    -- Step 2: Validate amount
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid transfer amount');
    END IF;

    -- Step 3: Lock accounts
    IF p_from_account < p_to_account THEN
        SELECT balance INTO v_balance
        FROM accounts
        WHERE account_id = p_from_account
        FOR UPDATE;

        SELECT balance INTO v_balance
        FROM accounts
        WHERE account_id = p_to_account
        FOR UPDATE;
    ELSE
        SELECT balance INTO v_balance
        FROM accounts
        WHERE account_id = p_to_account
        FOR UPDATE;

        SELECT balance INTO v_balance
        FROM accounts
        WHERE account_id = p_from_account
        FOR UPDATE;
    END IF;

    -- Step 5: SAVEPOINT
    SAVEPOINT before_transaction;
    
    -- Step 4: Check sender balance
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_from_account;

    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient balance');
    END IF;


    -- Step 6: Debit sender
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account;

    -- Step 7: Credit receiver
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;

    -- Step 8: Insert transaction
    INSERT INTO transactions (
        txn_id,
        from_account,
        to_account,
        amount,
        txn_type,
        status
    ) VALUES (
        transactions_seq.NEXTVAL,
        p_from_account,
        p_to_account,
        p_amount,
        'TRANSFER',
        'SUCCESS'
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Transfer successful');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        log_error('Invalid account', 'TRANSFER_FUNDS', p_from_account);
        RAISE_APPLICATION_ERROR(-20001, 'Invalid account');

    WHEN OTHERS THEN
        ROLLBACK TO before_transaction;
        log_error(SQLERRM, 'TRANSFER_FUNDS', p_from_account);
        RAISE_APPLICATION_ERROR(-20005, 'System error: ' || SQLERRM);
END;
/* ============================================================
   TEST CASE 1: VALID TRANSFER
   ============================================================ */

BEGIN
    transfer_funds(101, 102, 500);
END;
/

/* ============================================================
   VERIFY BALANCES
   ============================================================ */

SELECT balance FROM accounts WHERE account_id = 101;
/
SELECT balance FROM accounts WHERE account_id = 102;
/

/* ============================================================
   VERIFY TRANSACTION ENTRY
   ============================================================ */

SELECT * FROM transactions 
WHERE txn_type = 'TRANSFER';
/

/* ============================================================
   TEST CASE 2: INSUFFICIENT BALANCE (SHOULD FAIL)
   ============================================================ */

BEGIN
    transfer_funds(101, 102, 9999999);
END;
/

/* ============================================================
   TEST CASE 3: INVALID ACCOUNT (SHOULD FAIL)
   ============================================================ */

BEGIN
    transfer_funds(999, 102, 500);
END;
/
select * from error_logs ;