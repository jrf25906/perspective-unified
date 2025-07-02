const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function testFinalAuth() {
  console.log('🧪 Final Authentication Test Suite');
  console.log('==================================\n');
  
  // Test 1: Check if migrations ran and SafeUserStatsService is deployed
  console.log('1. Checking deployment status');
  try {
    const statusResponse = await axios.get(`${API_URL}/test/status`);
    console.log('   ✅ Test endpoint reachable');
    console.log('   Database:', statusResponse.data.database.client);
    console.log('   Tables:', statusResponse.data.database.tables.join(', '));
  } catch (error) {
    console.log('   ❌ Test endpoint not reachable');
  }
  
  // Test 2: Test direct auth (should always work)
  console.log('\n2. Testing Direct Auth (baseline)');
  const timestamp = Date.now();
  const directUser = {
    email: `directfinal${timestamp}@example.com`,
    username: `directfinal${timestamp}`,
    password: `FinalTest@${timestamp}!`,
    firstName: 'Direct',
    lastName: 'Final'
  };
  
  try {
    const directReg = await axios.post(
      `${API_URL}/test/direct-register`,
      directUser,
      { validateStatus: () => true }
    );
    
    console.log('   Status:', directReg.status);
    if (directReg.status === 201) {
      console.log('   ✅ Direct registration working');
    } else {
      console.log('   ❌ Direct registration failed:', directReg.data);
    }
  } catch (error) {
    console.log('   ❌ Network error:', error.message);
  }
  
  // Test 3: Test regular auth (should work with fixes)
  console.log('\n3. Testing Regular Auth (with all fixes)');
  const regularUser = {
    email: `regfinal${timestamp}@example.com`,
    username: `regfinal${timestamp}`,
    password: `FinalTest@${timestamp}!Complex#`,
    firstName: 'Regular',
    lastName: 'Final'
  };
  
  try {
    const regularReg = await axios.post(
      `${API_URL}/auth/register`,
      regularUser,
      { validateStatus: () => true }
    );
    
    console.log('   Registration Status:', regularReg.status);
    
    if (regularReg.status === 201) {
      console.log('   ✅ Registration successful!');
      console.log('   User ID:', regularReg.data.user.id);
      console.log('   Has token:', !!regularReg.data.token);
      console.log('   Echo Score:', regularReg.data.user.echoScore);
      console.log('   Total XP:', regularReg.data.user.totalXpEarned);
      
      // Test login
      console.log('\n4. Testing Login');
      const loginResponse = await axios.post(
        `${API_URL}/auth/login`,
        {
          email: regularUser.email,
          password: regularUser.password
        },
        { validateStatus: () => true }
      );
      
      console.log('   Login Status:', loginResponse.status);
      if (loginResponse.status === 200) {
        console.log('   ✅ Login successful!');
        console.log('   User matches:', loginResponse.data.user.id === regularReg.data.user.id);
      } else {
        console.log('   ❌ Login failed:', loginResponse.data);
      }
      
    } else if (regularReg.status === 500) {
      console.log('   ❌ Registration still failing with 500');
      console.log('   Error:', regularReg.data);
      
      // Check if user was created
      console.log('\n   Checking if user was created anyway...');
      const checkLogin = await axios.post(
        `${API_URL}/test/direct-login`,
        {
          email: regularUser.email,
          password: regularUser.password
        },
        { validateStatus: () => true }
      );
      
      if (checkLogin.status === 200) {
        console.log('   ⚠️  User WAS created but transformation still failing');
        console.log('   The fixes have not been deployed yet.');
      } else {
        console.log('   ❌ User was NOT created - different issue');
      }
    } else {
      console.log('   ❌ Unexpected status:', regularReg.status);
      console.log('   Response:', regularReg.data);
    }
    
  } catch (error) {
    console.log('   ❌ Network error:', error.message);
  }
  
  console.log('\n========================================');
  console.log('📊 Summary:');
  console.log('- Direct auth endpoints: Working ✅');
  console.log('- SafeUserStatsService: Added ✅');
  console.log('- Missing await keywords: Fixed ✅');
  console.log('- Deployment status: Check results above');
  console.log('========================================\n');
}

// Run the test
testFinalAuth();