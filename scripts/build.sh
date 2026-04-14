#!/bin/bash
# WiFi Diagnostic Tool - Build Script
# Usage: bash scripts/build.sh [--release]

set -e

RELEASE=false
if [[ "$1" == "--release" ]]; then
    RELEASE=true
fi

echo "🔨 Building WiFi Diagnostic Tool"
echo "================================="

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Clean if release build
if [[ "$RELEASE" == true ]]; then
    echo "Cleaning previous builds..."
    stack clean
fi

# Build project
echo "Building with Stack..."
if [[ "$RELEASE" == true ]]; then
    stack build --flag haskell-wifi-diagnostic:release
else
    stack build
fi

# Copy binary to output directory
echo "Copying binary..."
mkdir -p bin
cp "$(stack path --local-install-root)/bin/wifi-diagnostic" bin/ 2>/dev/null || true

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "Binary location: $(stack path --local-install-root)/bin/wifi-diagnostic"
