/* ============================================================
   TEST 7: CONCURRENCY TEST
   INSTRUCTIONS:
   Run in TWO separate sessions
   EXPECTATION:
   - One transaction waits
   - No data inconsistency
   ============================================================ */

-- SESSION 1
BEGIN
    transfer_funds(201, 202, 500);
END;
/

-- SESSION 2
BEGIN
    transfer_funds(201, 202, 300);
END;
/