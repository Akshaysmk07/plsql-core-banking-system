/* ============================================================
   MODULE:       Core Banking - Failed Transaction Report
   OBJECT:       FAILED_TRANSACTIONS
   DESCRIPTION:  Retrieves and displays all failed transactions.
                 Useful for monitoring, reconciliation, and debugging.
   AUTHOR:       Akshay
   ============================================================ */

CREATE OR REPLACE PROCEDURE failed_transactions
IS
    /* --------------------------------------------------------
       CURSOR: Fetch all failed transactions
       -------------------------------------------------------- */
    CURSOR fail_cursor IS
        SELECT 
            txn_id, 
            amount, 
            txn_type
        FROM transactions
        WHERE status = 'FAILED';

    -- Variable to hold each fetched row
    v_txn fail_cursor%ROWTYPE;

    -- Counter to track number of failed transactions
    v_count NUMBER := 0;

BEGIN
    /* --------------------------------------------------------
       STEP 1: Open cursor
       -------------------------------------------------------- */
    OPEN fail_cursor;

    /* --------------------------------------------------------
       STEP 2: Iterate through results
       -------------------------------------------------------- */
    LOOP
        FETCH fail_cursor INTO v_txn;
        EXIT WHEN fail_cursor%NOTFOUND;

        v_count := v_count + 1;

        /* ----------------------------------------------------
           STEP 3: Display transaction details
           ---------------------------------------------------- */
        DBMS_OUTPUT.PUT_LINE(
            'TxnID: ' || v_txn.txn_id ||
            ' | Amount: ' || v_txn.amount ||
            ' | Type: ' || v_txn.txn_type
        );
    END LOOP;

    /* --------------------------------------------------------
       STEP 4: Close cursor
       -------------------------------------------------------- */
    CLOSE fail_cursor;

    /* --------------------------------------------------------
       STEP 5: Summary output
       -------------------------------------------------------- */
    DBMS_OUTPUT.PUT_LINE('Total Failed Transactions: ' || v_count);

EXCEPTION
    /* --------------------------------------------------------
       EXCEPTION HANDLING
       -------------------------------------------------------- */

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE ||
            ' | Message: ' || SQLERRM
        );

        -- Ensure cursor is closed in case of error
        IF fail_cursor%ISOPEN THEN
            CLOSE fail_cursor;
        END IF;
END;
/


BEGIN
    failed_transactions;
END;
/