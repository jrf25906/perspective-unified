#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Starting production server...');

// First, try to run migrations
console.log('📦 Running database migrations...');
const migrate = spawn('npx', ['knex', 'migrate:latest'], {
  stdio: 'inherit',
  env: process.env
});

migrate.on('close', (code) => {
  if (code !== 0) {
    console.warn('⚠️  Migration failed, but continuing with server start...');
  } else {
    console.log('✅ Migrations completed');
  }
  
  // Start the server regardless of migration result
  console.log('🎯 Starting server...');
  const server = spawn('node', ['dist/index.js'], {
    stdio: 'inherit',
    env: process.env
  });
  
  server.on('error', (err) => {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  });
  
  // Forward signals to child process
  process.on('SIGTERM', () => {
    server.kill('SIGTERM');
  });
  
  process.on('SIGINT', () => {
    server.kill('SIGINT');
  });
});