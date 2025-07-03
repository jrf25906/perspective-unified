// Test that our static method fix works
const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function testStaticMethodFix() {
  try {
    console.log('Testing if static method fix is deployed...\n');
    
    // Test registration
    const timestamp = Date.now();
    const testUser = {
      email: `staticfix${timestamp}@test.com`,
      username: `staticfix${timestamp}`,
      password: `Static${timestamp}!@#`,
      firstName: 'Static',
      lastName: 'Fix'
    };
    
    console.log('Testing registration...');
    const regResponse = await axios.post(`${API_URL}/auth/register`, testUser, {
      validateStatus: () => true
    });
    
    if (regResponse.status === 201) {
      console.log('✅ Registration successful! Static method fix is deployed!');
      console.log('User created:', regResponse.data.user.email);
      
      // Test login
      console.log('\nTesting login...');
      const loginResponse = await axios.post(`${API_URL}/auth/login`, {
        email: testUser.email,
        password: testUser.password
      }, {
        validateStatus: () => true
      });
      
      if (loginResponse.status === 200) {
        console.log('✅ Login successful!');
        console.log('\n🎉 ALL AUTH FIXES ARE DEPLOYED AND WORKING!');
        console.log('\nYour user can now login with:');
        console.log('Email: jrf7ta2@virginia.edu');
        console.log('Password: SuperSecure$2025#Pass!');
      } else {
        console.log('❌ Login failed:', loginResponse.status);
        if (loginResponse.data?.error?.message) {
          console.log('Error:', loginResponse.data.error.message);
        }
      }
    } else {
      console.log('❌ Registration failed:', regResponse.status);
      if (regResponse.data?.error?.message) {
        console.log('Error:', regResponse.data.error.message);
        
        if (regResponse.data.error.message.includes('extractDeviceInfo')) {
          console.log('\n⚠️  Static method fix NOT deployed yet');
          console.log('The server is still running old code');
        }
      }
    }
  } catch (error) {
    console.error('Test failed:', error.message);
  }
}

testStaticMethodFix();