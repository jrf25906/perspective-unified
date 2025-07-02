#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
BASE_URL="http://localhost:3000"
RANDOM_HEX=$(openssl rand -hex 4)
TEST_EMAIL="test_${RANDOM_HEX}@example.com"
TEST_USERNAME="testuser${RANDOM_HEX}"
TEST_PASSWORD="SecureP@ss${RANDOM_HEX}2024!"

echo -e "${BOLD}${GREEN}🚀 Starting Authentication Endpoint Tests${NC}"
echo -e "${CYAN}Server: ${BASE_URL}${NC}"
echo -e "${CYAN}Test Email: ${TEST_EMAIL}${NC}"
echo -e "${CYAN}Test Username: ${TEST_USERNAME}${NC}"
echo -e "${CYAN}Test Password: ${TEST_PASSWORD}${NC}"
echo -e "${YELLOW}==================================================${NC}"

# Wait for rate limit to reset
echo -e "\n${YELLOW}⏳ Waiting for rate limit to reset (40 seconds)...${NC}"
sleep 40

# Test 1: Register new user
echo -e "\n${BOLD}${YELLOW}=== TESTING USER REGISTRATION ===${NC}"
echo -e "${CYAN}Attempting to register user: ${TEST_EMAIL}${NC}"

REGISTER_RESPONSE=$(curl -X POST "${BASE_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"username\": \"${TEST_USERNAME}\",
    \"password\": \"${TEST_PASSWORD}\"
  }" \
  -s -w "\n\nHTTP_STATUS_CODE:%{http_code}")

HTTP_STATUS=$(echo "$REGISTER_RESPONSE" | grep -o "HTTP_STATUS_CODE:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo "$REGISTER_RESPONSE" | sed '/HTTP_STATUS_CODE:/d')

echo -e "${BOLD}${BLUE}REGISTRATION RESPONSE:${NC}"
echo -e "${GREEN}Status: ${HTTP_STATUS}${NC}"
echo -e "${CYAN}Response Body:${NC}"
echo "$RESPONSE_BODY" | jq . 2>/dev/null || echo "$RESPONSE_BODY"

# Extract token if available
TOKEN=$(echo "$RESPONSE_BODY" | jq -r '.token // empty' 2>/dev/null)
if [ -n "$TOKEN" ]; then
    echo -e "\n${GREEN}✅ Token received from registration${NC}"
fi

# Wait to avoid rate limiting
echo -e "\n${YELLOW}⏳ Waiting 3 seconds to avoid rate limiting...${NC}"
sleep 3

# Test 2: Login
echo -e "\n${BOLD}${YELLOW}=== TESTING USER LOGIN ===${NC}"
echo -e "${CYAN}Attempting to login with: ${TEST_EMAIL}${NC}"

LOGIN_RESPONSE=$(curl -X POST "${BASE_URL}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${TEST_EMAIL}\",
    \"password\": \"${TEST_PASSWORD}\"
  }" \
  -s -w "\n\nHTTP_STATUS_CODE:%{http_code}")

HTTP_STATUS=$(echo "$LOGIN_RESPONSE" | grep -o "HTTP_STATUS_CODE:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo "$LOGIN_RESPONSE" | sed '/HTTP_STATUS_CODE:/d')

echo -e "${BOLD}${BLUE}LOGIN RESPONSE:${NC}"
echo -e "${GREEN}Status: ${HTTP_STATUS}${NC}"
echo -e "${CYAN}Response Body:${NC}"
echo "$RESPONSE_BODY" | jq . 2>/dev/null || echo "$RESPONSE_BODY"

# Extract token from login if not already available
if [ -z "$TOKEN" ]; then
    TOKEN=$(echo "$RESPONSE_BODY" | jq -r '.token // empty' 2>/dev/null)
    if [ -n "$TOKEN" ]; then
        echo -e "\n${GREEN}✅ Token received from login${NC}"
    fi
fi

if [ -z "$TOKEN" ]; then
    echo -e "\n${RED}❌ No token received from registration or login${NC}"
    exit 1
fi

# Wait to avoid rate limiting
echo -e "\n${YELLOW}⏳ Waiting 3 seconds to avoid rate limiting...${NC}"
sleep 3

# Test 3: Get user profile with token
echo -e "\n${BOLD}${YELLOW}=== TESTING GET USER PROFILE ===${NC}"
echo -e "${CYAN}Using token: ${TOKEN}${NC}"

PROFILE_RESPONSE=$(curl -X GET "${BASE_URL}/api/auth/profile" \
  -H "Authorization: Bearer ${TOKEN}" \
  -s -w "\n\nHTTP_STATUS_CODE:%{http_code}")

HTTP_STATUS=$(echo "$PROFILE_RESPONSE" | grep -o "HTTP_STATUS_CODE:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo "$PROFILE_RESPONSE" | sed '/HTTP_STATUS_CODE:/d')

echo -e "${BOLD}${BLUE}GET PROFILE RESPONSE:${NC}"
echo -e "${GREEN}Status: ${HTTP_STATUS}${NC}"
echo -e "${CYAN}Response Body:${NC}"
echo "$RESPONSE_BODY" | jq . 2>/dev/null || echo "$RESPONSE_BODY"

# Test 4: Try to get profile without token (should fail)
echo -e "\n${BOLD}${YELLOW}=== TESTING GET PROFILE WITHOUT TOKEN ===${NC}"

UNAUTH_RESPONSE=$(curl -X GET "${BASE_URL}/api/auth/profile" \
  -s -w "\n\nHTTP_STATUS_CODE:%{http_code}")

HTTP_STATUS=$(echo "$UNAUTH_RESPONSE" | grep -o "HTTP_STATUS_CODE:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo "$UNAUTH_RESPONSE" | sed '/HTTP_STATUS_CODE:/d')

echo -e "${BOLD}${BLUE}GET PROFILE UNAUTHORIZED RESPONSE:${NC}"
echo -e "${GREEN}Status: ${HTTP_STATUS}${NC}"
echo -e "${CYAN}Response Body:${NC}"
echo "$RESPONSE_BODY" | jq . 2>/dev/null || echo "$RESPONSE_BODY"

if [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ Expected 401 Unauthorized received${NC}"
else
    echo -e "${RED}❌ Unexpected status code: ${HTTP_STATUS}${NC}"
fi

echo -e "\n${BOLD}${GREEN}✨ All tests completed!${NC}"