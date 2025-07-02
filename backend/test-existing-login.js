const axios = require('axios');

const API_BASE = 'https://backend-production-d218.up.railway.app/api/v1';

async function testLogin() {
  console.log('Testing login with existing user...');

  try {
    // Test with the user from the logs
    const loginResponse = await axios.post(`${API_BASE}/auth/login`, {
      email: 'iostest@example.com',
      password: 'testpass123'
    });
    
    console.log('✅ Login successful!');
    console.log('   User:', loginResponse.data.user.email);
    console.log('   Token:', loginResponse.data.token.substring(0, 30) + '...');
    
    // Test authenticated request
    const meResponse = await axios.get(`${API_BASE}/auth/me`, {
      headers: {
        'Authorization': `Bearer ${loginResponse.data.token}`
      }
    });
    
    console.log('✅ Authenticated request successful');
    console.log('   User data:', meResponse.data.user);
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testLogin();