#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the absolute path of the project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="$SCRIPT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}Bookmarks Manager - Automatic Initialization${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Walker is installed
if ! command -v walker &> /dev/null; then
    echo -e "${RED}✗ Error: Walker is not installed.${NC}"
    echo "  Please install walker first: https://github.com/abenz1267/walker"
    exit 1
fi

# Check if Elephant is installed
if ! command -v elephant &> /dev/null; then
    echo -e "${RED}✗ Error: Elephant is not installed.${NC}"
    echo "  Please install elephant first: https://github.com/abenz1267/elephant"
    exit 1
fi

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Error: Node.js is not installed.${NC}"
    echo "  Please install Node.js first (v18 or later)"
    exit 1
fi

echo -e "${GREEN}✓${NC} Walker found: $(walker --version 2>&1 | head -1 || echo 'version unknown')"
echo -e "${GREEN}✓${NC} Elephant found"
echo -e "${GREEN}✓${NC} Node.js found: $(node --version)"
echo ""

# Step 1: Install dependencies if needed
if [ ! -d "$PROJECT_PATH/node_modules" ]; then
    echo -e "${YELLOW}→${NC} Installing Node.js dependencies..."
    cd "$PROJECT_PATH"
    npm install
    echo -e "${GREEN}✓${NC} Dependencies installed"
    echo ""
else
    echo -e "${GREEN}✓${NC} Dependencies already installed"
    echo ""
fi

# Step 2: Initialize database if needed
if [ ! -f "$PROJECT_PATH/bookmarks.db" ]; then
    echo -e "${YELLOW}→${NC} Initializing database..."
    cd "$PROJECT_PATH"
    npm run db:migrate
    echo -e "${GREEN}✓${NC} Database initialized"
    echo ""
else
    echo -e "${GREEN}✓${NC} Database already exists"
    echo ""
fi

# Step 3: Build the project
echo -e "${YELLOW}→${NC} Building project..."
cd "$PROJECT_PATH"
npm run build
echo -e "${GREEN}✓${NC} Project built successfully"
echo ""

# Step 4: Install Elephant menu configuration
echo -e "${YELLOW}→${NC} Installing Elephant menu configuration..."

ELEPHANT_MENUS_DIR="$HOME/.config/elephant/menus"
mkdir -p "$ELEPHANT_MENUS_DIR"

# Create bookmarks.lua from template with actual project path
sed "s|{{PROJECT_PATH}}|$PROJECT_PATH|g" "$PROJECT_PATH/config/bookmarks.lua" > "$ELEPHANT_MENUS_DIR/bookmarks.lua"

echo -e "${GREEN}✓${NC} Elephant menu installed to: $ELEPHANT_MENUS_DIR/bookmarks.lua"
echo ""

# Step 5: Configure Walker
echo -e "${YELLOW}→${NC} Configuring Walker..."

WALKER_CONFIG="$HOME/.config/walker/config.toml"
WALKER_CONFIG_DIR="$HOME/.config/walker"

mkdir -p "$WALKER_CONFIG_DIR"

if [ ! -f "$WALKER_CONFIG" ]; then
    # Create new Walker config with bookmarks
    echo -e "${YELLOW}  Creating new Walker configuration...${NC}"
    cat > "$WALKER_CONFIG" << 'EOF'
[providers]
max_results = 256
default = [
  "desktopapplications",
  "menus:bookmarks",
  "websearch",
]

[[providers.prefixes]]
prefix = "/"
provider = "providerlist"

[[providers.prefixes]]
prefix = "."
provider = "files"

[[providers.prefixes]]
prefix = ":"
provider = "symbols"

[[providers.prefixes]]
prefix = "="
provider = "calc"

[[providers.prefixes]]
prefix = "$"
provider = "clipboard"

[[providers.prefixes]]
prefix = "!"
provider = "menus:bookmarks"
EOF
    echo -e "${GREEN}✓${NC} Walker configuration created"
