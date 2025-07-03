const axios = require('axios');

async function checkCurrentError() {
  try {
    // Test with a simple registration
    const timestamp = Date.now();
    console.log('Testing registration...');
    
    const response = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      {
        email: `test${timestamp}@example.com`,
        username: `test${timestamp}`,
        password: 'Test123!@#',
        firstName: 'Test',
        lastName: 'User'
      },
      {
        headers: {
          'Content-Type': 'application/json'
        },
        validateStatus: () => true
      }
    );
    
    console.log('Status:', response.status);
    console.log('Response:', JSON.stringify(response.data, null, 2));
    
    if (response.status === 201) {
      console.log('\n✅ AUTH IS WORKING!');
      console.log('\nNow testing login with user credentials...');
      
      const loginResponse = await axios.post(
        'https://backend-production-d218.up.railway.app/api/v1/auth/login',
        {
          email: 'jrf7ta2@virginia.edu',
          password: 'SuperSecure$2025#Pass!'
        },
        {
          validateStatus: () => true
        }
      );
      
      console.log('\nLogin status:', loginResponse.status);
      if (loginResponse.status === 200) {
        console.log('✅ User can login successfully!');
      } else {
        console.log('Login response:', JSON.stringify(loginResponse.data, null, 2));
      }
    }
  } catch (error) {
    console.error('Error:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
  }
}

checkCurrentError();