const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1/test';

async function testDirectAuth() {
  // Test user data
  const timestamp = Date.now();
  const testUser = {
    email: `directtest${timestamp}@example.com`,
    username: `directuser${timestamp}`,
    password: 'TestPassword123!',
    firstName: 'Direct',
    lastName: 'Test'
  };
  
  console.log('🧪 Testing Direct Auth Endpoints');
  console.log('================================\n');
  
  try {
    // Test registration via direct endpoint
    console.log('1. Testing Direct Registration');
    console.log('   Endpoint: POST /api/v1/test/direct-register');
    console.log('   User:', testUser);
    
    const registerResponse = await axios.post(
      `${API_URL}/direct-register`,
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
      
      // Test login via direct endpoint
      console.log('2. Testing Direct Login');
      console.log('   Endpoint: POST /api/v1/test/direct-login');
      
      const loginResponse = await axios.post(
        `${API_URL}/direct-login`,
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
      
      if (loginResponse.status === 200) {
        console.log('   ✅ Login successful!');
        console.log('\n🎉 Direct auth endpoints are working correctly!');
        console.log('The issue is likely in UserTransformService or UserStatsService.');
      } else {
        console.log('   ❌ Login failed');
      }
    } else {
      console.log('   ❌ Registration failed');
    }
    
    // Compare with regular endpoints
    console.log('\n3. Testing Regular Registration (for comparison)');
    console.log('   Endpoint: POST /api/v1/auth/register');
    
    const regularUser = {
      ...testUser,
      email: `regular${timestamp}@example.com`,
      username: `regularuser${timestamp}`
    };
    
    const regularResponse = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      regularUser,
      { 
        headers: { 
          'Content-Type': 'application/json',
          'X-App-Version': 'Test/1.0'
        },
        validateStatus: () => true
      }
    );
    
    console.log('   Status:', regularResponse.status);
    console.log('   Response:', JSON.stringify(regularResponse.data, null, 2));
    
  } catch (error) {
    console.error('❌ Test failed with error:', error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
  }
}

// Run the test
testDirectAuth();