/* ============================================================
   MODULE:       Core Banking - Account Creation Procedure
   OBJECT:       CREATE_ACCOUNT
   DESCRIPTION:  Inserts a new account into ACCOUNTS table
   AUTHOR:       Akshay
   ============================================================ */

/* ============================================================
   MODULE:       Core Banking - Account Creation Procedure
   OBJECT:       CREATE_ACCOUNT
   DESCRIPTION:  Inserts a new account with production-grade
                 exception handling and validation
   ============================================================ */

CREATE OR REPLACE PROCEDURE create_account (
    p_account_id      IN NUMBER,
    p_customer_name   IN VARCHAR2,
    p_initial_balance IN NUMBER,
    p_account_type    IN VARCHAR2
)
IS
BEGIN
    -- Step 1: Input validations
    IF p_account_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Account ID cannot be NULL');
    END IF;

    IF p_customer_name IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Customer name cannot be NULL');
    END IF;

    IF p_initial_balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Initial balance cannot be negative');
    END IF;

    IF p_account_type NOT IN ('SAVINGS', 'CURRENT') THEN
        RAISE_APPLICATION_ERROR(-20013, 'Invalid account type');
    END IF;

    -- Step 2: Insert new account
    INSERT INTO accounts (
        account_id,
        customer_name,
        balance,
        account_type
    )
    VALUES (
        p_account_id,
        p_customer_name,
        p_initial_balance,
        p_account_type
    );

    -- Step 3: Commit transaction
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Account created successfully');

EXCEPTION
    -- Duplicate account
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Account already exists');

    -- Check constraint violation
    WHEN VALUE_ERROR THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Invalid data format');

    -- Any unexpected error
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE || ' | Message: ' || SQLERRM
        );
END;
/


/* ============================================================
   TEST BLOCK: Execute Procedure
   ============================================================ */

BEGIN
    create_account(102, 'Rahul', 3000, 'SAVINGS');
END;
/