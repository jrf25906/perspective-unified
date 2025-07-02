const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1/auth';

async function testRegularAuth() {
  // Test user data with complex password
  const timestamp = Date.now();
  const testUser = {
    email: `regtest${timestamp}@example.com`,
    username: `reguser${timestamp}`,
    password: `SecureP@ss${timestamp}!Complex#2025`, // Very unique password
    firstName: 'Regular',
    lastName: 'Test'
  };
  
  console.log('🧪 Testing Regular Auth Endpoints with Complex Password');
  console.log('======================================================\n');
  
  try {
    // Test registration
    console.log('1. Testing Regular Registration');
    console.log('   Endpoint: POST /api/v1/auth/register');
    console.log('   User:', {
      ...testUser,
      password: '[REDACTED]'
    });
    
    const registerResponse = await axios.post(
      `${API_URL}/register`,
      testUser,
      { 
        headers: { 
          'Content-Type': 'application/json',
          'X-App-Version': 'Test/1.0'
        },
        validateStatus: () => true
      }
    );
    
    console.log('   Status:', registerResponse.status);
    console.log('   Response:', JSON.stringify(registerResponse.data, null, 2));
    
    if (registerResponse.status === 201) {
      console.log('   ✅ Registration successful!\n');
      
      // Test login
      console.log('2. Testing Regular Login');
      console.log('   Endpoint: POST /api/v1/auth/login');
      
      const loginResponse = await axios.post(
        `${API_URL}/login`,
        {
          email: testUser.email,
          password: testUser.password
        },
        { 
          headers: { 
            'Content-Type': 'application/json',
            'X-App-Version': 'Test/1.0'
          },
          validateStatus: () => true
        }
      );
      
      console.log('   Status:', loginResponse.status);
      console.log('   Response:', JSON.stringify(loginResponse.data, null, 2));
      
    } else if (registerResponse.status === 500) {
      console.log('   ❌ Registration failed with 500 error\n');
      
      // Check if user was actually created via direct endpoint
      console.log('3. Checking if user exists via direct login');
      
      const checkResponse = await axios.post(
        'https://backend-production-d218.up.railway.app/api/v1/test/direct-login',
        {
          email: testUser.email,
          password: testUser.password
        },
        { 
          headers: { 
            'Content-Type': 'application/json',
            'X-App-Version': 'Test/1.0'
          },
          validateStatus: () => true
        }
      );
      
      console.log('   Status:', checkResponse.status);
      
      if (checkResponse.status === 200) {
        console.log('   ✅ User WAS created despite 500 error!');
        console.log('   This confirms the issue is in response transformation.');
      } else if (checkResponse.status === 404) {
        console.log('   ❌ User was NOT created - issue is in user creation.');
      }
    }
    
  } catch (error) {
    console.error('❌ Test failed with error:', error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
  }
}

// Run the test
testRegularAuth();