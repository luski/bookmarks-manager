# Installation Guide

Quick start guide for setting up the Bookmarks Manager with Walker launcher integration.

## Prerequisites

### Required
- **Arch Linux** with Hyprland (or similar Wayland compositor)
- **Walker** - Application launcher ([GitHub](https://github.com/abenz1267/walker))
- **Elephant** - Menu provider for Walker ([GitHub](https://github.com/abenz1267/elephant))
- **Node.js** (v18 or later) - JavaScript runtime
- **npm** - Package manager (comes with Node.js)

### Optional
- **wl-clipboard** - For clipboard support on Wayland
- **libnotify** - For desktop notifications

### Install Dependencies

```bash
# Install Walker and Elephant (AUR)
yay -S walker-bin elephant-bin

# Or build from source
# See their respective GitHub repositories

# Install optional dependencies
sudo pacman -S wl-clipboard libnotify
```

## Installation Steps

### Option 1: Automatic Installation (Recommended)

Simply run the initialization script:

```bash
git clone https://github.com/luski/bookmarks-manager.git
cd bookmarks-manager
./initialize.sh
```

Or using npm:

```bash
npm run init
```

This single command will automatically:
- ✓ Install Node.js dependencies
- ✓ Initialize the SQLite database
- ✓ Build the project
- ✓ Install Elephant menu configuration (with correct paths)
- ✓ Configure Walker to include bookmarks
- ✓ Restart Elephant

**That's it! Skip to the [Verification](#verification) section.**

### Option 2: Manual Installation

If you prefer manual setup or the automatic script doesn't work for your setup:

#### 1. Clone the Repository

```bash
git clone https://github.com/luski/bookmarks-manager.git
cd bookmarks-manager
```

#### 2. Install Node Dependencies

```bash
npm install
```

#### 3. Initialize Database

```bash
npm run db:migrate
```

This creates the SQLite database and sets up the schema.

#### 4. Build the Project

```bash
npm run build
```

This compiles TypeScript to JavaScript and makes CLI scripts executable.

#### 5. Configure Walker (Manual)

If you skipped the automated setup or it couldn't auto-configure Walker:

Edit `~/.config/walker/config.toml` and add:

```toml
[providers]
default = [
  "desktopapplications",
  "menus:bookmarks",  # Add this line
  "websearch",
]

# Add this section
[[providers.prefixes]]
prefix = "!"
provider = "menus:bookmarks"
```

### 7. Start Elephant

If not already running:

```bash
elephant &
```

## Verification

### Test the Installation

1. **Test CLI:**
   ```bash
   npm run bookmarks list
   ```
   Should show an empty list or any sample bookmarks.

2. **Test Walker Integration:**
   - Open Walker (usually `Super+Space` or your configured keybind)
   - Type `!` to filter to bookmarks only
   - You should see "Add New Bookmark" entry

3. **Add a Test Bookmark:**
   ```bash
   npm run bookmarks add "https://archlinux.org" "Arch Linux" "The best Linux distro"
   ```

4. **Verify in Walker:**
   - Open Walker
   - Type `!` or just start typing "arch"
   - Your bookmark should appear
   - Press Enter to open it in your browser

## Usage

### From Walker (Primary Interface)

1. **Open Walker** (your configured keybind)
2. **Search bookmarks:**
   - Type `!` for exclusive bookmark search
   - Or just type to search all providers (bookmarks included)
3. **Open bookmark:** Press `Enter`
4. **Add bookmark:** Select "Add New Bookmark" (copy URL to clipboard first)

### From Command Line

```bash
# Interactive add
npm run add

# Interactive delete
npm run delete

# List all bookmarks
npm run bookmarks list

# Search bookmarks
npm run bookmarks search "query"

# Add bookmark with CLI
npm run bookmarks add "URL" "Title" "Description" "tags"

# Delete by ID
npm run bookmarks delete 1
```

## Troubleshooting

### Bookmarks Don't Show in Walker

1. Check Elephant is running:
   ```bash
   pgrep elephant
   ```

2. Restart Elephant:
   ```bash
   killall elephant && elephant &
   ```

3. Verify menu file exists:
   ```bash
   ls ~/.config/elephant/menus/bookmarks.lua
   ```

4. Test CLI directly:
   ```bash
   npm run bookmarks list
   ```

### Can't Open URLs

Check and set default browser:

```bash
# Check current default
xdg-settings get default-web-browser

# Set default (example with Firefox)
xdg-settings set default-web-browser firefox.desktop
```

### Node.js Not Found

If using fnm or another version manager, ensure Node is in your PATH:

```bash
# For fnm users
eval "$(fnm env)"
```

Or update the path in `~/.config/elephant/menus/bookmarks.lua`.

### Database Errors

Reset the database:

```bash
rm bookmarks.db
npm run db:migrate
```

### Permission Errors

Make sure scripts are executable:

```bash
chmod +x scripts/setup-walker-integration.sh
npm run build  # This also sets executable permissions
```

## Uninstallation

To remove the integration:

```bash
# Remove Elephant menu
rm ~/.config/elephant/menus/bookmarks.lua

# Restart Elephant
killall elephant && elephant &

# Remove from Walker config
# Edit ~/.config/walker/config.toml and remove:
# - "menus:bookmarks" from default providers
# - The [[providers.prefixes]] section for bookmarks

# Remove project directory
cd ..
rm -rf bookmarks-manager
```

## Next Steps

- See [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md) for detailed usage
- See [config/README.md](config/README.md) for customization options
- See [README.md](README.md) for project overview and features

## Getting Help

- Check the [GitHub Issues](https://github.com/luski/bookmarks-manager/issues)
- Review [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md) for usage tips
- Check Walker/Elephant documentation for launcher-specific issues