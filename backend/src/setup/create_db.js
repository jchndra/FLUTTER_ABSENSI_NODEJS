require('dotenv').config();
const mysql = require('mysql2/promise');

(async function() {
  const host = process.env.DB_HOST || '127.0.0.1';
  const port = process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 3306;
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const dbName = process.env.DB_NAME || 'absensi_db';

  try {
    const conn = await mysql.createConnection({ host, port, user, password });
    await conn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
    console.log(`Database ${dbName} ensured.`);
    await conn.end();
  } catch (err) {
    console.error('Failed to create database:', err.message);
    process.exit(1);
  }
})();
