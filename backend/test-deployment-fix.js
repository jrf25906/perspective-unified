#!/usr/bin/env node

const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function testDeploymentFix() {
  console.log('🔍 Testing Railway deployment fix...');
  console.log(`📡 API URL: ${API_URL}`);
  
  try {
    // Test health endpoint first
    console.log('\n1️⃣ Testing health endpoint...');
    const healthRes = await axios.get(`${API_URL.replace('/api/v1', '')}/health`);
    console.log('✅ Health check:', healthRes.data);
    
    // Test registration with new code
    console.log('\n2️⃣ Testing registration with fixed code...');
    const timestamp = Date.now();
    const testUser = {
      email: `fixtest${timestamp}@test.com`,
      username: `fixtest${timestamp}`,
      password: `Deploy${timestamp}#Fix!`,
      first_name: 'Fix',
      last_name: 'Test'
    };
    
    console.log('📤 Sending registration request...');
    const registerRes = await axios.post(`${API_URL}/auth/register`, testUser);
    console.log('✅ Registration successful!');
    console.log('📥 Response:', JSON.stringify(registerRes.data, null, 2));
    
    // Test login
    console.log('\n3️⃣ Testing login with new user...');
    const loginRes = await axios.post(`${API_URL}/auth/login`, {
      email: testUser.email,
      password: testUser.password
    });
    console.log('✅ Login successful!');
    console.log('🎫 Token received:', loginRes.data.data.token ? 'Yes' : 'No');
    console.log('👤 User data:', JSON.stringify(loginRes.data.data.user, null, 2));
    
    console.log('\n🎉 Deployment fix verified! The extractDeviceInfo error is resolved.');
    
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    if (error.response) {
      console.error('📋 Response status:', error.response.status);
      console.error('📋 Response data:', JSON.stringify(error.response.data, null, 2));
    }
    process.exit(1);
  }
}

testDeploymentFix();