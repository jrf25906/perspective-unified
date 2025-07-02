const bcrypt = require('bcryptjs');

async function testBcrypt() {
  const password = 'FuckU!90';
  
  console.log('Testing bcrypt with password:', password);
  
  // Generate hash
  const hash = await bcrypt.hash(password, 10);
  console.log('Generated hash:', hash);
  console.log('Hash length:', hash.length);
  
  // Test comparison
  const isValid = await bcrypt.compare(password, hash);
  console.log('Comparison result:', isValid);
  
  // Test with a known hash from the database (if we had one)
  // This would help verify if the issue is with hash generation or comparison
}

testBcrypt();