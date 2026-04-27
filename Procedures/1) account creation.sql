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
BEGIN
    /* ----------------------------------------------------------
       STEP 2: INPUT VALIDATION
       ---------------------------------------------------------- */

    -- Validate account ID
    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Account ID cannot be NULL');
    END IF;

    -- Validate customer ID
    IF p_customer_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Customer ID cannot be NULL');
    END IF;

    -- Validate initial balance
    IF p_initial_balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Initial balance cannot be negative');
    END IF;

    -- Validate account type
    IF p_account_type NOT IN ('SAVINGS', 'CURRENT') THEN
        RAISE_APPLICATION_ERROR(-20013, 'Invalid account type');
    END IF;


    /* ----------------------------------------------------------
       STEP 3: CHECK CUSTOMER EXISTENCE
       ---------------------------------------------------------- */

    -- Verify if customer exists in customers table
    SELECT COUNT(*)
    INTO v_count
    FROM customers
    WHERE customer_id = p_customer_id;

    -- Raise error if customer not found
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Customer does not exist');
    END IF;


    /* ----------------------------------------------------------
       STEP 4: INSERT ACCOUNT RECORD
       ---------------------------------------------------------- */

    -- Insert new account into accounts table
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
       STEP 5: COMMIT TRANSACTION
       ---------------------------------------------------------- */

    -- Persist changes (Durability - ACID property)
    COMMIT;

    -- Confirmation message
    DBMS_OUTPUT.PUT_LINE('Account created successfully (V2)');


/* ============================================================
   STEP 6: EXCEPTION HANDLING
   ============================================================ */

EXCEPTION
    -- Handle duplicate account ID
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20015, 'Account already exists');

    -- Handle unexpected system errors
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
    create_account(302, 1, 1000, 'SAVINGS');
END;
/


/* ============================================================
   STEP 8: VERIFY DATA
   ============================================================ */

-- Retrieve all account records
SELECT * FROM accounts;