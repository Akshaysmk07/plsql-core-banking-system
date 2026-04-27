/* ============================================================
   MODULE:       Core Banking - Reconciliation
   OBJECT:       RECONCILE_ACCOUNTS
   DESCRIPTION:  Compares stored account balances with balances
                 derived from ledger entries and reports mismatches
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE PROCEDURE
   ============================================================ */

CREATE OR REPLACE PROCEDURE reconcile_accounts
IS
BEGIN
    /* ----------------------------------------------------------
       STEP 2: FETCH ACCOUNT VS LEDGER BALANCES
       ---------------------------------------------------------- */

    FOR rec IN (
        SELECT 
            a.account_id,

            -- Stored balance in accounts table
            a.balance AS stored_balance,

            -- Calculated balance from ledger entries
            NVL(SUM(
                CASE 
                    WHEN l.entry_type = 'CREDIT' THEN l.amount
                    ELSE -l.amount
                END
            ), 0) AS ledger_balance

        FROM accounts a

        -- Left join to include accounts with no ledger entries
        LEFT JOIN ledger_entries l
        ON a.account_id = l.account_id

        GROUP BY a.account_id, a.balance
    )
    LOOP

        /* ------------------------------------------------------
           STEP 3: COMPARE BALANCES
           ------------------------------------------------------ */

        -- Identify mismatch between stored and ledger balances
        IF rec.stored_balance != rec.ledger_balance THEN

            -- Output mismatch details
            DBMS_OUTPUT.PUT_LINE(
                'Mismatch in Account ' || rec.account_id ||
                ' | Stored: ' || rec.stored_balance ||
                ' | Ledger: ' || rec.ledger_balance
            );

        END IF;

    END LOOP;

END;
/

/* ============================================================
   TEST CASE: RUN RECONCILIATION
   ============================================================ */

-- Enable output
SET SERVEROUTPUT ON;
/

-- Execute reconciliation procedure
BEGIN
    reconcile_accounts;
END;
/

/* ============================================================
   VERIFY LEDGER DATA
   ============================================================ */

-- View latest ledger entries
SELECT * 
FROM ledger_entries 
ORDER BY ledger_id DESC;
/