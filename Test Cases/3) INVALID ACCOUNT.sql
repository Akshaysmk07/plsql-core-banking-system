/* ============================================================
   TEST 3: INVALID ACCOUNT
   ============================================================ */

BEGIN
    transfer_funds(999, 202, 500);
END;
/

SELECT * FROM error_logs ORDER BY error_id DESC;