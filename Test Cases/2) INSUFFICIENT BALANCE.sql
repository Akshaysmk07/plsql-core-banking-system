/* ============================================================
   TEST 2: INSUFFICIENT BALANCE
   EXPECTATION:
   - Error raised
   - No balance change
   - No transaction inserted
   - Error logged
   ============================================================ */

BEGIN
    transfer_funds(201, 202, 10000);
END;
/

-- Verification
SELECT account_id, balance FROM accounts WHERE account_id IN (201, 202);
SELECT * FROM error_logs ORDER BY error_id DESC;