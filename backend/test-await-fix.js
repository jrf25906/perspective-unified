const axios = require('axios');

async function testAwaitFix() {
  console.log('🔍 Testing if await fix is deployed...\n');
  
  // Create a unique test user
  const timestamp = Date.now();
  const testUser = {
    email: `awaittest${timestamp}@test.com`,
    username: `awaittest${timestamp}`,
    password: `AwaitTest${timestamp}!@#`,
    firstName: 'Await',
    lastName: 'Test'
  };
  
  try {
    // Register
    console.log('1. Attempting registration...');
    const regResponse = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      testUser,
      { validateStatus: () => true }
    );
    
    console.log('   Status:', regResponse.status);
    
    if (regResponse.status === 201) {
      console.log('   ✅ AWAIT FIX IS DEPLOYED!');
      console.log('   Response structure:', Object.keys(regResponse.data));
      console.log('   Has user object:', !!regResponse.data.user);
      console.log('   Has token:', !!regResponse.data.token);
      
      if (regResponse.data.user) {
        console.log('   User type:', typeof regResponse.data.user);
        console.log('   Is Promise:', regResponse.data.user instanceof Promise);
        console.log('   User ID:', regResponse.data.user.id);
      }
      
      return true;
    } else if (regResponse.status === 500) {
      console.log('   ❌ AWAIT FIX NOT DEPLOYED');
      console.log('   Error:', regResponse.data);
      
      // Debug: Check what the server is actually returning
      console.log('\n2. Checking raw response headers...');
      console.log('   Server header:', regResponse.headers.server);
      console.log('   X-Powered-By:', regResponse.headers['x-powered-by']);
      
      return false;
    }
    
  } catch (error) {
    console.log('❌ Network error:', error.message);
    return false;
  }
}

async function testYourLogin() {
  console.log('\n\n🔐 Testing your specific login...');
  
  try {
    const response = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/login',
      {
        email: 'jrf7ta2@virginia.edu',
        password: 'SuperSecure$2025#Pass!'
      },
      { 
        validateStatus: () => true,
        headers: {
          'X-Test-Time': new Date().toISOString()
        }
      }
    );
    
    console.log('Status:', response.status);
    
    if (response.status === 200) {
      console.log('✅ YOU CAN NOW LOGIN!');
      console.log('User:', response.data.user);
    } else {
      console.log('❌ Login still failing');
      console.log('Response:', response.data);
    }
    
  } catch (error) {
    console.log('Error:', error.message);
  }
}

// Run tests
testAwaitFix()
  .then(deployed => {
    if (!deployed) {
      console.log('\n⚠️  The deployment shows v1.0.1 but the await fix is not active.');
      console.log('Railway may have cached an old build.');
    }
    return testYourLogin();
  });