/* ============================================================
   MODULE:       Core Banking - Transaction Reversal
   OBJECT:       REVERSE_TRANSACTION
   DESCRIPTION:  Reverses a successful transaction by restoring
                 balances and creating a reversal entry with
                 reference to original transaction
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
    -- Original transaction details
    v_from_account NUMBER;
    v_to_account   NUMBER;
    v_amount       NUMBER;
    v_charge       NUMBER;
    v_channel      VARCHAR2(20);

    -- Dummy variable for locking
    v_dummy        NUMBER;   
BEGIN
    /* ----------------------------------------------------------
       STEP 2: FETCH ORIGINAL TRANSACTION
       ---------------------------------------------------------- */

    -- Retrieve transaction details
    SELECT from_account, to_account, amount, charge_amount, txn_channel
    INTO v_from_account, v_to_account, v_amount, v_charge, v_channel
    FROM transactions
    WHERE txn_id = p_txn_id;


    /* ----------------------------------------------------------
       STEP 3: LOCK ACCOUNTS (DEADLOCK PREVENTION)
       ---------------------------------------------------------- */

    -- Lock accounts in consistent order
    IF v_from_account < v_to_account THEN

        -- Lock sender
        SELECT 1 INTO v_dummy FROM accounts 
        WHERE account_id = v_from_account FOR UPDATE;

        -- Lock receiver
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
       STEP 4: REVERSE BALANCES
       ---------------------------------------------------------- */

    -- Credit back sender (including charge refund)
    UPDATE accounts
    SET balance = balance + (v_amount + v_charge)
    WHERE account_id = v_from_account;

    -- Debit receiver
    UPDATE accounts
    SET balance = balance - v_amount
    WHERE account_id = v_to_account;


    /* ----------------------------------------------------------
       STEP 5: INSERT REVERSAL TRANSACTION
       ---------------------------------------------------------- */

    -- Log reversal entry
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


    /* ----------------------------------------------------------
       STEP 6: COMMIT TRANSACTION
       ---------------------------------------------------------- */

    -- Persist reversal (Durability - ACID property)
    COMMIT;


/* ============================================================
   STEP 7: EXCEPTION HANDLING
   ============================================================ */

EXCEPTION
    -- Transaction not found
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20050, 'Transaction not found');

    -- System errors
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20051, 'Reversal failed: ' || SQLERRM);
END;
/


/* ============================================================
   TEST CASE 1: CREATE A TRANSACTION
   ============================================================ */

-- Perform a sample transfer
BEGIN
    transfer_funds(201, 202, 10, 'IMPS');
END;
/

/* ============================================================
   VERIFY ORIGINAL TRANSACTION
   ============================================================ */

-- Check latest transactions
SELECT * FROM transactions ORDER BY txn_id DESC;
/

/* ============================================================
   TEST CASE 2: REVERSE TRANSACTION
   ============================================================ */

-- Replace 47 with actual txn_id
BEGIN
    reverse_transaction(47);
END;
/

/* ============================================================
   VERIFY REVERSAL ENTRY
   ============================================================ */

-- Check reversal entry
SELECT * FROM transactions ORDER BY txn_id DESC;
/