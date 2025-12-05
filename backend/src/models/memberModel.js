const knex = require('../db');

const MemberModel = {
  async getAll() {
    return await knex('members').select('*');
  },
  async getById(id) {
    return await knex('members').where({ id }).first();
  },
  async create(member) {
    await knex('members').insert({
      id: member.id,
      name: member.name,
      photo_url: member.photoUrl || null,
    });
    return this.getById(member.id);
  },
  async update(id, changes) {
    await knex('members').where({ id }).update({
      name: changes.name,
      photo_url: changes.photoUrl || null,
    });
    return this.getById(id);
  },
  async remove(id) {
    return knex('members').where({ id }).del();
  }
};

module.exports = MemberModel;
