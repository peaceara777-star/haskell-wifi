#!/bin/bash
# WiFi Diagnostic Tool - Installation Script
# Usage: bash scripts/install.sh

set -e

echo "📡 WiFi Diagnostic Tool Installer"
echo "=================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

OS=$(detect_os)
echo -e "${GREEN}✓${NC} Detected OS: $OS"

# Check for Stack
if ! command -v stack &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} Stack not found. Installing Stack..."
    case $OS in
        linux)
            curl -sSL https://get.haskellstack.org/ | sh
            ;;
        macos)
            brew install haskell-stack
            ;;
        windows)
            echo "Please install Stack manually from: https://docs.haskellstack.org/en/stable/README/"
            exit 1
            ;;
    esac
else
    echo -e "${GREEN}✓${NC} Stack is installed: $(stack --version)"
fi

# Check system dependencies
case $OS in
    linux)
        echo "Checking Linux dependencies..."
        if ! command -v nmcli &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} NetworkManager not found. Please install:"
            echo "  Ubuntu/Debian: sudo apt install network-manager"
            echo "  Fedora: sudo dnf install NetworkManager"
            echo "  Arch: sudo pacman -S networkmanager"
        else
            echo -e "${GREEN}✓${NC} NetworkManager is installed"
        fi
        ;;
    windows)
        echo "Checking Windows dependencies..."
        netsh wlan show interfaces > /dev/null 2>&1 || echo -e "${YELLOW}⚠${NC} Ensure WiFi adapter is enabled"
        ;;
esac

# Build project
echo ""
echo "Building project..."
stack build

# Install binary
echo ""
echo "Installing binary..."
stack install

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Run 'wifi-diagnostic' to start the tool."
echo "Run 'wifi-diagnostic --help' for usage information."
