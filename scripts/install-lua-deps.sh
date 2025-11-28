#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Installing Lua Dependencies ===${NC}\n"

# Check if luarocks is installed
if ! command -v luarocks &> /dev/null; then
    echo -e "${RED}Error: luarocks is not installed.${NC}"
    echo "Please install luarocks first:"
    echo "  - Arch Linux: sudo pacman -S luarocks"
    echo "  - Ubuntu/Debian: sudo apt-get install luarocks"
    echo "  - Fedora: sudo dnf install luarocks"
    exit 1
fi

echo -e "${GREEN}Installing lsqlite3...${NC}"

# Install lsqlite3 locally for the current user
if luarocks install --local lsqlite3 2>&1 | grep -q "is now installed"; then
    echo -e "  ✓ lsqlite3 installed successfully"
elif lua -e "require('lsqlite3')" 2>/dev/null; then
    echo -e "  ✓ lsqlite3 already installed"
else
    echo -e "${RED}  ✗ Failed to install lsqlite3${NC}"
    exit 1
fi

# Add luarocks path setup instructions
echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "To use the Lua dependencies, you need to set up your Lua path."
echo "Add the following to your shell RC file (~/.bashrc, ~/.zshrc, etc.):"
echo ""
echo -e "${YELLOW}eval \$(luarocks path --lua-version 5.4)${NC}"
echo ""
echo "Or run it in your current shell session:"
echo -e "${YELLOW}source <(luarocks path --lua-version 5.4)${NC}"
echo ""
