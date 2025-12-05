const bcrypt = require('bcryptjs');

exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('users').del();

  const password = 'admin123';
  const hash = await bcrypt.hash(password, 10);

  // Use email as username to match frontend login UI (email-based)
  await knex('users').insert([
    { username: 'admin@klub.com', password_hash: hash, role: 'admin' }
  ]);

  console.log('Seeded admin user (username: admin@klub.com, password: admin123)');
};
