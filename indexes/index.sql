
CREATE INDEX idx_txn_from_acc ON transactions(from_account);
CREATE INDEX idx_txn_to_acc   ON transactions(to_account);

CREATE INDEX idx_ledger_acc ON ledger_entries(account_id);

CREATE INDEX idx_sched_date ON scheduled_transactions(schedule_date);