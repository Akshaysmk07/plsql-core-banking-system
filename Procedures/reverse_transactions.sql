/* ============================================================
   MODULE:       Core Banking - Transaction Reversal
   OBJECT:       REVERSE_TRANSACTION
   DESCRIPTION:  Reverses a successful transaction by:
                 - Validating transaction existence
                 - Preventing duplicate reversal
                 - Locking accounts (deadlock-safe)
                 - Reverting balances (including charges)
                 - Marking original transaction as REVERSED
                 - Creating reversal audit entry
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE PROCEDURE
   ============================================================ */

CREATE OR REPLACE PROCEDURE reverse_transaction (
    p_txn_id IN NUMBER
)
IS
    -- Source account of original transaction
    v_from_account NUMBER;

    -- Destination account of original transaction
    v_to_account   NUMBER;

    -- Transaction amount
    v_amount       NUMBER;

    -- Transaction charge applied
    v_charge       NUMBER;

    -- Transaction channel (UPI / IMPS / NEFT)
    v_channel      VARCHAR2(20);

    -- Transaction status (SUCCESS / REVERSED)
    v_status       VARCHAR2(20);

    -- Dummy variable for row locking
    v_dummy        NUMBER;

BEGIN
    /* ----------------------------------------------------------
       STEP 2: FETCH ORIGINAL TRANSACTION DETAILS
       ---------------------------------------------------------- */

    -- Retrieve transaction data
    SELECT from_account, to_account, amount, charge_amount, txn_channel, status
    INTO v_from_account, v_to_account, v_amount, v_charge, v_channel, v_status
    FROM transactions
    WHERE txn_id = p_txn_id;


    /* ----------------------------------------------------------
       STEP 3: PREVENT MULTIPLE REVERSALS
       ---------------------------------------------------------- */

    -- Ensure transaction is not already reversed
    IF v_status = 'REVERSED' THEN
        RAISE_APPLICATION_ERROR(-20060, 'Transaction already reversed');
    END IF;


    /* ----------------------------------------------------------
       STEP 4: LOCK ACCOUNTS (DEADLOCK PREVENTION)
       ---------------------------------------------------------- */

    -- Lock accounts in deterministic order
    IF v_from_account < v_to_account THEN

        -- Lock sender account
        SELECT 1 INTO v_dummy FROM accounts
        WHERE account_id = v_from_account FOR UPDATE;

        -- Lock receiver account
        SELECT 1 INTO v_dummy FROM accounts
        WHERE account_id = v_to_account FOR UPDATE;

    ELSE

        -- Lock receiver first
        SELECT 1 INTO v_dummy FROM accounts
        WHERE account_id = v_to_account FOR UPDATE;

        -- Lock sender
        SELECT 1 INTO v_dummy FROM accounts
        WHERE account_id = v_from_account FOR UPDATE;

    END IF;


    /* ----------------------------------------------------------
       STEP 5: REVERSE ACCOUNT BALANCES
       ---------------------------------------------------------- */

    -- Refund sender (amount + charge)
    UPDATE accounts
    SET balance = balance + (v_amount + v_charge)
    WHERE account_id = v_from_account;

    -- Deduct amount from receiver
    UPDATE accounts
    SET balance = balance - v_amount
    WHERE account_id = v_to_account;


    /* ----------------------------------------------------------
       STEP 6: MARK ORIGINAL TRANSACTION AS REVERSED
       ---------------------------------------------------------- */

    UPDATE transactions
    SET status = 'REVERSED'
    WHERE txn_id = p_txn_id;


    /* ----------------------------------------------------------
       STEP 7: INSERT REVERSAL TRANSACTION ENTRY
       ---------------------------------------------------------- */

    -- Log reversal for audit trail
    INSERT INTO transactions (
        txn_id,
        from_account,
        to_account,
        amount,
        txn_type,
        txn_channel,
        charge_amount,
        reference_txn_id,
        txn_direction,
        status
    ) VALUES (
        transactions_seq.NEXTVAL,
        v_to_account,
        v_from_account,
        v_amount,
        'REVERSAL',
        v_channel,
        v_charge,
        p_txn_id,
        'CREDIT',
        'SUCCESS'
    );
   -- Reverse: sender gets money back (CREDIT)
   INSERT INTO ledger_entries (
      ledger_id,
      account_id,
      txn_id,
      entry_type,
      amount
   ) VALUES (
      ledger_seq.NEXTVAL,
      v_from_account,
      transactions_seq.CURRVAL,
      'CREDIT',
      v_amount + v_charge
   );

   -- Reverse: receiver loses money (DEBIT)
   INSERT INTO ledger_entries (
      ledger_id,
      account_id,
      txn_id,
      entry_type,
      amount
   ) VALUES (
      ledger_seq.NEXTVAL,
      v_to_account,
      transactions_seq.CURRVAL,
      'DEBIT',
      v_amount
   );

    /* ----------------------------------------------------------
       STEP 8: COMMIT TRANSACTION
       ---------------------------------------------------------- */

    -- Persist changes (ACID - Durability)
    COMMIT;


/* ============================================================
   STEP 9: EXCEPTION HANDLING
   ============================================================ */

EXCEPTION
    -- Handle invalid transaction ID
    WHEN NO_DATA_FOUND THEN

        --  LOG BUSINESS ERROR
        log_error(
            'Transaction not found for reversal',
            'REVERSE_TRANSACTION',
            p_txn_id
        );

        RAISE_APPLICATION_ERROR(-20050, 'Transaction not found');

    -- Handle unexpected system errors
    WHEN OTHERS THEN
        ROLLBACK;

        --  LOG SYSTEM ERROR
        log_error(
            SQLERRM,
            'REVERSE_TRANSACTION',
            p_txn_id
        );

        RAISE_APPLICATION_ERROR(-20051, 'Reversal failed: ' || SQLERRM);
END;
/


/* ============================================================
   TEST CASE 1: CREATE A TRANSACTION
   ============================================================ */

-- Perform a sample transfer
BEGIN
    transfer_funds(101, 201, 100, 'IMPS');
END;
/

/* ============================================================
   VERIFY ORIGINAL TRANSACTION
   ============================================================ */

-- Retrieve latest transactions
SELECT * FROM transactions ORDER BY txn_id DESC;
/

/* ============================================================
   TEST CASE 2: VALID REVERSAL
   ============================================================ */

-- Replace with actual txn_id
BEGIN
    reverse_transaction(74);
END;
/

/* ============================================================
   TEST CASE 3: DUPLICATE REVERSAL (SHOULD FAIL)
   ============================================================ */

BEGIN
    reverse_transaction(51);
END;
/

/* ============================================================
   TEST CASE 4: INVALID TRANSACTION ID
   ============================================================ */

BEGIN
    reverse_transaction(9999);
END;
/

/* ============================================================
   VERIFY FINAL STATE
   ============================================================ */

-- Check all transactions including reversal
SELECT * FROM transactions ORDER BY txn_id DESC;
/