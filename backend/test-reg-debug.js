const axios = require('axios');

async function testRegistration() {
  // Test with the exact format the iOS app uses
  const user = {
    email: "test" + Date.now() + "@example.com",
    username: "testuser" + Date.now(), // No dots or special chars
    password: "SuperSecure$2025#Pass!",
    firstName: "Test",  // camelCase like iOS sends
    lastName: "User"
  };
  
  console.log('Testing registration with iOS format:', user);
  
  try {
    const response = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      user,
      { 
        headers: { 
          'Content-Type': 'application/json',
          'X-App-Version': 'iOS/1.0 (1)'
        },
        validateStatus: () => true
      }
    );
    
    console.log('\nStatus:', response.status);
    console.log('Response:', JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    console.error('Network error:', error.message);
  }
}

testRegistration();