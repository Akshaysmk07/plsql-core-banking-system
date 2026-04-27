CREATE OR REPLACE PROCEDURE daily_transactions
IS
    /* --------------------------------------------------------
       CURSOR: Fetch today's transactions
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

BEGIN
    /* --------------------------------------------------------
       STEP 1: LOOP USING CURSOR FOR LOOP (BEST PRACTICE)
       -------------------------------------------------------- */
    FOR v_txn IN txn_cursor LOOP

        DBMS_OUTPUT.PUT_LINE(
            'TxnID: ' || v_txn.txn_id ||
            ' | From: ' || NVL(TO_CHAR(v_txn.from_account), 'NULL') ||
            ' | To: ' || NVL(TO_CHAR(v_txn.to_account), 'NULL') ||
            ' | Amount: ' || v_txn.amount ||
            ' | Type: ' || v_txn.txn_type
        );

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN

        --  LOG ERROR (PRODUCTION)
        log_error(
            SQLERRM,
            'DAILY_TRANSACTIONS',
            NULL
        );

        -- Optional debug output
        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE || 
            ' | Message: ' || SQLERRM
        );
END;
/

SET SERVEROUTPUT ON;

BEGIN
    daily_transactions;
END;
/