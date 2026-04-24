/* ============================================================
   MODULE:       Core Banking - Top Accounts Report
   OBJECT:       TOP_ACCOUNTS
   DESCRIPTION:  Retrieves top 3 accounts based on highest balance.
                 Useful for reporting, analytics, and monitoring.
   AUTHOR:       Akshay
   ============================================================ */

CREATE OR REPLACE PROCEDURE top_accounts
IS
    /* --------------------------------------------------------
       CURSOR: Fetch accounts ordered by balance (highest first)
       -------------------------------------------------------- */
    CURSOR acc_cursor IS
        SELECT 
            account_id, 
            customer_name, 
            balance
        FROM accounts
        ORDER BY balance DESC;

    -- Variable to hold each fetched row
    v_acc acc_cursor%ROWTYPE;

    -- Counter to limit output to top 3 accounts
    v_count NUMBER := 0;

BEGIN
    /* --------------------------------------------------------
       STEP 1: Open cursor
       -------------------------------------------------------- */
    OPEN acc_cursor;

    /* --------------------------------------------------------
       STEP 2: Loop through results (limit to top 3)
       -------------------------------------------------------- */
    LOOP
        FETCH acc_cursor INTO v_acc;

        -- Exit when no more records or top 3 reached
        EXIT WHEN acc_cursor%NOTFOUND OR v_count = 3;

        v_count := v_count + 1;

        /* ----------------------------------------------------
           STEP 3: Display account details
           ---------------------------------------------------- */
        DBMS_OUTPUT.PUT_LINE(
            'Rank: ' || v_count ||
            ' | Account: ' || v_acc.account_id ||
            ' | Name: ' || v_acc.customer_name ||
            ' | Balance: ' || v_acc.balance
        );
    END LOOP;

    /* --------------------------------------------------------
       STEP 4: Close cursor
       -------------------------------------------------------- */
    CLOSE acc_cursor;

    /* --------------------------------------------------------
       STEP 5: Summary output
       -------------------------------------------------------- */
    DBMS_OUTPUT.PUT_LINE('Total Accounts Displayed: ' || v_count);

EXCEPTION
    /* --------------------------------------------------------
       EXCEPTION HANDLING
       -------------------------------------------------------- */

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error Code: ' || SQLCODE ||
            ' | Message: ' || SQLERRM
        );

        -- Ensure cursor is closed in case of failure
        IF acc_cursor%ISOPEN THEN
            CLOSE acc_cursor;
        END IF;
END;
/


BEGIN
    top_accounts ;
END ;