# CommitVault - Backend API & Database

This is the backend server and database architecture for **CommitVault**, a conceptual banking application built to demonstrate advanced Database Management System (DBMS) concepts.

## 🛠️ Tech Stack
* **Runtime:** Node.js
* **Framework:** Express.js
* **Database:** MySQL
* **Libraries:** `mysql2/promise`, `cors`, `dotenv`

## 🧠 Core DBMS Concepts Demonstrated
This project specifically highlights enterprise-level database programming:
1. **Views (Unit II):** Utilizes `Account_Summary_View` with correlated subqueries to calculate real-time portfolio balances without data duplication (Fan-Out prevention).
2. **Stored Procedures (Unit III):** Uses `ProcessFundTransfer` to handle complex multi-step banking transactions natively in the database.
3. **Transaction Control / ACID (Unit II/III):** Implements `START TRANSACTION`, `COMMIT`, and `ROLLBACK` to guarantee atomicity during fund transfers. Utilizes `FOR UPDATE` row-level locking to prevent concurrency anomalies.
4. **Triggers (Unit III):** Automated security logging (`audit_logs`) upon account creation.

## 🚀 Getting Started

### Prerequisites
* Node.js installed
* MySQL Server & MySQL Workbench installed

### 1. Database Setup
1. Open MySQL Workbench.
2. Create a new schema named `CommitVault`: `CREATE DATABASE CommitVault;`
3. Import the `database.sql` file provided in this repository to automatically build all tables, views, procedures, and dummy data.

### 2. Environment Setup
1. Clone this repository.
2. Run `npm install` to install dependencies.
3. Create a `.env` file in the root directory and add your MySQL credentials:
   ```text
   DB_USER=root
   DB_PASSWORD=your_mysql_password
3. Run the Server
Bash
node server.js
The backend will start running on http://localhost:5000.