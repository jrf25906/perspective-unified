const axios = require('axios');

const API_BASE = 'https://backend-production-d218.up.railway.app/api/v1';
const TEST_USER = {
  email: 'iostest' + Date.now() + '@example.com',
  username: 'iostest' + Date.now(),
  password: 'testpass123',
  first_name: 'iOS',
  last_name: 'Test'
};

async function testAuthFlow() {
  console.log('Testing auth flow with:', {
    email: TEST_USER.email,
    username: TEST_USER.username
  });

  try {
    // 1. Test Registration
    console.log('\n1. Testing Registration...');
    const registerResponse = await axios.post(`${API_BASE}/auth/register`, TEST_USER);
    console.log('✅ Registration successful');
    console.log('   User ID:', registerResponse.data.user.id);
    console.log('   Token received:', registerResponse.data.token.substring(0, 20) + '...');
    
    // Wait a moment
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // 2. Test Login with same credentials
    console.log('\n2. Testing Login...');
    const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
      email: TEST_USER.email,
      password: TEST_USER.password
    });
    console.log('✅ Login successful');
    console.log('   User ID:', loginResponse.data.user.id);
    console.log('   Token received:', loginResponse.data.token.substring(0, 20) + '...');
    
    // 3. Test authenticated request
    console.log('\n3. Testing Authenticated Request...');
    const meResponse = await axios.get(`${API_BASE}/auth/me`, {
      headers: {
        'Authorization': `Bearer ${loginResponse.data.token}`
      }
    });
    console.log('✅ Authenticated request successful');
    console.log('   User email:', meResponse.data.user.email);
    
    // 4. Test password verification (debug endpoint)
    console.log('\n4. Testing Password Verification...');
    try {
      const debugResponse = await axios.post(`${API_BASE}/auth/debug/check-password`, {
        email: TEST_USER.email,
        password: TEST_USER.password
      });
      console.log('✅ Password verification:', debugResponse.data.passwordTest?.isValid ? 'VALID' : 'INVALID');
      console.log('   Hash rounds:', debugResponse.data.passwordTest?.hashRounds);
    } catch (error) {
      console.log('⚠️  Debug endpoint not available (production mode?)');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    if (error.response?.data?.error) {
      console.error('   Error details:', error.response.data.error);
    }
  }
}

// Run the test
testAuthFlow();