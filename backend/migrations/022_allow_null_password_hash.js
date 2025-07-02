/**
 * Allow null password_hash for social login users (Google, etc.)
 * 
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.alterTable('users', function(table) {
    // Change password_hash to allow null values
    table.string('password_hash').nullable().alter();
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.alterTable('users', function(table) {
    // Revert to not nullable (this will fail if there are null values)
    table.string('password_hash').notNullable().alter();
  });
};