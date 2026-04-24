/* ============================================================
   TEST 6: DEPOSIT + WITHDRAW
   EXPECTATION:
   - Balance updates correctly
   - Transactions logged
   - Audit logs generated
   ============================================================ */

BEGIN
    deposit(201, 2000);
    withdraw(201, 1000);
END;
/

-- Verification
SELECT account_id, balance FROM accounts WHERE account_id = 201;
SELECT * FROM transactions WHERE to_account = 201 OR from_account = 201;
SELECT * FROM audit_logs WHERE account_id = 201;