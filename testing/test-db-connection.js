#!/usr/bin/env node

const path = require('path');
const backendDir = path.join(__dirname, 'perspective-app', 'backend');
const knex = require(path.join(backendDir, 'node_modules', 'knex'));
const config = require(path.join(backendDir, 'knexfile.js'));

async function testDatabaseConnection() {
  console.log('🔍 Testing database connection...\n');
  
  const env = process.env.NODE_ENV || 'development';
  console.log(`Environment: ${env}`);
  console.log(`Database config:`, JSON.stringify(config[env], null, 2));
  
  try {
    const db = knex(config[env]);
    
    // Test connection
    await db.raw('SELECT 1+1 as result');
    console.log('✅ Database connection successful!');
    
    // Check if users table exists
    const hasUsersTable = await db.schema.hasTable('users');
    console.log(`\nUsers table exists: ${hasUsersTable ? '✅ Yes' : '❌ No'}`);
    
    if (hasUsersTable) {
      const userCount = await db('users').count('* as count');
      console.log(`Number of users in database: ${userCount[0].count}`);
    }
    
    // List all tables
    const tables = await db.raw(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    
    console.log('\nAvailable tables:');
    tables.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });
    
    await db.destroy();
  } catch (error) {
    console.error('❌ Database connection failed!');
    console.error('Error:', error.message);
    console.error('\nFull error:', error);
  }
}

testDatabaseConnection();