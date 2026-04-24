/* ============================================================
   TEST 5: INVALID AMOUNT
   ============================================================ */

BEGIN
    transfer_funds(201, 202, -100);
END;
/

SELECT * FROM error_logs ORDER BY error_id DESC;