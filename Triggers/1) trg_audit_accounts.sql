

/* ============================================================
   MODULE:       Core Banking - Audit Trigger
   OBJECT:       TRG_AUDIT_ACCOUNTS
   DESCRIPTION:  Captures balance changes on ACCOUNTS table
                 with production-grade safety checks
   ============================================================ */

CREATE OR REPLACE TRIGGER trg_audit_accounts
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF :OLD.balance != :NEW.balance THEN
        -- Insert 
        -- Insert into audit_logs only if balance changed
        INSERT INTO audit_logs (
            audit_id,
            account_id,
            old_balance,
            new_balance,
            action_type,
            action_date
        ) VALUES (
            audit_seq.NEXTVAL,
            :OLD.account_id,
            :OLD.balance,
            :NEW.balance,
            'UPDATE',
            SYSDATE
        );
    END IF;

END;
/

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 101;
/
COMMIT;
/
select * from AUDIT_LOGS ;