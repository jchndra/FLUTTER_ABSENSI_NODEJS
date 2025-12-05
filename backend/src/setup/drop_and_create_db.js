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
    console.log(`Dropping database if exists: ${dbName}`);
    await conn.query(`DROP DATABASE IF EXISTS \`${dbName}\``);
    console.log(`Creating database: ${dbName}`);
    await conn.query(`CREATE DATABASE \`${dbName}\``);
    console.log(`Database ${dbName} recreated.`);
    await conn.end();
  } catch (err) {
    console.error('Failed to drop/create database:', err.message);
    process.exit(1);
  }
})();
