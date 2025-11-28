# Bookmarks Manager

[![CI](https://github.com/luski/bookmarks-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/luski/bookmarks-manager/actions/workflows/ci.yml)

A bookmarks management system for Arch Linux with Hyprland integration using Walker launcher.

## Stack

- **Backend**: Pure Lua (no Node.js required!)
- **Database**: SQLite3 (via `lsqlite3`)
- **Frontend**: Walker launcher integration via Elephant menus

## Quick Start

### Prerequisites

- Lua 5.4+
- luarocks
- Elephant
- Walker
- curl (for favicon downloads)
- rofi or dmenu (for input dialogs)

### Installation

Run the setup script:

```bash
./scripts/setup-walker-integration.sh
```

This will automatically:
- ✓ Install Lua dependencies (lsqlite3)
- ✓ Initialize the SQLite database
- ✓ Install Elephant menu configuration
- ✓ Configure Walker to include bookmarks
- ✓ Restart Elephant

**That's it!** The bookmarks manager is now fully integrated with Walker.

For detailed information about the Lua implementation, see [LUA_IMPLEMENTATION.md](LUA_IMPLEMENTATION.md).

## Manual Setup

If you prefer to set up manually, see [INSTALL.md](INSTALL.md) for detailed instructions.

## Walker Integration

Walker integration is complete! See [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md) for detailed usage instructions.

**Usage:**
1. Open Walker (your configured keybind, usually `Super+Space`)
2. Type `!` to search bookmarks exclusively, or just search normally to see bookmarks in results
3. Press **Enter** on a bookmark to open it in your browser
4. Press **Ctrl+X** on a bookmark to delete it
5. Select "Add New Bookmark" to add a new bookmark interactively

The integration uses Elephant's Lua menu system with direct SQLite access - no Node.js backend required!

**Prefix:** `!` - Type exclamation mark in Walker to show only bookmarks

## Project Structure

```
.
├── config/
│   ├── bookmarks.lua          # Main Lua implementation (all logic here!)
│   └── walker-template.toml   # Walker configuration template
├── scripts/
│   ├── install-lua-deps.sh    # Installs lsqlite3
│   ├── setup-walker-integration.sh  # Main setup script
│   ├── merge-walker-config.mjs     # Merges Walker config
│   └── test-lua-bookmarks.lua      # Test script
├── favicons/                  # Downloaded favicons (auto-created)
└── bookmarks.db              # SQLite database (auto-created)
```

## Features

- ✅ Pure Lua implementation (no Node.js build step!)
- ✅ SQLite database for bookmark storage via lsqlite3
- ✅ CRUD operations for bookmarks
- ✅ Walker launcher integration via Elephant menus
- ✅ Interactive bookmark creation with rofi dialogs
- ✅ Browser URL opening with xdg-open
- ✅ Quick-add from clipboard
- ✅ Automatic favicon downloading and caching
- ✅ Delete bookmarks with Ctrl+X in Walker
- ✅ Fast and lightweight (no startup overhead)

## Database Schema

**bookmarks** table:
- `id`: Primary key
- `title`: Bookmark title
- `url`: URL (unique)
- `description`: Optional description
- `tags`: Comma-separated tags
- `favicon`: Path to cached favicon
- `created_at`: Timestamp
- `updated_at`: Timestamp

## Architecture

This project uses a simplified two-layer architecture:

```
SQLite Database ← Elephant (Lua) ← Walker
```

All bookmark logic is handled directly in `config/bookmarks.lua`, which:
- Manages the SQLite database via lsqlite3
- Downloads and caches favicons
- Provides interactive dialogs for adding bookmarks
- Returns formatted entries to Walker

For more details, see [LUA_IMPLEMENTATION.md](LUA_IMPLEMENTATION.md).
