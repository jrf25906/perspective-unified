#!/usr/bin/env node

const axios = require('axios');
const crypto = require('crypto');

// Configuration
const BASE_URL = 'http://localhost:3000';

// Generate unique test credentials
const randomHex = crypto.randomBytes(4).toString('hex');
const TEST_USER = {
  email: `test_${randomHex}@example.com`,
  username: `testuser${randomHex}`,
  // Password that meets the entropy requirements and avoids common patterns
  password: `Zx9!kP${randomHex}Qm#2`
};

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m'
};

// Helper function to log with color
function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

// Helper function to log response details
function logResponse(title, response) {
  log(`\n${title}`, colors.bright + colors.blue);
  log('Status: ' + response.status, colors.green);
  
  // Log rate limit headers if present
  const rateLimitHeaders = Object.entries(response.headers)
    .filter(([key]) => key.toLowerCase().includes('ratelimit') || key.toLowerCase() === 'retry-after');
  
  if (rateLimitHeaders.length > 0) {
    log('Rate Limit Headers:', colors.magenta);
    rateLimitHeaders.forEach(([key, value]) => {
      console.log(`  ${key}: ${value}`);
    });
  }
  
  log('Response Data:', colors.cyan);
  console.log(JSON.stringify(response.data, null, 2));
}

// Helper function to log errors
function logError(title, error) {
  log(`\n${title}`, colors.bright + colors.red);
  if (error.response) {
    log('Status: ' + error.response.status, colors.red);
    
    // Log rate limit headers if present
    const rateLimitHeaders = Object.entries(error.response.headers)
      .filter(([key]) => key.toLowerCase().includes('ratelimit') || key.toLowerCase() === 'retry-after');
    
    if (rateLimitHeaders.length > 0) {
      log('Rate Limit Headers:', colors.magenta);
      rateLimitHeaders.forEach(([key, value]) => {
        console.log(`  ${key}: ${value}`);
      });
    }
    
    log('Response Data:', colors.red);
    console.log(JSON.stringify(error.response.data, null, 2));
  } else if (error.request) {
    log('No response received', colors.red);
    log('Request details:', colors.red);
    console.log('URL:', error.config?.url);
    console.log('Method:', error.config?.method);
    console.log('Data:', error.config?.data);
  } else {
    log('Error: ' + error.message, colors.red);
  }
}

// Check rate limit status
async function checkRateLimit() {
  try {
    const response = await axios.head(`${BASE_URL}/api/auth/register`);
    return response.headers;
  } catch (error) {
    if (error.response && error.response.status === 429) {
      return error.response.headers;
    }
    throw error;
  }
}

// Test registration
async function testRegister() {
  try {
    log('\n=== TESTING USER REGISTRATION ===', colors.bright + colors.yellow);
    log(`Email: ${TEST_USER.email}`, colors.cyan);
    log(`Username: ${TEST_USER.username}`, colors.cyan);
    log(`Password: ${TEST_USER.password}`, colors.cyan);
    
    const response = await axios.post(`${BASE_URL}/api/auth/register`, TEST_USER);
    logResponse('REGISTRATION SUCCESS', response);
    
    return response.data;
  } catch (error) {
    logError('REGISTRATION FAILED', error);
    throw error;
  }
}

// Test login
async function testLogin() {
  try {
    log('\n=== TESTING USER LOGIN ===', colors.bright + colors.yellow);
    log(`Email: ${TEST_USER.email}`, colors.cyan);
    
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

// Test get profile
async function testGetProfile(token) {
  try {
    log('\n=== TESTING GET USER PROFILE ===', colors.bright + colors.yellow);
    log(`Token: ${token.substring(0, 20)}...`, colors.cyan);
    
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

// Test unauthorized access
async function testUnauthorizedAccess() {
  try {
    log('\n=== TESTING UNAUTHORIZED ACCESS ===', colors.bright + colors.yellow);
    
    const response = await axios.get(`${BASE_URL}/api/auth/profile`);
    logResponse('UNEXPECTED SUCCESS', response);
  } catch (error) {
    if (error.response && error.response.status === 401) {
      log('✅ Expected 401 Unauthorized received', colors.green);
      logError('GET PROFILE UNAUTHORIZED (Expected)', error);
    } else {
      logError('GET PROFILE FAILED (Unexpected)', error);
    }
  }
}

// Test with invalid token
async function testInvalidToken() {
  try {
    log('\n=== TESTING WITH INVALID TOKEN ===', colors.bright + colors.yellow);
    
    const response = await axios.get(`${BASE_URL}/api/auth/profile`, {
      headers: {
        'Authorization': 'Bearer invalid-token-here'
      }
    });
    logResponse('UNEXPECTED SUCCESS', response);
  } catch (error) {
    if (error.response && error.response.status === 401) {
      log('✅ Expected 401 Unauthorized received', colors.green);
      logError('INVALID TOKEN REJECTED (Expected)', error);
    } else {
      logError('INVALID TOKEN FAILED (Unexpected)', error);
    }
  }
}

// Main test runner
async function runTests() {
  log('\n🚀 Starting Comprehensive Authentication Endpoint Tests', colors.bright + colors.green);
  log(`Server: ${BASE_URL}`, colors.cyan);
  log('=' .repeat(60), colors.yellow);

  try {
    // Check rate limit status first
    log('\n📊 Checking rate limit status...', colors.magenta);
    const headers = await checkRateLimit();
    const remaining = headers['ratelimit-remaining'];
    const retryAfter = headers['retry-after'];
    
    if (remaining === '0' && retryAfter) {
      log(`\n⏳ Rate limit exceeded. Need to wait ${retryAfter} seconds.`, colors.yellow);
      log('Please run this script again later.', colors.yellow);
      return;
    }
    
    log(`Rate limit remaining: ${remaining || 'unknown'}`, colors.green);
    
    let token = null;
    
    // Test 1: Register new user
    try {
      const registerData = await testRegister();
      if (registerData.token) {
        token = registerData.token;
        log('\n✅ Token received from registration', colors.green);
      }
    } catch (error) {
      // Continue to login test even if registration fails
      log('\n⚠️  Registration failed, attempting login...', colors.yellow);
    }
    
    // Wait a bit to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Test 2: Login with the user
    if (!token) {
      try {
        const loginData = await testLogin();
        if (loginData.token) {
          token = loginData.token;
          log('\n✅ Token received from login', colors.green);
        }
      } catch (error) {
        log('\n❌ Both registration and login failed', colors.red);
      }
    }
    
    // Test 3: Profile access tests
    if (token) {
      await new Promise(resolve => setTimeout(resolve, 2000));
      await testGetProfile(token);
      
      await new Promise(resolve => setTimeout(resolve, 2000));
      await testInvalidToken();
    }
    
    // Test 4: Unauthorized access
    await new Promise(resolve => setTimeout(resolve, 2000));
    await testUnauthorizedAccess();
    
    log('\n✨ All tests completed!', colors.bright + colors.green);
    log('\n📋 Summary:', colors.bright + colors.cyan);
    log(`- Test user: ${TEST_USER.email}`, colors.cyan);
    log(`- Token obtained: ${token ? 'Yes' : 'No'}`, token ? colors.green : colors.red);
    
  } catch (error) {
    log('\n❌ Test suite encountered an unexpected error', colors.bright + colors.red);
    console.error(error);
  }
}

// Run the tests
runTests();