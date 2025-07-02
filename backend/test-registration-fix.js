const axios = require('axios');

const testRegistration = async () => {
  const timestamp = Date.now();
  const testData = {
    email: `test.user${timestamp}@example.com`,
    username: `testuser${timestamp}`,
    firstName: "Test",
    lastName: "User",
    password: "SuperSecure$2025#Pass!"
  };

  console.log('Testing registration with data:', testData);

  try {
    const response = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      testData,
      {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': 'iOS/1.0 (1)'
        }
      }
    );
    
    console.log('✅ Registration successful!');
    console.log('Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('❌ Registration failed!');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
      console.error('Headers:', error.response.headers);
    } else {
      console.error('Error:', error.message);
    }
  }
};

testRegistration();