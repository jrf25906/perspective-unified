#!/usr/bin/env node

const axios = require('axios');
const crypto = require('crypto');

// Configuration
const BASE_URL = 'http://localhost:3000';
const TEST_USER = {
  email: `test_${crypto.randomBytes(4).toString('hex')}@example.com`,
  username: `testuser${crypto.randomBytes(4).toString('hex')}`,
  password: `SecureP@ss${crypto.randomBytes(4).toString('hex')}2024!`
};

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

// Helper function to log with color
function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

// Helper function to log JSON responses
function logResponse(title, response) {
  log(`\n${title}`, colors.bright + colors.blue);
  log('Status: ' + response.status, colors.green);
  log('Headers:', colors.cyan);
  console.log(response.headers);
  log('Response Data:', colors.cyan);
  console.log(JSON.stringify(response.data, null, 2));
}

// Helper function to log errors
function logError(title, error) {
  log(`\n${title}`, colors.bright + colors.red);
  if (error.response) {
    log('Status: ' + error.response.status, colors.red);
    log('Response Data:', colors.red);
    console.log(JSON.stringify(error.response.data, null, 2));
  } else if (error.request) {
    log('No response received', colors.red);
    console.log(error.request);
  } else {
    log('Error: ' + error.message, colors.red);
  }
}

// Test functions
async function testRegister() {
  try {
    log('\n=== TESTING USER REGISTRATION ===', colors.bright + colors.yellow);
    log(`Attempting to register user: ${TEST_USER.email}`, colors.cyan);
    
    const response = await axios.post(`${BASE_URL}/api/auth/register`, TEST_USER);
    logResponse('REGISTRATION SUCCESS', response);
    
    return response.data;
  } catch (error) {
    logError('REGISTRATION FAILED', error);
    throw error;
  }
}

async function testLogin() {
  try {
    log('\n=== TESTING USER LOGIN ===', colors.bright + colors.yellow);
    log(`Attempting to login with: ${TEST_USER.email}`, colors.cyan);
    
    const response = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: TEST_USER.email,
      password: TEST_USER.password
    });
    logResponse('LOGIN SUCCESS', response);
    
    return response.data;
  } catch (error) {
    logError('LOGIN FAILED', error);
    throw error;
  }
}

async function testGetProfile(token) {
  try {
    log('\n=== TESTING GET USER PROFILE ===', colors.bright + colors.yellow);
    log(`Using token: ${token}`, colors.cyan);
    
    const response = await axios.get(`${BASE_URL}/api/auth/profile`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    logResponse('GET PROFILE SUCCESS', response);
    
    return response.data;
  } catch (error) {
    logError('GET PROFILE FAILED', error);
    throw error;
  }
}

// Also test with invalid/missing token
async function testGetProfileUnauthorized() {
  try {
    log('\n=== TESTING GET PROFILE WITHOUT TOKEN ===', colors.bright + colors.yellow);
    
    const response = await axios.get(`${BASE_URL}/api/auth/profile`);
    logResponse('UNEXPECTED SUCCESS', response);
  } catch (error) {
    if (error.response && error.response.status === 401) {
      log('Expected 401 Unauthorized received', colors.green);
      logError('GET PROFILE UNAUTHORIZED (Expected)', error);
    } else {
      logError('GET PROFILE FAILED (Unexpected)', error);
    }
  }
}

// Helper function to add delay
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Main test runner
async function runTests() {
  log('\n🚀 Starting Authentication Endpoint Tests', colors.bright + colors.green);
  log(`Server: ${BASE_URL}`, colors.cyan);
  log(`Test User Email: ${TEST_USER.email}`, colors.cyan);
  log(`Test Username: ${TEST_USER.username}`, colors.cyan);
  log(`Test Password: ${TEST_USER.password}`, colors.cyan);
  log('=' .repeat(50), colors.yellow);

  let token = null;
  
  try {
    // Test 1: Register new user
    const registerData = await testRegister();
    
    // Extract token if provided during registration
    if (registerData.token) {
      token = registerData.token;
      log('\n✅ Token received from registration', colors.green);
    }
    
    // Wait a bit to avoid rate limiting
    log('\n⏳ Waiting 2 seconds to avoid rate limiting...', colors.yellow);
    await delay(2000);
    
    // Test 2: Login with the new user
    const loginData = await testLogin();
    
    // Use login token if available
    if (loginData.token) {
      token = loginData.token;
      log('\n✅ Token received from login', colors.green);
    }
    
    if (!token) {
      log('\n❌ No token received from registration or login', colors.red);
      return;
    }
    
    // Test 3: Get user profile with token
    await testGetProfile(token);
    
    // Test 4: Try to get profile without token (should fail)
    await testGetProfileUnauthorized();
    
    log('\n✨ All tests completed!', colors.bright + colors.green);
    
  } catch (error) {
    log('\n❌ Test suite failed', colors.bright + colors.red);
  }
}

// Check if axios is installed
try {
  require.resolve('axios');
  runTests();
} catch (e) {
  log('axios is not installed. Installing it now...', colors.yellow);
  const { execSync } = require('child_process');
  execSync('npm install axios', { stdio: 'inherit' });
  log('axios installed successfully. Please run the script again.', colors.green);
}