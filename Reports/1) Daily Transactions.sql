/* ============================================================
   MODULE:       Core Banking - Daily Transaction Report
   OBJECT:       DAILY_TRANSACTIONS
   DESCRIPTION:  Retrieves and displays all transactions
                 performed on the current day using a cursor.
                 Intended for operational monitoring/reporting.
   AUTHOR:       Akshay
   ============================================================ */

CREATE OR REPLACE PROCEDURE daily_transactions
IS
    /* --------------------------------------------------------
       CURSOR: Fetch today's transactions
       Filters records where transaction date = current date
       -------------------------------------------------------- */
    CURSOR txn_cursor IS
        SELECT 
            txn_id, 
            from_account, 
            to_account, 
            amount, 
            txn_type, 
            txn_date
        FROM transactions
        WHERE TRUNC(txn_date) = TRUNC(SYSDATE);

    -- Variable to hold each row fetched from cursor
    v_txn txn_cursor%ROWTYPE;

BEGIN
    /* --------------------------------------------------------
       STEP 1: Open cursor
       -------------------------------------------------------- */
    OPEN txn_cursor;

    /* --------------------------------------------------------
       STEP 2: Loop through all records
       -------------------------------------------------------- */
    LOOP
        FETCH txn_cursor INTO v_txn;

        -- Exit loop when no more records
        EXIT WHEN txn_cursor%NOTFOUND;

        /* ----------------------------------------------------
           STEP 3: Display transaction details
           (Used for debugging / reporting in SQL Developer)
           ---------------------------------------------------- */
        DBMS_OUTPUT.PUT_LINE(
            'TxnID: ' || v_txn.txn_id ||
            ' | Amount: ' || v_txn.amount ||
            ' | Type: ' || v_txn.txn_type
        );

    END LOOP;

    /* --------------------------------------------------------
       STEP 4: Close cursor (important to release resources)
       -------------------------------------------------------- */
    CLOSE txn_cursor;

EXCEPTION
    /* --------------------------------------------------------
       EXCEPTION HANDLING
       -------------------------------------------------------- */

    -- Handle unexpected errors
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE || 
            ' | Message: ' || SQLERRM
        );

        -- Ensure cursor is closed even if error occurs
        IF txn_cursor%ISOPEN THEN
            CLOSE txn_cursor;
        END IF;
END;
/

SET SERVEROUTPUT ON;
/
BEGIN
    daily_transactions;
END;
/

