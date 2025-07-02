const axios = require('axios');

const testDbConnection = async () => {
  console.log('Testing database connection via API...\n');

  try {
    // Test health endpoint
    const healthResponse = await axios.get('https://backend-production-d218.up.railway.app/health');
    console.log('✅ Health check passed:', healthResponse.data);
    
    // Test diagnostic endpoint
    const diagResponse = await axios.get('https://backend-production-d218.up.railway.app/api/v1/network-diagnostic/status');
    console.log('\n✅ Diagnostic status:', JSON.stringify(diagResponse.data, null, 2));
    
  } catch (error) {
    console.error('❌ Test failed!');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.error('Error:', error.message);
    }
  }
};

testDbConnection();