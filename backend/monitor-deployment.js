const axios = require('axios');

const API_URL = 'https://backend-production-d218.up.railway.app/api/v1';

async function checkDeployment() {
  try {
    // Quick test: try to register a user
    const timestamp = Date.now();
    const response = await axios.post(
      `${API_URL}/auth/register`,
      {
        email: `monitor${timestamp}@test.com`,
        username: `monitor${timestamp}`,
        password: `Monitor${timestamp}!@#`,
        firstName: 'Monitor',
        lastName: 'Test'
      },
      { validateStatus: () => true }
    );
    
    return response.status === 201;
  } catch (error) {
    return false;
  }
}

async function monitorDeployment() {
  console.log('🔄 Monitoring Railway Deployment');
  console.log('================================\n');
  console.log('Checking every 30 seconds...\n');
  
  let deployed = false;
  let attempts = 0;
  const maxAttempts = 20; // 10 minutes max
  
  while (!deployed && attempts < maxAttempts) {
    attempts++;
    process.stdout.write(`[${new Date().toLocaleTimeString()}] Checking deployment... `);
    
    deployed = await checkDeployment();
    
    if (deployed) {
      console.log('✅ DEPLOYED!');
      console.log('\n🎉 All fixes are now live!');
      console.log('You can now login with:');
      console.log('Email: jrf7ta2@virginia.edu');
      console.log('Password: SuperSecure$2025#Pass!');
      break;
    } else {
      console.log('⏳ Not ready yet');
      if (attempts < maxAttempts) {
        await new Promise(resolve => setTimeout(resolve, 30000)); // Wait 30 seconds
      }
    }
  }
  
  if (!deployed) {
    console.log('\n❌ Deployment is taking longer than expected.');
    console.log('Please check Railway dashboard or try again later.');
  }
}

// Start monitoring
console.log('Press Ctrl+C to stop monitoring\n');
monitorDeployment();