const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function checkUserStatus() {
  const userEmail = 'jrf7ta2@virginia.edu';
  const userPassword = 'SuperSecure$2025#Pass!';
  
  console.log('🔍 Checking User Account Status');
  console.log('================================\n');
  console.log(`Email: ${userEmail}`);
  console.log(`Username: jimmy\n`);
  
  // Step 1: Check deployment status
  console.log('1. Checking if new deployment is live...');
  try {
    const directTest = await axios.post(
      `${API_URL}/test/direct-register`,
      { 
        email: 'deployment-test@example.com',
        username: 'deploytest',
        password: 'test123',
        firstName: 'Deploy',
        lastName: 'Test'
      },
      { validateStatus: () => true }
    );
    
    if (directTest.status === 404) {
      console.log('   ❌ New deployment NOT live yet (getting 404)');
      console.log('   ⏳ Railway is still deploying. Please wait a few minutes.\n');
      return;
    } else {
      console.log('   ✅ New deployment is LIVE!\n');
    }
  } catch (error) {
    console.log('   ❌ Could not reach server:', error.message);
    return;
  }
  
  // Step 2: Check if user exists via direct login
  console.log('2. Checking if your account exists...');
  try {
    const checkLogin = await axios.post(
      `${API_URL}/test/direct-login`,
      {
        email: userEmail,
        password: userPassword
      },
      { validateStatus: () => true }
    );
    
    if (checkLogin.status === 200) {
      console.log('   ✅ Your account EXISTS in the database');
      console.log('   User ID:', checkLogin.data.user.id);
      console.log('   Username:', checkLogin.data.user.username);
      console.log('   Echo Score:', checkLogin.data.user.echoScore);
    } else if (checkLogin.status === 404) {
      console.log('   ❌ Account does NOT exist');
      console.log('   You should be able to register once deployment completes.');
      return;
    } else if (checkLogin.status === 401) {
      console.log('   ⚠️  Account exists but password is incorrect');
      return;
    }
  } catch (error) {
    console.log('   ❌ Error checking account:', error.message);
    return;
  }
  
  // Step 3: Test regular login (should work with fixes)
  console.log('\n3. Testing regular login endpoint...');
  try {
    const regularLogin = await axios.post(
      `${API_URL}/auth/login`,
      {
        email: userEmail,
        password: userPassword
      },
      { validateStatus: () => true }
    );
    
    console.log('   Status:', regularLogin.status);
    
    if (regularLogin.status === 200) {
      console.log('   ✅ LOGIN SUCCESSFUL! 🎉');
      console.log('   The authentication issues have been fixed!');
      console.log('\n   User Data:');
      console.log('   - ID:', regularLogin.data.user.id);
      console.log('   - Email:', regularLogin.data.user.email);
      console.log('   - Username:', regularLogin.data.user.username);
      console.log('   - Name:', regularLogin.data.user.firstName, regularLogin.data.user.lastName);
      console.log('   - Echo Score:', regularLogin.data.user.echoScore);
      console.log('   - Total XP:', regularLogin.data.user.totalXpEarned);
      console.log('   - Current Streak:', regularLogin.data.user.currentStreak);
      console.log('\n   ✅ You can now use the app normally!');
    } else if (regularLogin.status === 500) {
      console.log('   ❌ Login still failing with 500 error');
      console.log('   The transformation fixes may not be deployed yet.');
      console.log('   Error:', regularLogin.data);
    } else {
      console.log('   ❌ Unexpected error:', regularLogin.status);
      console.log('   Response:', regularLogin.data);
    }
  } catch (error) {
    console.log('   ❌ Network error:', error.message);
  }
  
  console.log('\n================================');
  console.log('📋 Next Steps:');
  console.log('1. If deployment is not live, wait 5-10 minutes');
  console.log('2. Run this script again to check status');
  console.log('3. Once login works here, try the iOS app');
  console.log('================================\n');
}

// For testing alternative accounts
async function testAlternativeAccount() {
  console.log('\n🧪 Testing with a fresh account...');
  const timestamp = Date.now();
  const testUser = {
    email: `james.test${timestamp}@example.com`,
    username: `jamestest${timestamp}`,
    password: `VerySecure@${timestamp}#Complex!`,
    firstName: 'James',
    lastName: 'Test'
  };
  
  try {
    // Try registration
    const regResponse = await axios.post(
      `${API_URL}/auth/register`,
      testUser,
      { validateStatus: () => true }
    );
    
    console.log('Registration Status:', regResponse.status);
    if (regResponse.status === 201) {
      console.log('✅ Fresh account registration WORKS!');
      console.log('The issue is only with existing accounts.');
    } else {
      console.log('Response:', regResponse.data);
    }
  } catch (error) {
    console.log('Error:', error.message);
  }
}

// Run the checks
checkUserStatus()
  .then(() => {
    // Optionally test with a fresh account
    // return testAlternativeAccount();
  })
  .catch(console.error);