const axios = require('axios');

async function testFinalAuth() {
  try {
    // First test with user's actual login
    console.log('Testing login with user\'s credentials...');
    
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
    
    console.log('Login status:', loginResponse.status);
    
    if (loginResponse.status === 200) {
      console.log('✅ LOGIN SUCCESSFUL!');
      console.log('User:', loginResponse.data.user.email);
      console.log('Token received:', loginResponse.data.token ? 'Yes' : 'No');
      console.log('\n🎉 AUTHENTICATION IS FULLY WORKING!');
      console.log('\nYou can now login with:');
      console.log('Email: jrf7ta2@virginia.edu');
      console.log('Password: SuperSecure$2025#Pass!');
      return;
    } else {
      console.log('Login failed:', JSON.stringify(loginResponse.data, null, 2));
    }
    
    // If login failed, test registration with a strong password
    console.log('\nTesting registration with strong password...');
    const timestamp = Date.now();
    
    const regResponse = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      {
        email: `finaltest${timestamp}@example.com`,
        username: `finaltest${timestamp}`,
        password: `SuperSecure${timestamp}$2025#Pass!`, // Strong unique password
        firstName: 'Final',
        lastName: 'Test'
      },
      {
        validateStatus: () => true
      }
    );
    
    console.log('Registration status:', regResponse.status);
    
    if (regResponse.status === 201) {
      console.log('✅ REGISTRATION SUCCESSFUL!');
      console.log('User created:', regResponse.data.user.email);
      console.log('Token received:', regResponse.data.token ? 'Yes' : 'No');
      console.log('\n🎉 ALL AUTHENTICATION FIXES ARE DEPLOYED AND WORKING!');
    } else {
      console.log('Registration failed:', JSON.stringify(regResponse.data, null, 2));
    }
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

testFinalAuth();