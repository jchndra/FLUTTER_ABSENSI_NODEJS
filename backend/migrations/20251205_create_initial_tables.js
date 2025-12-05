/**
 * Initial migration: create members and attendance_records tables
 */

exports.up = function(knex) {
  return knex.schema
    .createTable('members', function(table) {
      table.string('id').primary();
      table.string('name').notNullable();
      table.string('photo_url').nullable();
      table.timestamp('created_at').defaultTo(knex.fn.now());
    })
    .createTable('attendance_records', function(table) {
      table.increments('id').primary();
      table.date('date').notNullable().unique();
      table.text('present_member_ids_json').notNullable(); // JSON array of member IDs
      table.timestamp('created_at').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('attendance_records')
    .dropTableIfExists('members');
};
