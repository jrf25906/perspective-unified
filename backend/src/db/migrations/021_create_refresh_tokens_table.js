/**
 * Refresh Tokens Table Migration
 * 
 * Creates table to manage JWT refresh tokens with security features:
 * - Token rotation for security
 * - Expiration tracking
 * - Device/session identification
 * - Revocation capability
 */

exports.up = function(knex) {
  return knex.schema.createTable('refresh_tokens', function(table) {
    table.increments('id').primary();
    table.integer('user_id').unsigned().notNullable()
      .references('id').inTable('users').onDelete('CASCADE');
    
    // Token details
    table.string('token_hash', 255).notNullable().unique(); // SHA-256 hash of refresh token
    table.string('jti', 36).notNullable().unique(); // JWT ID for token tracking
    
    // Security and session info
    table.string('device_id', 100).nullable(); // Device identifier
    table.string('device_name', 200).nullable(); // Human-readable device name
    table.string('user_agent', 500).nullable(); // Client user agent
    table.string('ip_address', 45).nullable(); // IPv4/IPv6 address
    
    // Token lifecycle
    table.timestamp('issued_at').defaultTo(knex.fn.now());
    table.timestamp('expires_at').notNullable();
    table.timestamp('last_used_at').nullable();
    table.boolean('is_revoked').defaultTo(false);
    table.timestamp('revoked_at').nullable();
    table.string('revocation_reason', 100).nullable();
    
    // Token rotation tracking
    table.string('previous_token_jti', 36).nullable(); // Links to previous token in rotation
    table.integer('rotation_count').defaultTo(0); // Number of times token has been rotated
    
    // Timestamps
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.timestamp('updated_at').defaultTo(knex.fn.now());
    
    // Indexes for performance and security
    table.index('user_id', 'idx_refresh_tokens_user_id');
    table.index('token_hash', 'idx_refresh_tokens_token_hash');
    table.index('jti', 'idx_refresh_tokens_jti');
    table.index('expires_at', 'idx_refresh_tokens_expires_at');
    table.index(['user_id', 'is_revoked'], 'idx_refresh_tokens_user_active');
    table.index(['user_id', 'device_id'], 'idx_refresh_tokens_user_device');
    
    // Composite index for cleanup operations
    table.index(['expires_at', 'is_revoked'], 'idx_refresh_tokens_cleanup');
  });
};

exports.down = function(knex) {
  return knex.schema.dropTableIfExists('refresh_tokens');
}; 