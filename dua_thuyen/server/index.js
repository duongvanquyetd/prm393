require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const sql = require('mssql');
const bcrypt = require('bcryptjs');
const fs = require('fs').promises;
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

const dbConfig = {
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || 'YourStrong!Passw0rd',
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'DuaThuyen',
  options: { enableArithAbort: true, trustServerCertificate: true },
};

app.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Missing fields' });
  try {
    // Try SQL Server first
    const pool = await sql.connect(dbConfig);
    const existing = await pool.request().input('email', email).query('SELECT TOP 1 * FROM Users WHERE Email = @email');
    if (existing.recordset.length) {
      return res.status(400).json({ error: 'User exists' });
    }
    const hash = await bcrypt.hash(password, 10);
    await pool.request().input('name', name).input('email', email).input('pass', hash)
      .query('INSERT INTO Users (Name, Email, PasswordHash) VALUES (@name, @email, @pass)');
    // Also append the new account to a local JSON file for quick local backups / testing
    try {
      const dataDir = path.join(__dirname, 'data');
      const accountsFile = path.join(dataDir, 'accounts.json');
      await fs.mkdir(dataDir, { recursive: true });
      let accounts = [];
      try {
        const txt = await fs.readFile(accountsFile, 'utf8');
        accounts = JSON.parse(txt || '[]');
      } catch (e) {
        accounts = [];
      }
      accounts.push({ name, email, passwordHash: hash, createdAt: new Date().toISOString() });
      await fs.writeFile(accountsFile, JSON.stringify(accounts, null, 2), 'utf8');
    } catch (e) {
      console.error('Failed to write local accounts file', e);
    }
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    // If SQL fails (e.g., login error) -- fallback to local JSON store for development
    try {
      const hash = await bcrypt.hash(password, 10);
      const dataDir = path.join(__dirname, 'data');
      const accountsFile = path.join(dataDir, 'accounts.json');
      await fs.mkdir(dataDir, { recursive: true });
      let accounts = [];
      try {
        const txt = await fs.readFile(accountsFile, 'utf8');
        accounts = JSON.parse(txt || '[]');
      } catch (e) {
        accounts = [];
      }
      // check existing
      if (accounts.find(a => a.email === email)) {
        return res.status(400).json({ error: 'User exists' });
      }
      accounts.push({ name, email, passwordHash: hash, createdAt: new Date().toISOString() });
      await fs.writeFile(accountsFile, JSON.stringify(accounts, null, 2), 'utf8');
      console.warn('SQL error during register — used local accounts.json fallback');
      return res.json({ ok: true, fallback: true });
    } catch (e) {
      console.error('Fallback write failed', e);
      return res.status(500).json({ error: 'Server error' });
    }
  }
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Missing fields' });
  try {
    const pool = await sql.connect(dbConfig);
    const r = await pool.request().input('email', email).query('SELECT TOP 1 * FROM Users WHERE Email = @email');
    if (!r.recordset.length) return res.status(401).json({ error: 'Invalid' });
    const user = r.recordset[0];
    const ok = await bcrypt.compare(password, user.PasswordHash);
    if (!ok) return res.status(401).json({ error: 'Invalid' });
    // Return user id and name for client display
    res.json({ ok: true, userId: user.Id, name: user.Name });
  } catch (err) {
    console.error(err);
    // On SQL failure, try local fallback store for development
    try {
      const dataDir = path.join(__dirname, 'data');
      const accountsFile = path.join(dataDir, 'accounts.json');
      const txt = await fs.readFile(accountsFile, 'utf8');
      const accounts = JSON.parse(txt || '[]');
      const user = accounts.find(a => a.email === email);
      if (!user) return res.status(401).json({ error: 'Invalid' });
      const ok = await bcrypt.compare(password, user.passwordHash || '');
      if (!ok) return res.status(401).json({ error: 'Invalid' });
      // Return stored name from fallback store when available
      return res.json({ ok: true, userId: user.id || null, name: user.name || null, fallback: true });
    } catch (e) {
      console.error('Fallback login failed', e);
      return res.status(500).json({ error: 'Server error' });
    }
  }
});

const port = process.env.PORT || 3000;
const host = process.env.HOST || '0.0.0.0';
app.listen(port, host, () => console.log(`Auth server running on http://${host}:${port}`));
