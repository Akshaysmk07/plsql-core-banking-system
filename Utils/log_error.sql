
/* ============================================================
   MODULE:       Core Banking - Error Logging Procedure
   OBJECT:       LOG_ERROR
   DESCRIPTION:  Logs errors using autonomous transaction
                 to ensure logging even during failures
   ============================================================ */

CREATE OR REPLACE PROCEDURE log_error (
    p_error_message   IN VARCHAR2,
    p_procedure_name  IN VARCHAR2,
    p_account_id      IN NUMBER
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    -- Insert error record
    INSERT INTO error_logs (
        error_id,
        error_message,
        procedure_name,
        account_id,
        error_date
    ) VALUES (
        error_seq.NEXTVAL,
        p_error_message,
        p_procedure_name,
        p_account_id,
        SYSDATE
    );

    -- Commit independently
    COMMIT;

EXCEPTION
    -- Logging should never interrupt main flow
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    transfer_funds(999, 102, 10);
END;
/

select * from ERROR_LOGS ;