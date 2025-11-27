# Bookmarks Manager

[![CI](https://github.com/luski/bookmarks-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/luski/bookmarks-manager/actions/workflows/ci.yml)

A bookmarks management system for Arch Linux with Hyprland integration using Walker launcher.

## Stack

- **Backend**: Node.js 22.5+ with TypeScript
- **Database**: SQLite3 (native `node:sqlite` module)
- **Frontend**: Walker launcher integration

## Quick Start (Fully Automatic)

Run the initialization script to set up everything automatically:

```bash
./initialize.sh
```

Or using npm:

```bash
npm run init
```

This will automatically:
- ✓ Install Node.js dependencies
- ✓ Initialize the SQLite database
- ✓ Build the project
- ✓ Install Elephant menu configuration (with correct paths)
- ✓ Configure Walker to include bookmarks
- ✓ Restart Elephant

**That's it!** The bookmarks manager is now fully integrated with Walker.

## Manual Setup

If you prefer to set up manually, see [INSTALL.md](INSTALL.md) for detailed instructions.

## Development

Run in development mode:
```bash
npm run dev
```

## Walker Integration

Walker integration is complete! See [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md) for detailed usage instructions.

**Usage:**
1. Open Walker (your configured keybind, usually `Super+Space`)
2. Type `!` to search bookmarks exclusively, or just search normally to see bookmarks in results
3. Press Enter on a bookmark to open it in your browser
4. Select "Add New Bookmark" to add URLs from your clipboard

The integration uses Elephant's Lua menu system to dynamically query the bookmark database and display results in Walker.

**Prefix:** `!` - Type exclamation mark in Walker to show only bookmarks

## Project Structure

```
.
├── src/
│   ├── db/
│   │   ├── database.ts      # Database connection and initialization
│   │   └── migrate.ts       # Migration script
│   ├── models/
│   │   └── bookmark.ts      # Bookmark model and operations
│   └── index.ts             # Main entry point
├── bookmarks.db             # SQLite database (auto-created)
├── package.json
└── tsconfig.json
```

## Features

- ✅ SQLite database for bookmark storage (native Node.js SQLite - no dependencies!)
- ✅ TypeScript backend with type safety
- ✅ CRUD operations for bookmarks
- ✅ Full-text search across title, URL, description, and tags
- ✅ Walker launcher integration via Elephant menus
- ✅ Command-line interface for bookmark management
- ✅ Browser URL opening with xdg-open
- ✅ Quick-add from clipboard
- ✅ Favicon support for visual identification

## Database Schema

**bookmarks** table:
- `id`: Primary key
- `title`: Bookmark title
- `url`: URL (unique)
- `description`: Optional description
- `tags`: Space or comma-separated tags
- `created_at`: Timestamp
- `updated_at`: Timestamp
