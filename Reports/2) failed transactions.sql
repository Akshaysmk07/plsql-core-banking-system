CREATE OR REPLACE PROCEDURE failed_transactions
IS
    /* --------------------------------------------------------
       CURSOR: Fetch failed transactions
       -------------------------------------------------------- */
    CURSOR fail_cursor IS
        SELECT 
            txn_id, 
            from_account,
            to_account,
            amount, 
            txn_type
        FROM transactions
        WHERE status = 'FAILED';

    v_count NUMBER := 0;

BEGIN
    /* --------------------------------------------------------
       STEP 1: CURSOR FOR LOOP (BEST PRACTICE)
       -------------------------------------------------------- */
    FOR v_txn IN fail_cursor LOOP

        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            'TxnID: ' || v_txn.txn_id ||
            ' | From: ' || NVL(TO_CHAR(v_txn.from_account), 'NULL') ||
            ' | To: ' || NVL(TO_CHAR(v_txn.to_account), 'NULL') ||
            ' | Amount: ' || v_txn.amount ||
            ' | Type: ' || v_txn.txn_type
        );

    END LOOP;

    /* --------------------------------------------------------
       STEP 2: SUMMARY
       -------------------------------------------------------- */
    DBMS_OUTPUT.PUT_LINE('Total Failed Transactions: ' || v_count);


EXCEPTION
    WHEN OTHERS THEN

        --  LOG ERROR (PRODUCTION)
        log_error(
            SQLERRM,
            'FAILED_TRANSACTIONS',
            NULL
        );

        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE ||
            ' | Message: ' || SQLERRM
        );
END;
/


SET SERVEROUTPUT ON;

BEGIN
    failed_transactions;
END;
/