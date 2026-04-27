/* ============================================================
   MODULE:       Core Banking - Account Creation
   OBJECT:       PROCEDURE create_account
   DESCRIPTION:  Creates a new account for an existing customer
                 with validation and error handling.
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE PROCEDURE
   ============================================================ */

CREATE OR REPLACE PROCEDURE create_account (
    p_account_id      IN NUMBER,
    p_customer_id     IN NUMBER,
    p_initial_balance IN NUMBER,
    p_account_type    IN VARCHAR2
)
IS
    -- Variable to check customer existence
    v_count NUMBER;

    -- Transaction ID for linking ledger
    v_txn_id NUMBER;
BEGIN
    /* ----------------------------------------------------------
       STEP 1: INPUT VALIDATION
       ---------------------------------------------------------- */

    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Account ID cannot be NULL');
    END IF;

    IF p_customer_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Customer ID cannot be NULL');
    END IF;

    IF p_initial_balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Initial balance cannot be negative');
    END IF;

    IF p_account_type NOT IN ('SAVINGS', 'CURRENT') THEN
        RAISE_APPLICATION_ERROR(-20013, 'Invalid account type');
    END IF;


    /* ----------------------------------------------------------
       STEP 2: CHECK CUSTOMER EXISTENCE
       ---------------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_count
    FROM customers
    WHERE customer_id = p_customer_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Customer does not exist');
    END IF;


    /* ----------------------------------------------------------
       STEP 3: INSERT ACCOUNT
       ---------------------------------------------------------- */

    INSERT INTO accounts (
        account_id,
        customer_id,
        balance,
        account_type
    )
    VALUES (
        p_account_id,
        p_customer_id,
        p_initial_balance,
        p_account_type
    );


    /* ----------------------------------------------------------
       STEP 4: CREATE OPENING TRANSACTION
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
        p_initial_balance,
        'DEPOSIT',       -- opening treated as deposit
        'SYSTEM',
        0,
        'SUCCESS'
    );


    /* ----------------------------------------------------------
       STEP 5: LEDGER ENTRY (OPENING BALANCE) 🔥
       ---------------------------------------------------------- */

    IF p_initial_balance > 0 THEN
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
            p_initial_balance
        );
    END IF;


    /* ----------------------------------------------------------
       STEP 6: COMMIT
       ---------------------------------------------------------- */

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Account created successfully with ledger');


EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20015, 'Account already exists');

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20016, 'System error: ' || SQLERRM);
END;
/


/* ============================================================
   STEP 7: EXECUTE PROCEDURE (TEST CASE)
   ============================================================ */

-- Create a sample account
BEGIN
    create_account(301, 1, 5000, 'SAVINGS');
END;
/

BEGIN
    create_account(304, 2, 1000, 'SAVINGS');
END;
/


/* ============================================================
   STEP 8: VERIFY DATA
   ============================================================ */

-- Retrieve all account records
SELECT * FROM accounts;