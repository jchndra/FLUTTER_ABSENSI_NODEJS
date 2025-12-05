const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const routes = require('./routes');
const knex = require('./db');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use('/api', routes);

// simple health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// For development default to 0.0.0.0 so server is reachable on any interface.
// In production set HOST to your laptop IP (e.g., 192.168.1.254) via .env
const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;

app.listen(PORT, HOST, () => {
  console.log(`Backend listening at http://${HOST}:${PORT}`);
});

module.exports = app;
