# Configuration Files

This directory contains configuration templates for integrating the Bookmarks Manager with Walker launcher and Elephant menus.

## Quick Start

**Use the automatic initialization script instead of manual setup:**

```bash
./initialize.sh
```

This will automatically install and configure everything. See the sections below only if you need to customize or troubleshoot.

## Files

### `bookmarks.lua` (Template)
Elephant menu configuration template that provides the bookmarks interface in Walker.

**Note:** This is a template file with `{{PROJECT_PATH}}` placeholder. The initialization script automatically replaces this with your actual project path and installs it to `~/.config/elephant/menus/bookmarks.lua`.

**Features:**
- Dynamic bookmark listing from SQLite database
- Favicon support for visual identification
- Search filtering as you type
- Browser opening via `xdg-open`
- Quick-add from clipboard
- Delete action for bookmarks

**Location:** Should be installed to `~/.config/elephant/menus/bookmarks.lua`

### `walker-config.toml`
Walker configuration snippet showing how to integrate bookmarks into your Walker setup.

**Key settings:**
- Adds `menus:bookmarks` to default providers (shows in normal search)
- Maps `!` prefix for exclusive bookmark search

**Location:** Merge into your `~/.config/walker/config.toml`

## Installation

### Automatic Setup (Recommended)

Run the initialization script from the project root:

```bash
./initialize.sh
```

Or using npm:

```bash
npm run init
```

This will:
1. ✓ Check if Walker and Elephant are installed
2. ✓ Install Node.js dependencies
3. ✓ Initialize the database
4. ✓ Build the project
5. ✓ Process template and install `bookmarks.lua` to Elephant menus directory
6. ✓ Automatically configure Walker (modifies your config.toml)
7. ✓ Restart Elephant to load the menu

**This is fully automatic and requires no manual configuration!**

### Manual Setup

#### 1. Install Elephant Menu

```bash
mkdir -p ~/.config/elephant/menus
cp config/bookmarks.lua ~/.config/elephant/menus/bookmarks.lua
```

Edit the file and update the project path if your bookmarks project is not in `~/projects/private/bookmarks`.

#### 2. Configure Walker

Edit `~/.config/walker/config.toml`:

**Add to default providers:**
```toml
[providers]
default = [
  "desktopapplications",
  "menus:bookmarks",  # Add this line
  "websearch",
]
```

**Add prefix for exclusive bookmark search:**
```toml
[[providers.prefixes]]
prefix = "!"
provider = "menus:bookmarks"
```

#### 3. Restart Elephant

```bash
killall elephant
elephant &
```

## Customization

### Change the Bookmark Prefix

Edit `~/.config/walker/config.toml`:

```toml
[[providers.prefixes]]
prefix = "b"  # Change "!" to any prefix you prefer
provider = "menus:bookmarks"
```

### Modify Menu Behavior

Edit `~/.config/elephant/menus/bookmarks.lua` to:
- Change icons (see [freedesktop.org icon naming spec](https://specifications.freedesktop.org/icon-naming-spec/icon-naming-spec-latest.html))
- Customize display format
- Add more actions
- Change default browser behavior

### Use Different Node Version

The `bookmarks.lua` file automatically detects Node.js in your PATH and has smart fallbacks:
1. First tries `which node` (system Node or version manager in PATH)
2. Falls back to latest fnm version automatically
3. Final fallback to `/usr/bin/node`

If you use a version manager, ensure Node is in your PATH when running the initialization script.

## Troubleshooting

### Bookmarks don't show in Walker

1. Check Elephant is running:
   ```bash
   pgrep elephant
   ```

2. Verify menu file exists:
   ```bash
   ls ~/.config/elephant/menus/bookmarks.lua
   ```

3. Restart Elephant:
   ```bash
   killall elephant && elephant &
   ```

4. Test CLI directly:
   ```bash
   npm run bookmarks list
   ```

### Can't open URLs

Check your default browser:
```bash
xdg-settings get default-web-browser
```

Set if needed:
```bash
xdg-settings set default-web-browser firefox.desktop
```

### Node.js not found

The Lua script tries to find Node.js using `which node`. If you use fnm or another version manager:

1. Ensure Node is in your PATH, or
2. Update the fallback path in `bookmarks.lua`:
   ```lua
   node_path = os.getenv("HOME") .. "/.local/share/fnm/node-versions/vX.X.X/installation/bin/node"
   ```

### Add Bookmark doesn't work

1. Ensure `wl-paste` is installed (for Wayland clipboard):
   ```bash
   sudo pacman -S wl-clipboard
   ```

2. Copy a URL before selecting "Add New Bookmark"

3. Check notifications for error messages

## Dependencies

### Required
- **Walker** - Application launcher ([GitHub](https://github.com/abenz1267/walker))
- **Elephant** - Menu provider for Walker ([GitHub](https://github.com/abenz1267/elephant))
- **Node.js** - Runtime for the bookmarks CLI
- **xdg-utils** - For opening URLs in default browser

### Optional
- **wl-clipboard** - For clipboard support on Wayland (quick-add bookmarks)
- **libnotify** - For desktop notifications

## Project Structure

```
bookmarks/
├── config/
│   ├── README.md              # This file
│   ├── bookmarks.lua          # Elephant menu configuration
│   └── walker-config.toml     # Walker configuration snippet
├── scripts/
│   └── setup-walker-integration.sh  # Automatic setup script
└── dist/
    └── cli/
        ├── bookmarks-cli.js   # CLI tool used by Elephant
        ├── add-interactive.js # Interactive add script
        └── delete-interactive.js  # Interactive delete script
```

## Scripts Comparison

### `initialize.sh` (Recommended)
- **Location:** Project root
- **Purpose:** Complete automatic setup
- **What it does:** Everything - dependencies, database, build, config installation, Walker modification
- **User interaction:** None (fully automatic)
- **Use when:** First time setup or fresh installation

### `scripts/setup-walker-integration.sh` (Advanced)
- **Location:** `scripts/` directory
- **Purpose:** Only handles Walker/Elephant configuration
- **What it does:** Installs configs and guides Walker setup (assumes project is built)
- **User interaction:** May require manual Walker config editing
- **Use when:** Reinstalling just the Walker integration after project is already set up

**For most users, just use `./initialize.sh` and ignore the other script.**

## Related Documentation

- [INSTALL.md](../INSTALL.md) - Complete installation guide
- [WALKER_INTEGRATION.md](../WALKER_INTEGRATION.md) - Full integration guide
- [IMPLEMENTATION.md](../IMPLEMENTATION.md) - Implementation details
- [README.md](../README.md) - Main project documentation