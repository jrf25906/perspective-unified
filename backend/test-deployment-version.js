const axios = require('axios');

async function checkDeploymentVersion() {
  console.log('Checking what code is actually deployed...\n');
  
  try {
    // Test 1: Check health endpoint for version
    const health = await axios.get('https://backend-production-d218.up.railway.app/health');
    console.log('Health check version:', health.data.version);
    console.log('Uptime:', Math.floor(health.data.uptime / 60), 'minutes');
    
    // Test 2: Try registration to see specific error
    const timestamp = Date.now();
    const regResponse = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      {
        email: `versiontest${timestamp}@test.com`,
        username: `versiontest${timestamp}`,
        password: `VersionTest${timestamp}!@#$`,
        firstName: 'Version',
        lastName: 'Test'
      },
      { 
        validateStatus: () => true,
        timeout: 10000
      }
    );
    
    console.log('\nRegistration test:');
    console.log('Status:', regResponse.status);
    
    if (regResponse.status === 500) {
      console.log('Error message:', regResponse.data?.error?.message);
      
      // Check the error details if available
      if (regResponse.data?.error?.details) {
        console.log('Error details:', regResponse.data.error.details);
      }
      
      // These are the errors we've fixed:
      console.log('\nChecking for specific fixed issues:');
      
      if (regResponse.data?.error?.message?.includes('expiresIn')) {
        console.log('❌ JWT exp duplicate error - OLD CODE RUNNING');
      } else if (regResponse.data?.error?.message?.includes('extractDeviceInfo')) {
        console.log('❌ Static method binding error - OLD CODE RUNNING');
      } else {
        console.log('✓ Neither known error present');
      }
    } else if (regResponse.status === 201) {
      console.log('✅ REGISTRATION SUCCESSFUL! New code is deployed!');
      console.log('User:', regResponse.data.user?.email);
    } else if (regResponse.status === 400) {
      console.log('Validation error:', regResponse.data?.error?.message);
      if (regResponse.data?.error?.validationErrors) {
        console.log('Details:', JSON.stringify(regResponse.data.error.validationErrors, null, 2));
      }
    }
    
    // Test 3: Check if test endpoint exists (only in newer code)
    console.log('\nChecking for test endpoints...');
    const testResponse = await axios.get(
      'https://backend-production-d218.up.railway.app/api/v1/auth/test',
      { validateStatus: () => true }
    );
    
    if (testResponse.status === 200) {
      console.log('✓ Test endpoint exists');
    } else {
      console.log('✗ Test endpoint not found (status:', testResponse.status + ')');
    }
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

checkDeploymentVersion();