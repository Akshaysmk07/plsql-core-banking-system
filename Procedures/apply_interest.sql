CREATE OR REPLACE PROCEDURE apply_interest
IS
    -- Cursor for all active savings accounts
    CURSOR acc_cursor IS
        SELECT account_id, balance, interest_rate
        FROM accounts
        WHERE account_type = 'SAVINGS'
        AND status = 'ACTIVE';

    v_interest NUMBER;

    -- Transaction id for linking ledger
    v_txn_id NUMBER;
BEGIN
    FOR acc IN acc_cursor LOOP

        /* ----------------------------------------------------------
           STEP 1: CALCULATE INTEREST
           ---------------------------------------------------------- */
        v_interest := (acc.balance * acc.interest_rate) / (100 * 12);

        -- Skip if interest is 0
        IF v_interest <= 0 THEN
            CONTINUE;
        END IF;

        /* ----------------------------------------------------------
           STEP 2: UPDATE BALANCE
           ---------------------------------------------------------- */
        UPDATE accounts
        SET balance = balance + v_interest
        WHERE account_id = acc.account_id;

        /* ----------------------------------------------------------
           STEP 3: INSERT TRANSACTION
           ---------------------------------------------------------- */
        v_txn_id := transactions_seq.NEXTVAL;

        INSERT INTO transactions (
            txn_id,
            from_account,
            to_account,
            amount,
            txn_type,
            txn_channel,
            charge_amount,
            reference_txn_id,
            txn_direction,
            status
        ) VALUES (
            v_txn_id,
            NULL,
            acc.account_id,
            v_interest,
            'INTEREST',
            'SYSTEM',
            0,
            NULL,
            'CREDIT',
            'SUCCESS'
        );

        /* ----------------------------------------------------------
           STEP 4: INSERT LEDGER ENTRY 🔥
           ---------------------------------------------------------- */
        INSERT INTO ledger_entries (
            ledger_id,
            account_id,
            txn_id,
            entry_type,
            amount
        ) VALUES (
            ledger_seq.NEXTVAL,
            acc.account_id,
            v_txn_id,
            'CREDIT',
            v_interest
        );

    END LOOP;

    COMMIT;

END;
/
-- check balance
SELECT account_id, balance FROM accounts WHERE account_id = 301;
/

BEGIN
    apply_interest;
END;
/

SELECT txn_type, txn_channel, amount 
FROM transactions
WHERE txn_type = 'INTEREST';