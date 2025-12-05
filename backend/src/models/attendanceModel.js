const knex = require('../db');

const AttendanceModel = {
  async getAll() {
    const rows = await knex('attendance_records').select('*').orderBy('date', 'desc');
    return rows.map(r => ({
      id: r.id,
      date: r.date,
      presentMemberIds: JSON.parse(r.present_member_ids_json)
    }));
  },
  async getByDate(dateStr) {
    const row = await knex('attendance_records').where({ date: dateStr }).first();
    if (!row) return null;
    return {
      id: row.id,
      date: row.date,
      presentMemberIds: JSON.parse(row.present_member_ids_json)
    };
  },
  async create(dateStr, presentMemberIds) {
    const json = JSON.stringify(presentMemberIds);
    await knex('attendance_records').insert({ date: dateStr, present_member_ids_json: json });
    return this.getByDate(dateStr);
  },
  async updateByDate(dateStr, presentMemberIds) {
    const json = JSON.stringify(presentMemberIds);
    await knex('attendance_records').where({ date: dateStr }).update({ present_member_ids_json: json });
    return this.getByDate(dateStr);
  },
  async deleteByDate(dateStr) {
    return knex('attendance_records').where({ date: dateStr }).del();
  }
};

module.exports = AttendanceModel;
