// --- SECTION 1: IMPORTS & SETUP ---
require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors({
    origin: ['http://localhost:5173', 'https://commit-vault.vercel.app'],
    credentials: true
}));

// --- SECTION 2: DATABASE CONNECTION ---
// const db = mysql.createPool({
//   host: process.env.DB_HOST,
//   port: process.env.DB_PORT || 3306,
//   user: process.env.DB_USER,
//   password: process.env.DB_PASSWORD,
//   database: 'CommitVault',
//   ssl: {
//     rejectUnauthorized: false 
//   }
// });

// --- SECTION 2: DATABASE CONNECTION ---
const db = mysql.createPool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT) || 3306, // <-- Forces this to be a number
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: 'CommitVault',
  ssl: {
    rejectUnauthorized: false 
  }
});

// --- THE DIAGNOSTIC TEST ---
db.getConnection()
  .then(conn => {
    console.log("✅ SUCCESS: Connected to Aiven Cloud Database!");
    conn.release();
  })
  .catch(err => {
    console.log("❌ ERROR: Could not connect to Aiven.");
    console.error(err.message); // This will spit out the exact reason!
  });

// --- SECTION 3: API ROUTES ---

// Route A: Fetching the Dashboard Data
app.get('/api/dashboard/:customerId', async (req, res) => {
    try {
        const { customerId } = req.params;
        
        const [summary] = await db.query('SELECT * FROM account_summary_view WHERE customer_id = ?', [customerId]);        
        
        const [transactions] = await db.query(`
            SELECT t.transaction_id, t.transaction_type, t.amount, t.transaction_date, t.description 
            FROM transactions t
            JOIN accounts a ON t.account_id = a.account_id
            WHERE a.customer_id = ? 
            ORDER BY t.transaction_date DESC LIMIT 5
        `, [customerId]);

        res.json({ summary: summary[0], transactions });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Route B: Processing the Transfer
app.post('/api/transfer', async (req, res) => {
    try {
        const { senderAccountId, receiverAccountId, amount } = req.body;
        
        await db.query('CALL ProcessFundTransfer(?, ?, ?)', [senderAccountId, receiverAccountId, amount]);
        
        res.json({ message: 'Transfer Successful!' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Route C: Get All Customers (For the Navbar Dropdown)
app.get('/api/customers', async (req, res) => {
    try {
        // Fetching from the actual customers table so the dropdown populates!
        const [rows] = await db.query('SELECT * FROM customers'); 
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Route D: Get Accounts for a Specific Customer (For the Transfer Dropdown)
// Check this in server.js
app.get('/api/accounts/:customerId', async (req, res) => {
  const { customerId } = req.params;
  try {
    // Is it 'customer_id' or 'user_id' in your Aiven DB?
    const [rows] = await db.query('SELECT * FROM accounts WHERE customer_id = ?', [customerId]);
    console.log("Accounts found:", rows); // Add this to see the result in your VS Code terminal
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- SECTION 4: SERVER START ---
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});