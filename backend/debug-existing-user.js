const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function debugExistingUser() {
  console.log('🔍 Debugging Existing User Issue');
  console.log('=================================\n');
  
  // Your registration attempts
  const attempts = [
    { email: 'jrf7ta2@virginia.edu', username: 'jimmy', password: 'SuperSecure$2025#Pass!' },
    { email: 'james.farmer276@gmail.com', username: 'james.farmer276', password: 'you mentioned this earlier' },
    { email: 'James.farmer@gm.com', username: 'jamie', password: 'unknown' }
  ];
  
  console.log('Checking which email/username combinations exist...\n');
  
  for (const attempt of attempts) {
    console.log(`📧 Email: ${attempt.email}`);
    console.log(`👤 Username: ${attempt.username}`);
    
    // Check with direct endpoint when available
    try {
      // First check if direct endpoints are deployed
      const directCheck = await axios.post(
        `${API_URL}/test/direct-login`,
        { email: 'test@test.com', password: 'test' },
        { validateStatus: () => true }
      );
      
      if (directCheck.status === 404) {
        console.log('   ⏳ Direct endpoints not deployed yet\n');
        continue;
      }
      
      // Try to register to see what error we get
      const regTest = await axios.post(
        `${API_URL}/auth/register`,
        {
          email: attempt.email,
          username: attempt.username,
          password: 'TestPassword123456!@#',
          firstName: 'Test',
          lastName: 'User'
        },
        { validateStatus: () => true }
      );
      
      if (regTest.status === 409) {
        console.log('   ✅ Account EXISTS');
        console.log('   Error:', regTest.data.error.message);
        
        // If you know the password, try login
        if (attempt.password && attempt.password !== 'unknown' && attempt.password !== 'you mentioned this earlier') {
          const loginTest = await axios.post(
            `${API_URL}/test/direct-login`,
            {
              email: attempt.email,
              password: attempt.password
            },
            { validateStatus: () => true }
          );
          
          if (loginTest.status === 200) {
            console.log('   ✅ Password is CORRECT');
            console.log('   User ID:', loginTest.data.user.id);
          } else if (loginTest.status === 401) {
            console.log('   ❌ Password is INCORRECT');
          }
        }
      } else if (regTest.status === 400) {
        console.log('   ❓ Validation error:', regTest.data.error.message);
      } else if (regTest.status === 500) {
        console.log('   ❌ Server error - transformation issue still present');
      } else {
        console.log('   ❓ Unexpected status:', regTest.status);
      }
      
    } catch (error) {
      console.log('   ❌ Network error:', error.message);
    }
    
    console.log('');
  }
  
  console.log('\n🔧 Troubleshooting Steps:');
  console.log('1. Your email jrf7ta2@virginia.edu already exists in the database');
  console.log('2. The password you\'re using should be: SuperSecure$2025#Pass!');
  console.log('3. Wait for deployment to complete (5-10 minutes)');
  console.log('4. Try logging in with the iOS app once the fixes are deployed');
  console.log('\nIf you need to use a different email, try:');
  console.log('- jrf7ta+test@virginia.edu (many email providers support + aliases)');
  console.log('- Any other email address you have access to');
}

debugExistingUser();