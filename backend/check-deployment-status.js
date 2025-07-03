const axios = require('axios');

async function checkDeploymentStatus() {
  try {
    const health = await axios.get('https://backend-production-d218.up.railway.app/health');
    const uptime = health.data.uptime;
    const minutes = Math.floor(uptime / 60);
    const seconds = Math.floor(uptime % 60);
    
    console.log(`Current deployment uptime: ${minutes}m ${seconds}s`);
    
    if (uptime < 300) { // Less than 5 minutes
      console.log('✅ New deployment is running!');
      
      // Test auth
      const timestamp = Date.now();
      const testResponse = await axios.post(
        'https://backend-production-d218.up.railway.app/api/v1/auth/register',
        {
          email: `deploytest${timestamp}@test.com`,
          username: `deploytest${timestamp}`,
          password: `Deploy${timestamp}!@#`,
          firstName: 'Deploy',
          lastName: 'Test'
        },
        { validateStatus: () => true }
      );
      
      if (testResponse.status === 201) {
        console.log('🎉 AUTH IS FIXED! Registration works!');
        console.log('\nYou can now login with:');
        console.log('Email: jrf7ta2@virginia.edu');
        console.log('Password: SuperSecure$2025#Pass!');
      } else {
        console.log('❌ Auth still failing:', testResponse.status);
      }
    } else {
      console.log('⏳ Old deployment still running. New deployment not active yet.');
      console.log('Check Railway dashboard for build status.');
    }
  } catch (error) {
    console.error('Error checking status:', error.message);
  }
}

// Check every 30 seconds
async function monitor() {
  console.log('Monitoring deployment status...\n');
  
  while (true) {
    await checkDeploymentStatus();
    console.log('---');
    await new Promise(resolve => setTimeout(resolve, 30000));
  }
}

// Run once or monitor
if (process.argv.includes('--monitor')) {
  monitor();
} else {
  checkDeploymentStatus();
}