# 🏦 Mini Core Banking Transaction Processing System — Version 1 (Complete Guide)

---

# 📌 1. Project Overview

This project simulates a **real-world banking backend system** using Oracle PL/SQL.

It models how banks:

- Store account data  
- Process deposits and withdrawals  
- Transfer money safely  
- Maintain logs and audit trails  
- Handle failures and concurrency  

---

# 🎯 2. Core Objective

Build a **transaction-safe, consistent, and auditable system** that follows:

- Data Integrity  
- ACID Principles  
- Real Banking Logic  

---

# 🧠 3. Key Concepts Used

## 🔹 ACID Properties

- **Atomicity** → All steps succeed or none  
- **Consistency** → Data remains valid  
- **Isolation** → Transactions don’t interfere  
- **Durability** → Data persists after commit  

---

## 🔹 Concurrency Control

- Row-level locking using `FOR UPDATE`  
- Deadlock prevention using ordered locking  

---

## 🔹 Error Handling

- `RAISE_APPLICATION_ERROR`  
- Exception blocks  

---

## 🔹 Logging

- Error logging  
- Audit logging  

---

# 🏗️ 4. System Architecture

```text
User Action
   ↓
PL/SQL Procedure
   ↓
Accounts Table Update
   ↓
Transaction Insert
   ↓
Audit Trigger Fires
   ↓
Audit Logs Stored
   ↓
(If Error) → Error Logs Stored
```

---

# 🧱 5. Database Design

## 📄 accounts

| Column       | Description           |
|--------------|-----------------------|
| account_id   | Unique account number |
| account_name | Account holder name   |
| balance      | Current balance       |

---

## 📄 transactions

| Column       | Description                   |
|--------------|-------------------------------|
| txn_id       | Transaction ID                |
| from_account | Sender                        |
| to_account   | Receiver                      |
| amount       | Amount transferred            |
| txn_type     | DEPOSIT / WITHDRAW / TRANSFER |
| status       | SUCCESS / FAILED              |

---

## 📄 error_logs

| Column         | Description          |
|----------------|----------------------|
| error_id       | Unique ID            |
| error_message  | Error details        |
| procedure_name | Where error occurred |
| account_id     | Related account      |
| error_date     | Timestamp            |

---

## 📄 audit_logs

| Column      | Description      |
|-------------|------------------|
| audit_id    | Unique ID        |
| account_id  | Affected account |
| old_balance | Before update    |
| new_balance | After update     |
| change_date | Timestamp        |

---

# ⚙️ 6. Core Procedures

## 🏗️ create_account

- Creates a new account  
- Initializes balance  

---

## 💰 deposit

- Validates account  
- Adds balance  
- Logs transaction  
- Commits  

---

## 💸 withdraw

- Validates account  
- Checks balance  
- Deducts money  
- Logs transaction  

---

## 🔁 transfer_funds (MOST IMPORTANT)

Handles the complete money transfer lifecycle:

---

# 🔍 7. Transfer Flow

1. Validate input  
2. Lock accounts (`FOR UPDATE`)  
3. Prevent deadlock (ordered locking)  
4. Check balance  
5. Create SAVEPOINT  
6. Debit sender  
7. Credit receiver  
8. Insert transaction  
9. Commit  

---

# 🔒 8. Row Locking

```sql
SELECT ... FOR UPDATE;
```

👉 Prevents concurrent modification  

---

# 🔁 9. Savepoint Usage

```sql
SAVEPOINT before_transaction;
ROLLBACK TO before_transaction;
```

👉 Allows partial rollback  

---

# ⚠️ 10. Exception Handling

Handled cases:

- Invalid account  
- Insufficient balance  
- System errors  

---

## Example

```sql
RAISE_APPLICATION_ERROR(-20001, 'Invalid account');
```

---

# 🧾 11. Audit System

- Trigger tracks balance changes  
- Stores:
  - Old balance  
  - New balance  
  - Timestamp  

👉 Ensures full traceability  

---

# 🪵 12. Logging System

## Error Logging Procedure

- Stores errors in `error_logs`  
- Uses autonomous transaction  

```sql
PRAGMA AUTONOMOUS_TRANSACTION;
```

👉 Ensures logs persist even after rollback  

---

# 🔥 13. Deadlock Concept

## ❌ Problem

Two transactions lock resources in different order:

```text
Session A: 101 → 102  
Session B: 102 → 101  
```

👉 Leads to deadlock  

---

## ✅ Solution

Always lock resources in the same order:

```text
101 → 102
```

👉 Prevents deadlock  

---

# 🧪 14. Testing Scenarios

## ✅ Normal Transfer

- Balance updates correctly  
- Transaction recorded  

---

## ❌ Insufficient Balance

- Error raised  
- No update  

---

## ❌ Invalid Account

- Exception triggered  
- Logged  

---

## 🔒 Concurrent Transactions

- No data corruption  
- Proper locking ensured  

---

# 📊 15. Reports

Using cursors:

- Daily transactions  
- Failed transactions  
- Top accounts  

---

# 🧠 16. Real-World Mapping

| System Feature   | Real Banking Example |
|-----------------|---------------------|
| transfer_funds  | UPI / IMPS          |
| deposit         | ATM deposit         |
| withdraw        | ATM withdrawal      |
| audit_logs      | Bank audit trail    |
| error_logs      | System monitoring   |

---

# 🔥 17. Key Strengths of This Project

- Transaction-safe  
- Concurrency-safe  
- Audit-ready  
- Error-resilient  
- Real banking logic  

---

# 🚀 Final Summary

This project mimics **core banking transaction processing systems** by combining:

- Strong database design  
- Reliable transaction handling  
- Robust error management  
- Real-world concurrency control  

👉 It forms a **solid foundation for Oracle Financial Services (OFSS) roles** and real banking systems like Flexcube.

---
