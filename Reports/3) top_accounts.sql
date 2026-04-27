CREATE OR REPLACE PROCEDURE top_accounts
IS
    /* --------------------------------------------------------
       CURSOR: Fetch TOP 3 accounts directly (optimized)
       -------------------------------------------------------- */
    CURSOR acc_cursor IS
        SELECT 
            account_id,
            balance
        FROM accounts
        ORDER BY balance DESC
        FETCH FIRST 3 ROWS ONLY;

    v_count NUMBER := 0;

BEGIN
    /* --------------------------------------------------------
       STEP 1: CURSOR FOR LOOP
       -------------------------------------------------------- */
    FOR v_acc IN acc_cursor LOOP

        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            'Rank: ' || v_count ||
            ' | Account: ' || v_acc.account_id ||
            ' | Balance: ' || v_acc.balance
        );

    END LOOP;

    /* --------------------------------------------------------
       STEP 2: SUMMARY
       -------------------------------------------------------- */
    DBMS_OUTPUT.PUT_LINE('Total Accounts Displayed: ' || v_count);


EXCEPTION
    WHEN OTHERS THEN

        --  LOG ERROR (PRODUCTION)
        log_error(
            SQLERRM,
            'TOP_ACCOUNTS',
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
    top_accounts;
END;
/