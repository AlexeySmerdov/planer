const admin = require('firebase-admin');
const { GoogleAuth } = require('google-auth-library');

// Initialize Firebase Admin SDK
const serviceAccount = require('./service-account-key.json'); // You'll need to download this
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'planner-fe828'
});

async function checkIndexStatus() {
  try {
    console.log('🔍 Checking Firestore index status...\n');
    
    // Method 1: Using Firebase Admin SDK to list indexes
    const auth = new GoogleAuth({
      keyFile: './service-account-key.json',
      scopes: ['https://www.googleapis.com/auth/cloud-platform']
    });
    
    const authClient = await auth.getClient();
    const projectId = 'planner-fe828';
    
    // Get access token
    const accessToken = await authClient.getAccessToken();
    
    // Make API call to list indexes
    const response = await fetch(
      `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/collectionGroups/-/indexes`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken.token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    
    if (data.indexes && data.indexes.length > 0) {
      console.log('📊 Index Status Report:');
      console.log('=' .repeat(50));
      
      data.indexes.forEach((index, i) => {
        console.log(`\n${i + 1}. Index: ${index.name}`);
        console.log(`   Collection: ${index.collectionGroup || 'N/A'}`);
        console.log(`   State: ${index.state || 'UNKNOWN'}`);
        
        // Decode state
        const stateEmoji = {
          'CREATING': '🔄',
          'READY': '✅',
          'NEEDS_REPAIR': '⚠️',
          'ERROR': '❌'
        };
        
        const stateDescription = {
          'CREATING': 'Index is being built',
          'READY': 'Index is ready for use',
          'NEEDS_REPAIR': 'Index needs repair',
          'ERROR': 'Index creation failed'
        };
        
        console.log(`   Status: ${stateEmoji[index.state] || '❓'} ${stateDescription[index.state] || 'Unknown state'}`);
        
        if (index.fields) {
          console.log(`   Fields:`);
          index.fields.forEach(field => {
            console.log(`     - ${field.fieldPath}: ${field.order || field.arrayConfig || 'N/A'}`);
          });
        }
      });
    } else {
      console.log('📝 No indexes found or all indexes are ready.');
    }
    
    console.log('\n' + '=' .repeat(50));
    console.log('✨ Index status check completed!');
    
  } catch (error) {
    console.error('❌ Error checking index status:', error.message);
    console.log('\n💡 Troubleshooting tips:');
    console.log('1. Make sure you have downloaded your service account key');
    console.log('2. Ensure you have the correct permissions');
    console.log('3. Check your internet connection');
  }
}

// Method 2: Simple function to check if indexes are building
async function areIndexesBuilding() {
  try {
    const auth = new GoogleAuth({
      keyFile: './service-account-key.json',
      scopes: ['https://www.googleapis.com/auth/cloud-platform']
    });
    
    const authClient = await auth.getClient();
    const accessToken = await authClient.getAccessToken();
    
    const response = await fetch(
      `https://firestore.googleapis.com/v1/projects/planner-fe828/databases/(default)/collectionGroups/-/indexes`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken.token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const data = await response.json();
    
    if (data.indexes) {
      const buildingIndexes = data.indexes.filter(index => index.state === 'CREATING');
      return {
        isBuilding: buildingIndexes.length > 0,
        buildingCount: buildingIndexes.length,
        totalCount: data.indexes.length,
        buildingIndexes: buildingIndexes
      };
    }
    
    return { isBuilding: false, buildingCount: 0, totalCount: 0, buildingIndexes: [] };
  } catch (error) {
    console.error('Error checking if indexes are building:', error);
    return null;
  }
}

// Method 3: Continuous monitoring
async function monitorIndexes(intervalSeconds = 30) {
  console.log(`🔄 Starting continuous index monitoring (checking every ${intervalSeconds} seconds)...`);
  console.log('Press Ctrl+C to stop monitoring\n');
  
  const checkInterval = setInterval(async () => {
    const status = await areIndexesBuilding();
    
    if (status) {
      const timestamp = new Date().toLocaleTimeString();
      
      if (status.isBuilding) {
        console.log(`[${timestamp}] 🔄 ${status.buildingCount}/${status.totalCount} indexes are still building...`);
      } else {
        console.log(`[${timestamp}] ✅ All ${status.totalCount} indexes are ready!`);
        clearInterval(checkInterval);
        console.log('🎉 Monitoring completed - all indexes are ready!');
      }
    } else {
      console.log(`[${new Date().toLocaleTimeString()}] ❌ Failed to check index status`);
    }
  }, intervalSeconds * 1000);
  
  // Handle Ctrl+C
  process.on('SIGINT', () => {
    clearInterval(checkInterval);
    console.log('\n👋 Monitoring stopped by user');
    process.exit(0);
  });
}

// Export functions for use in other scripts
module.exports = {
  checkIndexStatus,
  areIndexesBuilding,
  monitorIndexes
};

// If run directly, execute the main function
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.includes('--monitor')) {
    const interval = parseInt(args[args.indexOf('--monitor') + 1]) || 30;
    monitorIndexes(interval);
  } else {
    checkIndexStatus();
  }
} 