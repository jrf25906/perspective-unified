# Testing Scripts

This directory contains testing and validation scripts for the Perspective backend API.

## Scripts Available

### Authentication Testing
- **`test-auth-comprehensive.js`** - Comprehensive authentication flow testing
- **`test-auth-endpoints.js`** - Individual endpoint testing  
- **`test-auth-curl.sh`** - cURL-based authentication testing

### Database Testing
- **`test-db-connection.js`** - Database connectivity validation

## Usage

### Node.js Scripts
```bash
# Run from the backend directory
cd ../backend
node ../testing/test-auth-comprehensive.js
node ../testing/test-auth-endpoints.js
node ../testing/test-db-connection.js
```

### Shell Scripts
```bash
# Make executable and run
chmod +x testing/test-auth-curl.sh
./testing/test-auth-curl.sh
```

## Prerequisites

- Backend server running on port 3000
- Database properly migrated
- Valid test user credentials

## Notes

These scripts were migrated from the root directory during project consolidation. They test the backend API endpoints and authentication flows to ensure proper functionality.