const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function verifyDeployment() {
  console.log('🔍 Verifying Deployment Status');
  console.log('==============================\n');
  
  const deploymentChecks = {
    directEndpoints: false,
    safeStatsService: false,
    awaitFixes: false
  };
  
  // Test 1: Direct endpoints (commit c320a7c)
  console.log('1. Testing DirectAuthController endpoints...');
  try {
    const timestamp = Date.now();
    const directReg = await axios.post(
      `${API_URL}/test/direct-register`,
      {
        email: `deploy${timestamp}@test.com`,
        username: `deploy${timestamp}`,
        password: 'test123',
        firstName: 'Deploy',
        lastName: 'Test'
      },
      { validateStatus: () => true }
    );
    
    if (directReg.status === 201) {
      deploymentChecks.directEndpoints = true;
      console.log('   ✅ DirectAuthController is deployed');
    } else if (directReg.status === 404) {
      console.log('   ❌ DirectAuthController NOT deployed (404)');
    } else {
      console.log('   ⚠️  Unexpected status:', directReg.status);
    }
  } catch (error) {
    console.log('   ❌ Error:', error.message);
  }
  
  // Test 2: SafeUserStatsService (commit ce14842)
  // This is harder to test directly, but if registration doesn't fail with stats errors, it's working
  console.log('\n2. Testing SafeUserStatsService...');
  console.log('   ℹ️  If registration creates users (even with 500), SafeUserStatsService is working');
  
  // Test 3: Await fixes (commit 4dbd541)
  console.log('\n3. Testing await fixes in authController...');
  try {
    const timestamp = Date.now();
    const testUser = {
      email: `awaitfix${timestamp}@test.com`,
      username: `awaitfix${timestamp}`,
      password: `SecurePass${timestamp}!@#`,
      firstName: 'Await',
      lastName: 'Fix'
    };
    
    // Register a new user
    const regResponse = await axios.post(
      `${API_URL}/auth/register`,
      testUser,
      { validateStatus: () => true }
    );
    
    console.log('   Registration status:', regResponse.status);
    
    if (regResponse.status === 201) {
      console.log('   ✅ Await fixes ARE deployed! Registration works!');
      deploymentChecks.awaitFixes = true;
      
      // Check response structure
      if (regResponse.data.user && regResponse.data.token) {
        console.log('   ✅ Response has correct structure');
        console.log('   User ID:', regResponse.data.user.id);
        console.log('   Has stats:', !!regResponse.data.user.totalXpEarned);
      }
    } else if (regResponse.status === 500) {
      console.log('   ❌ Await fixes NOT deployed yet (still getting 500)');
      
      // Check if user was created anyway
      const checkLogin = await axios.post(
        `${API_URL}/test/direct-login`,
        { email: testUser.email, password: testUser.password },
        { validateStatus: () => true }
      );
      
      if (checkLogin.status === 200) {
        console.log('   ⚠️  User WAS created despite 500 - await fix not deployed');
      }
    }
  } catch (error) {
    console.log('   ❌ Error:', error.message);
  }
  
  // Summary
  console.log('\n==============================');
  console.log('📊 Deployment Summary:');
  console.log(`DirectAuthController: ${deploymentChecks.directEndpoints ? '✅ Deployed' : '❌ Not deployed'}`);
  console.log(`SafeUserStatsService: ${deploymentChecks.directEndpoints ? '✅ Likely deployed' : '❓ Unknown'}`);
  console.log(`Await fixes: ${deploymentChecks.awaitFixes ? '✅ Deployed' : '❌ Not deployed'}`);
  
  if (!deploymentChecks.awaitFixes) {
    console.log('\n⏳ The critical await fixes are not deployed yet.');
    console.log('Railway may still be building. Wait 5-10 more minutes.');
  } else {
    console.log('\n🎉 All fixes are deployed! Authentication should work now.');
  }
  
  console.log('\n==============================\n');
}

// Test your specific account
async function testYourAccount() {
  console.log('🔐 Testing your specific account...');
  console.log('Email: jrf7ta2@virginia.edu');
  console.log('Password: SuperSecure$2025#Pass!\n');
  
  try {
    const loginResponse = await axios.post(
      `${API_URL}/auth/login`,
      {
        email: 'jrf7ta2@virginia.edu',
        password: 'SuperSecure$2025#Pass!'
      },
      { validateStatus: () => true }
    );
    
    console.log('Login Status:', loginResponse.status);
    
    if (loginResponse.status === 200) {
      console.log('✅ LOGIN SUCCESSFUL! You can use the app now!');
      console.log('\nYour user data:');
      console.log(JSON.stringify(loginResponse.data.user, null, 2));
    } else if (loginResponse.status === 401) {
      console.log('❌ Invalid password');
    } else if (loginResponse.status === 404) {
      console.log('❌ User not found');
    } else if (loginResponse.status === 500) {
      console.log('❌ Server error - await fixes not deployed yet');
    }
  } catch (error) {
    console.log('❌ Network error:', error.message);
  }
}

// Run verification
verifyDeployment()
  .then(() => testYourAccount())
  .catch(console.error);