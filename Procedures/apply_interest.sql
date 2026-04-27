CREATE OR REPLACE PROCEDURE apply_interest
IS
    -- Cursor for all active savings accounts
    CURSOR acc_cursor IS
        SELECT account_id, balance, interest_rate
        FROM accounts
        WHERE account_type = 'SAVINGS'
        AND status = 'ACTIVE';

    v_interest NUMBER;
BEGIN
    FOR acc IN acc_cursor LOOP

        -- Step 1: Calculate monthly interest
        v_interest := (acc.balance * acc.interest_rate) / (100 * 12);

        -- Step 2: Update balance
        UPDATE accounts
        SET balance = balance + v_interest
        WHERE account_id = acc.account_id;

        -- Step 3: Insert transaction
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
            transactions_seq.NEXTVAL,
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

    END LOOP;

    COMMIT;

END;
/

-- check balance
SELECT account_id, balance FROM accounts WHERE account_id = 201;
/

BEGIN
    apply_interest;
END;
/

SELECT txn_type, txn_channel, amount 
FROM transactions
WHERE txn_type = 'INTEREST';