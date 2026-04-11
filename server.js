// --- SECTION 1: IMPORTS & SETUP ---
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// --- SECTION 2: DATABASE CONNECTION ---
const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'pallavithegreat', 
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

// --- SECTION 4: SERVER START ---
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});