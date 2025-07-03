const axios = require('axios');

async function testAuthFlow() {
  const baseURL = 'https://backend-production-d218.up.railway.app/api/v1/auth';
  
  console.log('Testing authentication flow...\n');
  
  // Test 1: Try login with user's credentials
  console.log('1. Testing login with existing account...');
  try {
    const loginResponse = await axios.post(`${baseURL}/login`, {
      username: 'jimmy',
      password: 'SuperSecure$2025#Pass\!'
    }, {
      validateStatus: () => true,
      timeout: 10000
    });
    
    console.log('Login status:', loginResponse.status);
    if (loginResponse.status === 200) {
      console.log('✅ LOGIN SUCCESSFUL\!');
      console.log('User:', loginResponse.data.user?.email);
      console.log('Has tokens:', \!\!loginResponse.data.accessToken && \!\!loginResponse.data.refreshToken);
    } else {
      console.log('❌ Login failed:', loginResponse.data?.error?.message);
    }
  } catch (error) {
    console.log('❌ Login error:', error.message);
  }
  
  // Test 2: Try registration with a new account
  console.log('\n2. Testing new registration...');
  const timestamp = Date.now();
  try {
    const regResponse = await axios.post(`${baseURL}/register`, {
      email: `test${timestamp}@example.com`,
      username: `testuser${timestamp}`,
      password: `Test${timestamp}\!@#$`,
      firstName: 'Test',
      lastName: 'User'
    }, {
      validateStatus: () => true,
      timeout: 10000
    });
    
    console.log('Registration status:', regResponse.status);
    if (regResponse.status === 201) {
      console.log('✅ REGISTRATION SUCCESSFUL\!');
      console.log('User:', regResponse.data.user?.email);
      console.log('Has tokens:', \!\!regResponse.data.accessToken && \!\!regResponse.data.refreshToken);
    } else {
      console.log('❌ Registration failed:', regResponse.data?.error?.message);
      if (regResponse.data?.error?.details) {
        console.log('Error details:', regResponse.data.error.details);
      }
    }
  } catch (error) {
    console.log('❌ Registration error:', error.message);
  }
  
  // Test 3: Check version endpoint
  console.log('\n3. Checking deployment version...');
  try {
    const versionResponse = await axios.get(`${baseURL}/version`);
    console.log('Version info:', versionResponse.data);
  } catch (error) {
    console.log('Version check error:', error.message);
  }
}

testAuthFlow();
