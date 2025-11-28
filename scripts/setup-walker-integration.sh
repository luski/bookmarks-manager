#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$PROJECT_ROOT/config"

echo -e "${GREEN}=== Bookmarks Manager - Walker Integration Setup ===${NC}\n"

# Check if npm dependencies are installed (needed for Walker config merge)
if [ ! -d "$PROJECT_ROOT/node_modules" ]; then
    echo -e "${YELLOW}Installing npm dependencies for setup...${NC}"
    cd "$PROJECT_ROOT"
    npm install
    echo ""
fi

# Check if Elephant is installed
if ! command -v elephant &> /dev/null; then
    echo -e "${RED}Error: Elephant is not installed.${NC}"
    echo "Please install elephant first: https://github.com/abenz1267/elephant"
    exit 1
fi

# Check if Walker is installed
if ! command -v walker &> /dev/null; then
    echo -e "${RED}Error: Walker is not installed.${NC}"
    echo "Please install walker first: https://github.com/abenz1267/walker"
    exit 1
fi

# Check for required tools
echo -e "${GREEN}Checking system dependencies...${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed.${NC}"
    echo "Please install curl: sudo pacman -S curl"
    exit 1
fi
echo -e "  ✓ curl found"



# Create Elephant menus directory if it doesn't exist
ELEPHANT_MENUS_DIR="$HOME/.config/elephant/menus"
if [ ! -d "$ELEPHANT_MENUS_DIR" ]; then
    echo -e "${YELLOW}Creating Elephant menus directory...${NC}"
    mkdir -p "$ELEPHANT_MENUS_DIR"
fi

# Copy bookmarks.lua to Elephant menus
echo -e "${GREEN}Installing Elephant bookmarks menu...${NC}"
cp "$CONFIG_DIR/bookmarks.lua" "$ELEPHANT_MENUS_DIR/bookmarks.lua"
echo -e "  ✓ Copied to $ELEPHANT_MENUS_DIR/bookmarks.lua"

# Update paths in the Lua file to use current project location
# Convert absolute path to relative from HOME
RELATIVE_PATH="${PROJECT_ROOT/#$HOME/}"
sed -i "s|HOME .. \"{{PROJECT_PATH}}\"|HOME .. \"$RELATIVE_PATH\"|g" "$ELEPHANT_MENUS_DIR/bookmarks.lua"
echo -e "  ✓ Updated paths to: ~$RELATIVE_PATH"

# Create bookmarks.toml if it doesn't exist
BOOKMARKS_FILE="$PROJECT_ROOT/bookmarks.toml"
if [ ! -f "$BOOKMARKS_FILE" ]; then
    echo -e "${YELLOW}Creating empty bookmarks file...${NC}"
    touch "$BOOKMARKS_FILE"
    echo -e "  ✓ Created $BOOKMARKS_FILE"
else
    echo -e "  ✓ Bookmarks file already exists"
fi

# Create favicons directory if it doesn't exist
FAVICON_DIR="$PROJECT_ROOT/favicons"
if [ ! -d "$FAVICON_DIR" ]; then
    echo -e "${YELLOW}Creating favicons directory...${NC}"
    mkdir -p "$FAVICON_DIR"
    echo -e "  ✓ Created $FAVICON_DIR"
else
    echo -e "  ✓ Favicons directory already exists"
fi

# Walker configuration
WALKER_CONFIG_DIR="$HOME/.config/walker"
mkdir -p "$WALKER_CONFIG_DIR"

echo -e "${GREEN}Configuring Walker...${NC}"
node "$SCRIPT_DIR/merge-walker-config.mjs"

# Restart Elephant if it's running
if pgrep -x elephant > /dev/null; then
    echo -e "${GREEN}Restarting Elephant...${NC}"
    killall elephant
    sleep 1
    elephant &> /dev/null &
    echo -e "  ✓ Elephant restarted"
else
    echo -e "${YELLOW}Elephant is not running. Starting it...${NC}"
    elephant &> /dev/null &
    echo -e "  ✓ Elephant started"
fi

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Usage:"
echo "  1. Open Walker (your configured keybind)"
echo "  2. Type '!' to search bookmarks exclusively"
echo "  3. Or just type to search across all providers (bookmarks included)"
echo "  4. Press Enter on a bookmark to open it"
echo "  5. Press Ctrl+X on a bookmark to delete it"
echo "  6. Select 'Add New Bookmark' to add a new bookmark"
echo ""
echo "Bookmarks are stored in: $BOOKMARKS_FILE"
echo ""
echo "Troubleshooting:"
echo "  - Check Elephant is running: pgrep elephant"
echo "  - Restart Elephant: killall elephant && elephant &"
echo "  - View bookmarks: cat $BOOKMARKS_FILE"
echo ""
