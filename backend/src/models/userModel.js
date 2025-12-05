const knex = require('../db');

const UserModel = {
  async create({ username, password_hash, role = 'admin' }) {
    const [id] = await knex('users').insert({ username, password_hash, role });
    return this.getById(id);
  },
  async getById(id) {
    return knex('users').where({ id }).first();
  },
  async getByUsername(username) {
    return knex('users').where({ username }).first();
  },
  async update(id, changes) {
    await knex('users').where({ id }).update(changes);
    return this.getById(id);
  },
  async remove(id) {
    return knex('users').where({ id }).del();
  }
};

module.exports = UserModel;
