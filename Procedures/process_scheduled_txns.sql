/* ============================================================
   MODULE:       Core Banking - Scheduled Transaction Processor
   OBJECT:       PROCESS_SCHEDULED_TXNS
   DESCRIPTION:  Processes all ACTIVE scheduled transactions
                 whose execution date is due. Executes transfer,
                 updates next schedule date based on frequency,
                 and handles failures gracefully.
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE PROCEDURE
   ============================================================ */

CREATE OR REPLACE PROCEDURE process_scheduled_txns
IS
    /* ----------------------------------------------------------
       CURSOR: FETCH DUE SCHEDULED TRANSACTIONS
       ---------------------------------------------------------- */

    -- Select active schedules ready for execution
    CURSOR sched_cursor IS
        SELECT schedule_id,
               from_account,
               to_account,
               amount,
               txn_channel,
               schedule_date,
               frequency
        FROM scheduled_transactions
        WHERE status = 'ACTIVE'
        AND schedule_date <= SYSDATE;

BEGIN
    /* ----------------------------------------------------------
       STEP 2: PROCESS EACH SCHEDULE
       ---------------------------------------------------------- */

    FOR rec IN sched_cursor LOOP

        BEGIN
            /* --------------------------------------------------
               STEP 2.1: EXECUTE FUND TRANSFER
               -------------------------------------------------- */

            -- Invoke transfer procedure
            transfer_funds(
                rec.from_account,
                rec.to_account,
                rec.amount,
                rec.txn_channel
            );


            /* --------------------------------------------------
               STEP 2.2: UPDATE NEXT EXECUTION DATE
               -------------------------------------------------- */

            -- Update based on frequency
            IF rec.frequency = 'DAILY' THEN

                UPDATE scheduled_transactions
                SET schedule_date = schedule_date + 1
                WHERE schedule_id = rec.schedule_id;

            ELSIF rec.frequency = 'MONTHLY' THEN

                UPDATE scheduled_transactions
                SET schedule_date = ADD_MONTHS(schedule_date, 1)
                WHERE schedule_id = rec.schedule_id;

            END IF;


        /* ------------------------------------------------------
           STEP 2.3: HANDLE FAILURES
           ------------------------------------------------------ */

        EXCEPTION
            WHEN OTHERS THEN

                -- Log error message (for debugging)
                DBMS_OUTPUT.PUT_LINE(
                    'Error in schedule_id ' || rec.schedule_id || 
                    ': ' || SQLERRM
                );

                -- Mark schedule as FAILED
                UPDATE scheduled_transactions
                SET status = 'FAILED'
                WHERE schedule_id = rec.schedule_id;

        END;

    END LOOP;


    /* ----------------------------------------------------------
       STEP 3: COMMIT TRANSACTION
       ---------------------------------------------------------- */

    -- Persist all updates
    COMMIT;

END;
/

/* ============================================================
   TEST CASE 1: VIEW SCHEDULED TRANSACTIONS
   ============================================================ */

-- Check all schedules
SELECT * FROM scheduled_transactions;
/


/* ============================================================
   TEST CASE 2: EXECUTE SCHEDULE PROCESSOR
   ============================================================ */

-- Run scheduled transaction processor
BEGIN
    process_scheduled_txns;
END;
/

/* ============================================================
   VERIFY TRANSACTIONS EXECUTED
   ============================================================ */

-- Check recent transactions
SELECT * FROM transactions 
ORDER BY txn_id DESC;
/


/* ============================================================
   VERIFY UPDATED SCHEDULES
   ============================================================ */

-- Check updated schedule dates and status
SELECT * FROM scheduled_transactions;
/