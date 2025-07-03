/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('refresh_tokens', function (table) {
    table.increments('id').primary();
    table.integer('user_id').unsigned().notNullable();
    table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.string('token_hash', 64).notNullable();
    table.string('jti', 36).notNullable().unique();
    table.string('device_id', 255);
    table.string('device_name', 255);
    table.text('user_agent');
    table.string('ip_address', 45);
    table.timestamp('issued_at').defaultTo(knex.fn.now());
    table.timestamp('expires_at').notNullable();
    table.timestamp('last_used_at');
    table.boolean('is_revoked').defaultTo(false);
    table.string('revocation_reason', 100);
    table.timestamp('revoked_at');
    table.integer('rotation_count').defaultTo(0);
    table.string('previous_token_jti', 36);
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.timestamp('updated_at').defaultTo(knex.fn.now());
    
    // Indexes for performance
    table.index('user_id');
    table.index('jti');
    table.index(['is_revoked', 'expires_at']);
    table.index('device_id');
    table.index('last_used_at');
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('refresh_tokens');
};