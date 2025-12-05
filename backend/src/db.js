require('dotenv').config();
const env = process.env.NODE_ENV || 'development';
const config = require('../knexfile')[env];
const knex = require('knex')(config);

// Quick check: export a function to run raw queries if needed
module.exports = knex;
