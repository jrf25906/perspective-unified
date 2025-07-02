const axios = require('axios');

const testSimpleRegistration = async () => {
  const timestamp = Date.now();
  
  // Test 1: Simple registration without first_name/last_name
  const simpleData = {
    email: `simple${timestamp}@example.com`,
    username: `simple${timestamp}`,
    password: "SimplePass123!"
  };

  console.log('Test 1: Simple registration without names');
  console.log('Data:', simpleData);

  try {
    const response = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      simpleData,
      {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      }
    );
    
    console.log('✅ Success!');
    console.log('Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('❌ Failed!');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
    }
  }

  // Test 2: Full registration with names
  const fullData = {
    email: `full${timestamp}@example.com`,
    username: `full${timestamp}`,
    password: "FullPass123!",
    firstName: "Test",
    lastName: "User"
  };

  console.log('\nTest 2: Full registration with names');
  console.log('Data:', fullData);

  try {
    const response = await axios.post(
      'https://backend-production-d218.up.railway.app/api/v1/auth/register',
      fullData,
      {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      }
    );
    
    console.log('✅ Success!');
    console.log('Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('❌ Failed!');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
    }
  }
};

testSimpleRegistration();