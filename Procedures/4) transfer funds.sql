/* ============================================================
   MODULE:       Core Banking - Fund Transfer
   OBJECT:       TRANSFER_FUNDS
   DESCRIPTION:  Transfers funds between accounts with support
                 for transaction types (UPI / IMPS / NEFT),
                 limit validation, locking, and error handling
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


CREATE OR REPLACE PROCEDURE transfer_funds (
    p_from_account IN NUMBER,
    p_to_account   IN NUMBER,
    p_amount       IN NUMBER,
    p_txn_type     IN VARCHAR2
)
IS
    v_balance         NUMBER;
    v_limit           NUMBER;
    v_charge          NUMBER;  
    v_sender_status   VARCHAR2(10);
    v_receiver_status VARCHAR2(10);
BEGIN
    /* ----------------------------------------------------------
       STEP 1: BASIC VALIDATION
       ---------------------------------------------------------- */

    IF p_from_account = p_to_account THEN
        RAISE_APPLICATION_ERROR(-20003, 'Sender and receiver cannot be same');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid transfer amount');
    END IF;

    /* ----------------------------------------------------------
       STEP 2: SAVEPOINT
       ---------------------------------------------------------- */
    SAVEPOINT before_transaction;

    /* ----------------------------------------------------------
       STEP 3: FETCH TRANSACTION LIMIT
       ---------------------------------------------------------- */
    SELECT max_limit INTO v_limit
    FROM transaction_types
    WHERE txn_type = p_txn_type;

    /* ----------------------------------------------------------
       STEP 4: VALIDATE LIMIT
       ---------------------------------------------------------- */
    IF p_amount > v_limit THEN
        RAISE_APPLICATION_ERROR(-20042, 'Exceeds limit for ' || p_txn_type);
    END IF;

    /* ----------------------------------------------------------
       STEP 5: LOCK ACCOUNTS (ORDERED)
       ---------------------------------------------------------- */
    IF p_from_account < p_to_account THEN

        SELECT balance, status INTO v_balance, v_sender_status
        FROM accounts
        WHERE account_id = p_from_account
        FOR UPDATE;

        SELECT status INTO v_receiver_status
        FROM accounts
        WHERE account_id = p_to_account
        FOR UPDATE;

    ELSE

        SELECT status INTO v_receiver_status
        FROM accounts
        WHERE account_id = p_to_account
        FOR UPDATE;

        SELECT balance, status INTO v_balance, v_sender_status
        FROM accounts
        WHERE account_id = p_from_account
        FOR UPDATE;

    END IF;

    /* ----------------------------------------------------------
       STEP 6: STATUS VALIDATION
       ---------------------------------------------------------- */

    IF v_sender_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20043, 'Sender account is not ACTIVE');
    END IF;

    IF v_receiver_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20044, 'Receiver account is not ACTIVE');
    END IF;

    /* ----------------------------------------------------------
       STEP 7: FETCH CHARGES
       ---------------------------------------------------------- */

    SELECT charge_amount INTO v_charge
    FROM transaction_charges
    WHERE txn_channel = p_txn_type;

    /* ----------------------------------------------------------
       STEP 8: BALANCE CHECK (INCLUDING CHARGES)
       ---------------------------------------------------------- */

    IF v_balance < (p_amount + v_charge) THEN
        RAISE_APPLICATION_ERROR(-20045, 'Insufficient balance including charges');
    END IF;

    /* ----------------------------------------------------------
       STEP 9: DEBIT SENDER
       ---------------------------------------------------------- */

    UPDATE accounts
    SET balance = balance - (p_amount + v_charge)
    WHERE account_id = p_from_account;

    /* ----------------------------------------------------------
       STEP 10: CREDIT RECEIVER
       ---------------------------------------------------------- */

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;

    /* ----------------------------------------------------------
       STEP 11: INSERT TRANSACTION
       ---------------------------------------------------------- */

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
        transactions_seq.NEXTVAL,
        p_from_account,
        p_to_account,
        p_amount,
        'TRANSFER',
        p_txn_type,
        v_charge,
        'SUCCESS'
    );
    -- 🔹 Sender ledger entry
    INSERT INTO ledger_entries (
        ledger_id,
        account_id,
        txn_id,
        entry_type,
        amount
    ) VALUES (
        ledger_seq.NEXTVAL,
        p_from_account,
        transactions_seq.CURRVAL,
        'DEBIT',
        p_amount + v_charge
    );

    -- 🔹 Receiver ledger entry
    INSERT INTO ledger_entries (
        ledger_id,
        account_id,
        txn_id,
        entry_type,
        amount
    ) VALUES (
        ledger_seq.NEXTVAL,
        p_to_account,
        transactions_seq.CURRVAL,
        'CREDIT',
        p_amount
    );
    /* ----------------------------------------------------------
       STEP 12: COMMIT
       ---------------------------------------------------------- */
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        log_error('Invalid account or txn type', 'TRANSFER_FUNDS', p_from_account);
        RAISE_APPLICATION_ERROR(-20001, 'Invalid account or transaction type');

    WHEN OTHERS THEN
        ROLLBACK TO before_transaction;
        log_error(SQLERRM, 'TRANSFER_FUNDS', p_from_account);
        RAISE_APPLICATION_ERROR(-20005, 'System error: ' || SQLERRM);
END;
/

/* ============================================================
   TEST CASE 1: VALID UPI TRANSFER
   ============================================================ */
BEGIN
    transfer_funds(201, 202, 500, 'UPI');
END;
/

/* ============================================================
   TEST CASE 2: LIMIT EXCEEDED (UPI)
   ============================================================ */
BEGIN
    transfer_funds(201, 202, 200000, 'UPI');
END;
/

/* ============================================================
   TEST CASE 3: INVALID TRANSACTION TYPE
   ============================================================ */
BEGIN
    transfer_funds(201, 202, 5000, 'XYZ');
END;
/

/* ============================================================
   TEST CASE 4: INACTIVE ACCOUNT
   ============================================================ */
UPDATE accounts SET status = 'INACTIVE' WHERE account_id = 201;

BEGIN
    transfer_funds(201, 202, 1000, 'IMPS');
END;
/

/* ============================================================
   RESET ACCOUNT STATUS
   ============================================================ */
UPDATE accounts SET status = 'ACTIVE' WHERE account_id = 201;
COMMIT;


/* ============================================================
   TEST CASE 5: VALID TRANSFER (IMPS)
   ============================================================ */
BEGIN
    transfer_funds(101, 102, 500, 'IMPS');
END;
/

/* ============================================================
   VERIFY BALANCES
   ============================================================ */
SELECT account_id, balance FROM accounts 
WHERE account_id IN (101, 102);
/

/* ============================================================
   VERIFY TRANSACTION ENTRY
   ============================================================ */
SELECT * FROM transactions 
WHERE txn_channel IN ('UPI','IMPS','NEFT');
/

/* ============================================================
   TEST CASE 6: INSUFFICIENT BALANCE
   ============================================================ */
BEGIN
    transfer_funds(101, 102, 9999999, 'NEFT');
END;
/

/* ============================================================
   TEST CASE 7: INVALID ACCOUNT
   ============================================================ */
BEGIN
    transfer_funds(999, 102, 500, 'IMPS');
END;
/

/* ============================================================
   VERIFY ERROR LOGS
   ============================================================ */
SELECT * FROM error_logs;
/