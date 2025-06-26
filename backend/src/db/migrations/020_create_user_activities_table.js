/**
 * User Activities Table Migration
 * 
 * Creates table to track comprehensive user activities beyond just challenges
 * Supports the ActivityTrackingService with proper indexing for performance
 */

exports.up = function(knex) {
  return knex.schema.createTable('user_activities', function(table) {
    table.increments('id').primary();
    table.integer('user_id').unsigned().notNullable()
      .references('id').inTable('users').onDelete('CASCADE');
    
    // Activity details
    table.string('type', 50).notNullable(); // ActivityType enum
    table.string('title', 200).notNullable();
    table.text('description').notNullable();
    table.json('metadata').nullable(); // Additional activity data
    table.integer('xp_earned').defaultTo(0);
    
    // Categorization and visibility
    table.string('category', 30).notNullable(); // ActivityCategory enum
    table.string('visibility', 20).defaultTo('public'); // ActivityVisibility enum
    
    // Timestamps
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.timestamp('updated_at').defaultTo(knex.fn.now());
    
    // Indexes for performance
    table.index(['user_id', 'created_at'], 'idx_user_activities_user_date');
    table.index(['type', 'created_at'], 'idx_user_activities_type_date');
    table.index(['category', 'created_at'], 'idx_user_activities_category_date');
    table.index(['visibility', 'created_at'], 'idx_user_activities_visibility_date');
    table.index('created_at', 'idx_user_activities_created_at');
    
    // Composite index for public activity feeds
    table.index(['visibility', 'created_at', 'user_id'], 'idx_user_activities_public_feed');
  });
};

exports.down = function(knex) {
  return knex.schema.dropTableIfExists('user_activities');
}; 