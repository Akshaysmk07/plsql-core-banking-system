/* ============================================================
   TEST 1: ACCOUNT CREATION + TRANSFER
   EXPECTATION:
   - Successful transfer
   - Balances updated
   - Transaction + Audit logs created
   ============================================================ */

BEGIN
    create_account(201, 'User A', 5000, 'SAVINGS');
    create_account(202, 'User B', 3000, 'SAVINGS');
END;
/

BEGIN
    transfer_funds(201, 202, 1000);
END;
/

-- Verification
SELECT account_id, balance FROM accounts WHERE account_id IN (201, 202);
SELECT * FROM transactions WHERE txn_type = 'TRANSFER';
SELECT * FROM audit_logs WHERE account_id IN (201, 202);