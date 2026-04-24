/* ============================================================
   TEST 4: SAME ACCOUNT VALIDATION
   ============================================================ */

BEGIN
    transfer_funds(201, 201, 500);
END;
/

SELECT * FROM error_logs ORDER BY error_id DESC;