````md
# 🏦 Mini Core Banking Transaction Processing System — Version 1 (Complete Guide)

---

## 📌 1. Project Overview

This project simulates a **real-world banking backend system** using Oracle PL/SQL.

It models how banks:

- Store account data  
- Process deposits and withdrawals  
- Transfer money safely  
- Maintain logs and audit trails  
- Handle failures and concurrency  

---

## 🎯 Core Objective

Build a **transaction-safe, consistent, and auditable system** that follows:

- Data integrity  
- ACID principles  
- Real banking logic  

---

## 🧠 2. Key Concepts Used

### 🔹 ACID Properties

- **Atomicity** → All steps succeed or none  
- **Consistency** → Data remains valid  
- **Isolation** → Transactions don’t interfere  
- **Durability** → Data persists after commit  

---

### 🔹 Concurrency Control

- Row-level locking (`FOR UPDATE`)  
- Deadlock prevention (ordered locking)  

---

### 🔹 Error Handling

- `RAISE_APPLICATION_ERROR`  
- Exception blocks  

---

### 🔹 Logging

- Error logging  
- Audit logging  

---

## 🏗️ 3. System Architecture

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
````

---

## 🧱 4. Database Design

### 📄 accounts

| Column       | Description           |
| ------------ | --------------------- |
| account_id   | Unique account number |
| account_name | Account holder name   |
| balance      | Current balance       |

---

### 📄 transactions

| Column       | Description                   |
| ------------ | ----------------------------- |
| txn_id       | Transaction ID                |
| from_account | Sender                        |
| to_account   | Receiver                      |
| amount       | Amount transferred            |
| txn_type     | DEPOSIT / WITHDRAW / TRANSFER |
| status       | SUCCESS / FAILED              |

---

### 📄 error_logs

| Column         | Description          |
| -------------- | -------------------- |
| error_id       | Unique ID            |
| error_message  | Error details        |
| procedure_name | Where error occurred |
| account_id     | Related account      |
| error_date     | Timestamp            |

---

### 📄 audit_logs

| Column      | Description      |
| ----------- | ---------------- |
| audit_id    | Unique ID        |
| account_id  | Affected account |
| old_balance | Before update    |
| new_balance | After update     |
| change_date | Timestamp        |

---

## ⚙️ 5. Core Procedures

---

### 🏗️ create_account

* Creates new account
* Initializes balance

---

### 💰 deposit

* Validates account
* Adds balance
* Logs transaction
* Commits

---

### 💸 withdraw

* Validates account
* Checks balance
* Deducts money
* Logs transaction

---

### 🔁 transfer_funds (MOST IMPORTANT)

Handles full money transfer flow:

---

## 🔍 Transfer Flow

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

## 🔒 Row Locking

```sql
SELECT ... FOR UPDATE;
```

👉 Prevents concurrent modification

---

## 🔁 Savepoint Usage

```sql
SAVEPOINT before_transaction;
ROLLBACK TO before_transaction;
```

👉 Allows partial rollback

---

## ⚠️ 6. Exception Handling

Handled cases:

* Invalid account
* Insufficient balance
* System errors

---

### Example

```sql
RAISE_APPLICATION_ERROR(-20001, 'Invalid account');
```

---

## 🧾 7. Audit System

Trigger tracks balance changes:

* Old balance
* New balance
* Timestamp

👉 Ensures full traceability

---

## 🪵 8. Logging System

### Error Logging Procedure

* Stores errors in `error_logs`
* Uses autonomous transaction

```sql
PRAGMA AUTONOMOUS_TRANSACTION;
```

👉 Ensures logs persist even after rollback

---

## 🔥 9. Deadlock Concept

### ❌ Problem

Two transactions lock resources in different order:

```text
Session A: 101 → 102
Session B: 102 → 101
```

👉 Deadlock

---

### ✅ Solution

Always lock in same order:

```text
101 → 102
```

👉 Prevents deadlock

---

## 🧪 10. Testing Scenarios

---

### ✅ Normal Transfer

* Balance updates correctly
* Transaction recorded

---

### ❌ Insufficient Balance

* Error raised
* No update

---

### ❌ Invalid Account

* Exception triggered
* Logged

---

### 🔒 Concurrent Transactions

* No data corruption
* Proper locking

---

## 📊 11. Reports

Using cursors:

* Daily transactions
* Failed transactions
* Top accounts

---

## 🧠 12. Real-World Mapping

| System         | Real Example      |
| -------------- | ----------------- |
| transfer_funds | UPI / IMPS        |
| deposit        | ATM deposit       |
| withdraw       | ATM withdrawal    |
| audit_logs     | Bank audit trail  |
| error_logs     | System monitoring |

---

## 🔥 13. Key Strengths of This Project

* Transaction-safe
* Concurrency-safe
* Audit-ready
* Error-resilient
* Real banking logic

---

```
```
