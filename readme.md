# CommitVault — Backend API & Database

The server and database layer for CommitVault — demonstrating enterprise-level SQL: views with correlated subqueries, stored procedures, row-level locking, and automated audit triggers.

![Node.js](https://img.shields.io/badge/Node.js-Express-339933?style=flat-square&logo=node.js&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql&logoColor=white)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js |
| Framework | Express.js |
| Database | MySQL |
| Driver | `mysql2/promise` |
| Utilities | `cors`, `dotenv` |

---

## Core DBMS Concepts

| Concept | Unit | Implementation |
|---|---|---|
| **`VIEW`** | II | `Account_Summary_View` uses correlated subqueries to compute real-time portfolio balances — no data duplication, fan-out anomalies prevented at the schema level. |
| **`STORED PROCEDURE`** | III | `ProcessFundTransfer` encapsulates the full transfer logic natively in MySQL — multi-step, validated, and reusable without application-layer orchestration. |
| **`TRANSACTION` / ACID** | II–III | `START TRANSACTION` with explicit `COMMIT` / `ROLLBACK` guarantees atomicity. `SELECT ... FOR UPDATE` applies row-level locking to prevent concurrent transfer anomalies. |
| **`TRIGGER`** | III | An `AFTER INSERT` trigger on the accounts table automatically writes to `audit_logs` — security events captured without any explicit application code. |

---

## Database Objects

**Tables:** `users`, `accounts`, `transactions`, `audit_logs`  
**Views:** `Account_Summary_View`  
**Procedures:** `ProcessFundTransfer`  
**Triggers:** `after_insert_account`

---

## Getting Started

### 1. Set up the database

```sql
CREATE DATABASE CommitVault;
```

Import `database.sql` in MySQL Workbench to scaffold all tables, views, procedures, triggers, and seed data.

### 2. Clone & install

```bash
git clone <repo-url>
npm install
```

### 3. Configure environment

Create `.env` in the root directory:

```env
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=CommitVault
PORT=5000
```

### 4. Start the server

```bash
node server.js
```

API available at `http://localhost:5000`.

---