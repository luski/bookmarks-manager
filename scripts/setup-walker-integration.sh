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

# Check if project is built
if [ ! -f "$PROJECT_ROOT/dist/cli/bookmarks-cli.js" ]; then
    echo -e "${YELLOW}Project not built. Running build...${NC}"
    cd "$PROJECT_ROOT"
    npm run build
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
sed -i "s|HOME .. \"/projects/private/bookmarks|HOME .. \"$PROJECT_ROOT|g" "$ELEPHANT_MENUS_DIR/bookmarks.lua"
echo -e "  ✓ Updated paths to: $PROJECT_ROOT"

# Walker configuration
WALKER_CONFIG="$HOME/.config/walker/config.toml"
WALKER_CONFIG_DIR="$HOME/.config/walker"

mkdir -p "$WALKER_CONFIG_DIR"

# Backup existing config if it exists
if [ -f "$WALKER_CONFIG" ]; then
    cp "$WALKER_CONFIG" "$WALKER_CONFIG.backup.$(date +%s)"
    echo -e "${GREEN}Configuring Walker...${NC}"
    echo -e "  ✓ Backed up existing Walker config"
fi

# Check if bookmarks is already configured
if [ -f "$WALKER_CONFIG" ] && grep -q 'menus:bookmarks' "$WALKER_CONFIG"; then
    echo -e "  ${YELLOW}⚠${NC}  Bookmarks already configured in Walker"
else
    # Check if Walker config exists and has providers section
    if [ -f "$WALKER_CONFIG" ]; then
        # Existing config - only add what's needed
        echo -e "${GREEN}Configuring Walker...${NC}"

        # Add to default providers if section exists
        if grep -q '^default = \[' "$WALKER_CONFIG"; then
            # Add bookmarks to the default array
            sed -i '/^default = \[/,/^\]/ {
                /^\]/ i\  "menus:bookmarks",
            }' "$WALKER_CONFIG"
            echo -e "  ✓ Added bookmarks to existing Walker default providers"
        elif grep -q '^\[providers\]' "$WALKER_CONFIG"; then
            # Has [providers] but no default array - add it after [providers]
            sed -i '/^\[providers\]/a default = [\n  "menus:bookmarks",\n]' "$WALKER_CONFIG"
            echo -e "  ✓ Added default providers array with bookmarks"
        else
            # No providers section at all - append it
            cat >> "$WALKER_CONFIG" << 'EOF'

[providers]
default = [
  "menus:bookmarks",
]
EOF
            echo -e "  ✓ Added providers section with bookmarks"
        fi

        # Add prefix configuration if not already there
        if ! grep -q 'provider = "menus:bookmarks"' "$WALKER_CONFIG"; then
            cat >> "$WALKER_CONFIG" << 'EOF'

[[providers.prefixes]]
prefix = "!"
provider = "menus:bookmarks"
EOF
            echo -e "  ✓ Added bookmark prefix (!) to Walker"
        fi
    else
        # No config file exists - create minimal one with just bookmarks
        echo -e "${YELLOW}Walker config not found. Creating minimal config...${NC}"
        cat > "$WALKER_CONFIG" << 'EOF'
[providers]
default = [
  "menus:bookmarks",
]

[[providers.prefixes]]
prefix = "!"
provider = "menus:bookmarks"
EOF
        echo -e "  ✓ Created Walker configuration with bookmarks"
    fi
fi

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
echo "  5. Select 'Add New Bookmark' to add from clipboard"
echo ""
echo "CLI Usage:"
echo "  npm run add          - Add bookmark interactively"
echo "  npm run delete       - Delete bookmark interactively"
echo "  npm run bookmarks    - Manage bookmarks via CLI"
echo ""
echo "Troubleshooting:"
echo "  - Check Elephant is running: pgrep elephant"
echo "  - Restart Elephant: killall elephant && elephant &"
echo "  - Test CLI: npm run bookmarks list"
echo ""
