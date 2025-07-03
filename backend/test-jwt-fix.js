const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function testJWTFix() {
  console.log('Testing JWT fix deployment...\n');
  
  // Test with user's actual credentials first
  try {
    console.log('Testing login with existing user...');
    const loginResponse = await axios.post(`${API_URL}/auth/login`, {
      email: 'jrf7ta2@virginia.edu',
      password: 'SuperSecure$2025#Pass!'
    }, {
      validateStatus: () => true
    });
    
    console.log('Login response status:', loginResponse.status);
    
    if (loginResponse.status === 200) {
      console.log('✅ LOGIN SUCCESSFUL! JWT fix is deployed!');
      console.log('Token received:', loginResponse.data.token ? 'Yes' : 'No');
      console.log('User:', loginResponse.data.user?.email);
      return;
    } else if (loginResponse.status === 401) {
      console.log('❌ Invalid credentials');
      if (loginResponse.data?.error?.message) {
        console.log('Error:', loginResponse.data.error.message);
      }
    } else {
      console.log('❌ Login failed:', loginResponse.status);
      if (loginResponse.data?.error?.message) {
        console.log('Error:', loginResponse.data.error.message);
      }
    }
  } catch (error) {
    console.error('Login test error:', error.message);
  }
  
  // Test registration to see specific error
  try {
    console.log('\nTesting registration to check JWT error...');
    const timestamp = Date.now();
    const regResponse = await axios.post(`${API_URL}/auth/register`, {
      email: `jwttest${timestamp}@test.com`,
      username: `jwttest${timestamp}`,
      password: `JWT${timestamp}!@#`,
      firstName: 'JWT',
      lastName: 'Test'
    }, {
      validateStatus: () => true
    });
    
    console.log('Registration response status:', regResponse.status);
    
    if (regResponse.status === 201) {
      console.log('✅ Registration successful! JWT fix is deployed!');
    } else {
      console.log('❌ Registration failed');
      if (regResponse.data?.error?.message) {
        console.log('Error message:', regResponse.data.error.message);
        
        if (regResponse.data.error.message.includes('expiresIn')) {
          console.log('\n⚠️  JWT fix NOT deployed yet - still has duplicate exp error');
        }
      }
    }
  } catch (error) {
    console.error('Registration test error:', error.message);
  }
}

testJWTFix();