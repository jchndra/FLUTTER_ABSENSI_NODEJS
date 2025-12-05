require('dotenv').config();

const common = {
  migrations: {
    directory: './migrations'
  }
};

module.exports = {
  development: Object.assign({}, common, {
    client: 'mysql2',
    connection: {
      host: process.env.DB_HOST || '127.0.0.1',
      port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 3306,
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'absensi_db'
    }
  }),
};
