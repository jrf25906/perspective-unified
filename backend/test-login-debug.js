const axios = require('axios');

async function debugLogin() {
  console.log('Testing login with debug information...\n');
  
  const baseURL = 'https://backend-production-d218.up.railway.app/api/v1';
  
  // Test 1: Check if user exists with debug endpoint
  console.log('1. Checking if debug endpoints are available...');
  try {
    const debugResponse = await axios.get(`${baseURL}/auth/debug/recent-users`, {
      validateStatus: () => true
    });
    
    if (debugResponse.status === 200) {
      console.log('Debug endpoint available. Recent users:');
      console.log(JSON.stringify(debugResponse.data, null, 2));
    } else {
      console.log('Debug endpoint not available (status:', debugResponse.status + ')');
    }
  } catch (error) {
    console.log('Debug endpoint error:', error.message);
  }
  
  // Test 2: Try login with detailed error capture
  console.log('\n2. Testing login...');
  try {
    const loginResponse = await axios.post(`${baseURL}/auth/login`, {
      email: 'jrf7ta2@virginia.edu',
      password: 'SuperSecure$2025#Pass!'
    }, {
      validateStatus: () => true,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 Test Client'
      }
    });
    
    console.log('Login response status:', loginResponse.status);
    console.log('Response headers:', loginResponse.headers);
    console.log('Response data:', JSON.stringify(loginResponse.data, null, 2));
    
    if (loginResponse.status === 400 || loginResponse.status === 500) {
      // Try to get more info from error response
      const errorData = loginResponse.data;
      console.log('\nError details:');
      console.log('- Code:', errorData.error?.code);
      console.log('- Message:', errorData.error?.message);
      console.log('- Timestamp:', errorData.error?.timestamp);
      console.log('- Validation errors:', errorData.error?.validationErrors);
    }
  } catch (error) {
    console.log('Login request error:', error.message);
    if (error.response) {
      console.log('Error response:', error.response.data);
    }
  }
  
  // Test 3: Check database connection
  console.log('\n3. Checking database connection...');
  try {
    const dbResponse = await axios.get(`${baseURL}/diagnostics/database/connection`);
    console.log('Database status:', JSON.stringify(dbResponse.data, null, 2));
  } catch (error) {
    console.log('Database check error:', error.message);
  }
  
  // Test 4: Try to check password with debug endpoint
  console.log('\n4. Testing password check (if debug enabled)...');
  try {
    const pwdResponse = await axios.post(`${baseURL}/auth/debug/check-password`, {
      email: 'jrf7ta2@virginia.edu',
      password: 'SuperSecure$2025#Pass!'
    }, {
      validateStatus: () => true
    });
    
    console.log('Password check status:', pwdResponse.status);
    if (pwdResponse.status === 200) {
      console.log('Password check result:', JSON.stringify(pwdResponse.data, null, 2));
    }
  } catch (error) {
    console.log('Password check error:', error.message);
  }
}

debugLogin();