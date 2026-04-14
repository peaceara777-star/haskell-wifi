#!/bin/bash
# WiFi Diagnostic Tool - Test Script
# Usage: bash scripts/test.sh

set -e

echo "🧪 Running WiFi Diagnostic Tool Tests"
echo "======================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Run unit tests
echo -e "\n📋 Running unit tests..."
if stack test; then
    echo -e "${GREEN}✓${NC} Unit tests passed"
else
    echo -e "${RED}✗${NC} Unit tests failed"
    exit 1
fi

# Run HLint
echo -e "\n🔍 Running HLint..."
if command -v hlint &> /dev/null; then
    hlint src app test --hint=.hlint.yaml || echo -e "${YELLOW}⚠${NC} HLint found suggestions"
else
    echo -e "${YELLOW}⚠${NC} HLint not installed. Install with: stack install hlint"
fi

echo -e "\n${GREEN}✅ All tests completed!${NC}"
