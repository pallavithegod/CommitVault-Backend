// --- SECTION 1: IMPORTS & SETUP ---
require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// --- SECTION 2: DATABASE CONNECTION ---
const db = mysql.createPool({
    host: 'localhost',
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: 'CommitVault'
});

// --- SECTION 3: API ROUTES ---

// Route A: Fetching the Dashboard Data
app.get('/api/dashboard/:customerId', async (req, res) => {
    try {
        const { customerId } = req.params;
        
        const [summary] = await db.query('SELECT * FROM Account_Summary_View WHERE customer_id = ?', [customerId]);
        
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
        // Fetches just the basic info needed for the dropdown
        const [customers] = await db.query('SELECT customer_id, CONCAT(first_name, " ", last_name) AS name FROM customers');
        res.json(customers);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Route D: Get Accounts for a Specific Customer (For the Transfer Dropdown)
app.get('/api/accounts/:customerId', async (req, res) => {
    try {
        const { customerId } = req.params;
        // Fetches only Active accounts that belong to the selected user
        const [accounts] = await db.query('SELECT account_id, account_type, balance FROM accounts WHERE customer_id = ? AND status = "Active"', [customerId]);
        res.json(accounts);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- SECTION 4: SERVER START ---
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});