const { Pool } = require('pg');
require('dotenv').config();

console.log('DATABASE_URL:', process.env.DATABASE_URL); // Debug line

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function testConnection() {
  try {
    const client = await pool.connect();
    console.log('Connected to PostgreSQL!');
    const res = await client.query('SELECT NOW()');
    console.log('Current time:', res.rows[0]);
    client.release();
  } catch (err) {
    console.error('Connection error:', err.stack);
  }
}

testConnection();
