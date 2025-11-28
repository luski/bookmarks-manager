# Bookmarks Manager

A bookmarks management system for Arch Linux with Hyprland integration using Walker launcher.

## Stack

- **Backend**: Pure Lua (no Node.js required!)
- **Storage**: TOML text files (human-readable, no database!)
- **Frontend**: Walker launcher integration via Elephant menus

## Quick Start

### Prerequisites

- Lua 5.4+ (for Elephant)
- Elephant
- Walker
- curl (for favicon downloads)
- rofi or dmenu (for input dialogs)
- Node.js + npm (only required once for initial setup to merge Walker config)

### Installation

Run the setup script:

```bash
./scripts/setup-walker-integration.sh
```

**Note:** Node.js + npm are only needed during this one-time setup to safely merge the Walker TOML configuration. The setup script will automatically install the required npm package (`@iarna/toml`). After setup, the bookmarks manager runs purely in Lua with no external dependencies.

This will automatically:
- ✓ Install npm dependencies for setup (if needed)
- ✓ Create empty bookmarks.toml file
- ✓ Install Elephant menu configuration
- ✓ Configure Walker to include bookmarks
- ✓ Restart Elephant

**That's it!** The bookmarks manager is now fully integrated with Walker.

## Walker Integration

Walker integration is complete! See [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md) for detailed usage instructions.

**Usage:**
1. Open Walker (your configured keybind, usually `Super+Space`)
2. Type `!` to search bookmarks exclusively, or just search normally to see bookmarks in results
3. Press **Enter** on a bookmark to open it in your browser
4. Press **Ctrl+X** on a bookmark to delete it
5. Select "Add New Bookmark" to add a new bookmark interactively

The integration uses Elephant's Lua menu system with simple TOML file storage - no database, no external dependencies!

**Prefix:** `!` - Type exclamation mark in Walker to show only bookmarks

## Project Structure

```
.
├── config/
│   ├── bookmarks.lua          # Main Lua implementation (all logic here!)
│   └── walker-template.toml   # Walker configuration template
├── scripts/
│   ├── setup-walker-integration.sh  # Main setup script
│   ├── merge-walker-config.mjs     # Merges Walker config
│   └── test-lua-bookmarks.lua      # Test script
├── favicons/                  # Downloaded favicons (auto-created)
├── bookmarks.toml            # Bookmarks storage (auto-created)
└── package.json              # npm deps for setup only
```

## Features

- ✅ Pure Lua implementation (no build step!)
- ✅ TOML file storage (human-readable, easy to backup)
- ✅ No database required
- ✅ No Lua dependencies (no luarocks needed)
- ✅ CRUD operations for bookmarks
- ✅ Walker launcher integration via Elephant menus
- ✅ Interactive bookmark creation with rofi dialogs
- ✅ Browser URL opening with xdg-open
- ✅ Quick-add from clipboard
- ✅ Automatic favicon downloading and caching
- ✅ Delete bookmarks with Ctrl+X in Walker
- ✅ Fast and lightweight (no startup overhead)
- ✅ Version control friendly (plain text storage)

## Bookmark Storage

Bookmarks are stored in `bookmarks.toml` with a simple structure:

```toml
[[bookmark]]
id = 1
title = "GitHub"
url = "https://github.com"
favicon = "/home/user/projects/bookmarks/favicons/github.com.png"

[[bookmark]]
id = 2
title = "Rust Lang"
url = "https://rust-lang.org"
favicon = "/home/user/projects/bookmarks/favicons/rust-lang.org.png"
```

You can manually edit this file if needed!

## Architecture

This project uses a simplified two-layer architecture:

```
TOML File ← Elephant (Lua) ← Walker
```

All bookmark logic is handled directly in `config/bookmarks.lua`, which:
- Reads/writes bookmarks from/to TOML file
- Downloads and caches favicons
- Provides interactive dialogs for adding bookmarks
- Returns formatted entries to Walker

No database, no C dependencies, no complex setup!

## Manual Backup

Since bookmarks are stored in a plain text TOML file, backing up is trivial:

```bash
cp bookmarks.toml bookmarks.backup.toml
```

Or add it to your dotfiles repository!

## Troubleshooting

### Elephant not finding bookmarks

Make sure Elephant is running:
```bash
pgrep elephant
```

Restart Elephant:
```bash
killall elephant && elephant &
```

### View your bookmarks

Simply open the file:
```bash
cat bookmarks.toml
```

Or edit manually:
```bash
nano bookmarks.toml
```

### Favicons not loading

Check that curl is installed:
```bash
which curl
```

Check favicon directory permissions:
```bash
ls -la favicons/
```
