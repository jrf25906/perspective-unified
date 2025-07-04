#!/usr/bin/env node

/**
 * Local password reset script
 * Run this with: node reset-password-local.js
 */

require('dotenv').config();
const bcrypt = require('bcryptjs');
const knex = require('knex');
const knexfile = require('./knexfile');

async function resetPassword() {
  const email = 'jrf7ta2@virginia.edu';
  const newPassword = 'SuperSecure$2025#Pass!';
  
  console.log('🔐 Password Reset Tool\n');
  console.log(`Email: ${email}`);
  console.log(`New Password: ${newPassword}\n`);
  
  // Initialize database connection
  const db = knex(knexfile[process.env.NODE_ENV || 'development']);
  
  try {
    // Find user
    console.log('1. Finding user...');
    const user = await db('users').where('email', email).first();
    
    if (!user) {
      console.error('❌ User not found!');
      process.exit(1);
    }
    
    console.log(`✅ Found user: ${user.username} (ID: ${user.id})`);
    
    // Hash new password
    console.log('\n2. Hashing new password...');
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(newPassword, saltRounds);
    console.log(`✅ Password hashed (length: ${passwordHash.length})`);
    
    // Update password
    console.log('\n3. Updating password in database...');
    await db('users')
      .where('id', user.id)
      .update({
        password_hash: passwordHash,
        updated_at: new Date()
      });
    
    console.log('✅ Password updated successfully!');
    
    // Verify the update
    console.log('\n4. Verifying password...');
    const updatedUser = await db('users').where('id', user.id).first();
    const isValid = await bcrypt.compare(newPassword, updatedUser.password_hash);
    
    if (isValid) {
      console.log('✅ Password verification successful!');
      console.log('\n🎉 Password reset complete! You can now login with your new password.');
    } else {
      console.error('❌ Password verification failed!');
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error(error);
  } finally {
    await db.destroy();
  }
}

// Run the reset
resetPassword();