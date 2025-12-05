/**
 * Migration: create users table
 */
exports.up = function(knex) {
  return knex.schema.createTable('users', function(table) {
    table.increments('id').primary();
    table.string('username', 100).notNullable().unique();
    table.string('password_hash', 255).notNullable();
    table.string('role', 50).notNullable().defaultTo('admin');
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex) {
  return knex.schema.dropTableIfExists('users');
};
