/**
 * Fix user_challenge_stats table for SQLite compatibility
 * SQLite doesn't support JSONB, so we need to use TEXT instead
 */

exports.up = async function(knex) {
  const isPostgres = knex.client.config.client === 'postgresql';
  
  // Check if table exists
  const tableExists = await knex.schema.hasTable('user_challenge_stats');
  
  if (!tableExists) {
    // Create the table with proper column types for the database
    return knex.schema.createTable('user_challenge_stats', function (table) {
      table.increments('id').primary();
      table.integer('user_id').unsigned().notNullable().unique();
      table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.integer('total_completed').notNullable().defaultTo(0);
      table.integer('total_correct').notNullable().defaultTo(0);
      table.integer('current_streak').notNullable().defaultTo(0);
      table.integer('longest_streak').notNullable().defaultTo(0);
      table.integer('total_xp_earned').notNullable().defaultTo(0);
      table.date('last_challenge_date');
      
      // Use JSONB for PostgreSQL, TEXT for SQLite
      if (isPostgres) {
        table.jsonb('difficulty_performance').notNullable().defaultTo('{}');
        table.jsonb('type_performance').notNullable().defaultTo('{}');
      } else {
        table.text('difficulty_performance').notNullable().defaultTo('{}');
        table.text('type_performance').notNullable().defaultTo('{}');
      }
      
      table.timestamps(true, true);
      
      // Indexes
      table.index('user_id');
    });
  } else {
    // Table exists, check if we need to add total_xp_earned column
    const hasXpColumn = await knex.schema.hasColumn('user_challenge_stats', 'total_xp_earned');
    
    if (!hasXpColumn) {
      await knex.schema.alterTable('user_challenge_stats', table => {
        table.integer('total_xp_earned').notNullable().defaultTo(0);
      });
    }
  }
};

exports.down = function(knex) {
  // Don't drop the table in down migration as it might have data
  // Just remove the total_xp_earned column if it exists
  return knex.schema.hasColumn('user_challenge_stats', 'total_xp_earned')
    .then(exists => {
      if (exists) {
        return knex.schema.alterTable('user_challenge_stats', table => {
          table.dropColumn('total_xp_earned');
        });
      }
    });
};