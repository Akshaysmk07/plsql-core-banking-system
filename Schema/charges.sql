CREATE TABLE transaction_charges (
    txn_channel    VARCHAR2(20) PRIMARY KEY,
    charge_amount  NUMBER(10,2)
);

INSERT INTO transaction_charges VALUES ('UPI', 0);
INSERT INTO transaction_charges VALUES ('IMPS', 5);
INSERT INTO transaction_charges VALUES ('NEFT', 10);

COMMIT;