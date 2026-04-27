/* ============================================================
   MODULE:       Core Banking - Scheduled Transactions
   OBJECT:       SCHEDULED_TRANSACTIONS
   DESCRIPTION:  Stores recurring/scheduled transactions such as
                 daily or monthly transfers between accounts
   AUTHOR:       Akshay
   CREATED ON:   27/04/2026
   ============================================================ */


/* ============================================================
   STEP 1: CREATE SCHEDULED_TRANSACTIONS TABLE
   ============================================================ */

CREATE TABLE scheduled_transactions (

    -- Unique schedule identifier (Primary Key)
    schedule_id     NUMBER PRIMARY KEY,

    -- Source account for scheduled transfer
    from_account    NUMBER,

    -- Destination account for scheduled transfer
    to_account      NUMBER,

    -- Transaction amount
    amount          NUMBER(12,2),

    -- Transaction channel (UPI / IMPS / NEFT)
    txn_channel     VARCHAR2(20),

    -- Next execution date
    schedule_date   DATE,

    -- Execution frequency (DAILY / MONTHLY)
    frequency       VARCHAR2(20),

    -- Schedule status (ACTIVE / INACTIVE)
    status          VARCHAR2(20) DEFAULT 'ACTIVE',

    -- Record creation timestamp
    created_date    DATE DEFAULT SYSDATE
);


INSERT INTO scheduled_transactions (
    schedule_id,
    from_account,
    to_account,
    amount,
    txn_channel,
    schedule_date,
    frequency
) VALUES (
    1,
    301,
    302,
    1000,
    'IMPS',
    SYSDATE,
    'MONTHLY'
);

COMMIT;