else
    # Backup existing config
    cp "$WALKER_CONFIG" "$WALKER_CONFIG.backup.$(date +%s)"
    echo -e "${GREEN}✓${NC} Backed up existing Walker config"

    # Check if bookmarks is already configured
    if grep -q 'menus:bookmarks' "$WALKER_CONFIG"; then
        echo -e "${YELLOW}  ⚠${NC}  Bookmarks already configured in Walker"
    else
        # Add bookmarks to default providers if not already there
        if grep -q '^\[providers\]' "$WALKER_CONFIG" && grep -q '^default = \[' "$WALKER_CONFIG"; then
            # Add to existing default array if it doesn't already have bookmarks
            if ! grep -A 5 '^default = \[' "$WALKER_CONFIG" | grep -q 'menus:bookmarks'; then
                # Find the default array and add bookmarks before the closing bracket
                sed -i '/^default = \[/,/^\]/ {
                    /^\]/ i\  "menus:bookmarks",
                }' "$WALKER_CONFIG"
                echo -e "${GREEN}✓${NC} Added bookmarks to Walker default providers"
            fi
        else
            # Add providers section if it doesn't exist
            echo "" >> "$WALKER_CONFIG"
            cat >> "$WALKER_CONFIG" << 'EOF'

[providers]
max_results = 256
default = [
  "desktopapplications",
  "menus:bookmarks",
  "websearch",
]
EOF
            echo -e "${GREEN}✓${NC} Added providers section with bookmarks"
        fi

        # Add prefix configuration if not already there
        if ! grep -q 'provider = "menus:bookmarks"' "$WALKER_CONFIG"; then
            echo "" >> "$WALKER_CONFIG"
            cat >> "$WALKER_CONFIG" << 'EOF'

[[providers.prefixes]]
prefix = "!"
provider = "menus:bookmarks"
EOF
            echo -e "${GREEN}✓${NC} Added bookmark prefix (!) to Walker"
        fi
    fi
fi

echo ""

# Step 6: Restart Elephant
echo -e "${YELLOW}→${NC} Restarting Elephant..."

if pgrep -x elephant > /dev/null; then
    killall elephant 2>/dev/null || true
    sleep 1
fi

# Start Elephant in background
elephant &> /dev/null &
ELEPHANT_PID=$!

# Wait a moment for Elephant to start
sleep 2

if pgrep -x elephant > /dev/null; then
    echo -e "${GREEN}✓${NC} Elephant restarted successfully (PID: $ELEPHANT_PID)"
else
    echo -e "${YELLOW}  ⚠${NC}  Elephant may not have started. Try running: elephant &"
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}✓ Installation Complete!${NC}                              ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Project Path:${NC} $PROJECT_PATH"
echo ""
echo -e "${YELLOW}Usage:${NC}"
echo "  1. Open Walker (your configured keybind, usually Super+Space)"
echo "  2. Type ${BLUE}!${NC} to search bookmarks exclusively"
echo "  3. Or just type to search across all providers (bookmarks included)"
echo "  4. Press Enter on a bookmark to open it in your browser"
echo "  5. Select 'Add New Bookmark' to add from clipboard"
echo ""
echo -e "${YELLOW}CLI Commands:${NC}"
echo "  ${BLUE}npm run add${NC}          - Add bookmark interactively"
echo "  ${BLUE}npm run delete${NC}       - Delete bookmark interactively"
echo "  ${BLUE}npm run bookmarks list${NC} - List all bookmarks"
echo ""
echo -e "${YELLOW}Test the integration:${NC}"
echo "  ${BLUE}npm run bookmarks add \"https://archlinux.org\" \"Arch Linux\" \"The best distro\"${NC}"
echo ""
echo -e "${YELLOW}Files modified:${NC}"
echo "  • $ELEPHANT_MENUS_DIR/bookmarks.lua"
echo "  • $WALKER_CONFIG"
if [ -f "$WALKER_CONFIG.backup."* ]; then
    echo "  • Backup: $WALKER_CONFIG.backup.*"
fi
echo ""
echo -e "${GREEN}Happy bookmarking! 🔖${NC}"
echo ""
