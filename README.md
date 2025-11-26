# Bookmarks Manager

A bookmarks management system for Arch Linux with Hyprland integration using Walker launcher.

## Stack

- **Backend**: Node.js + TypeScript
- **Database**: SQLite3 (better-sqlite3)
- **Frontend**: Walker launcher integration

## Setup

1. Install dependencies:
```bash
npm install
```

2. Initialize database:
```bash
npm run db:migrate
```

3. Build the project:
```bash
npm run build
```

4. Run in development:
```bash
npm run dev
```

## Walker Integration

Walker integration is complete! See [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md) for detailed usage instructions.

**Quick Start:**
1. Make sure `elephant` is running
2. Open Walker (your configured keybind)
3. Type `!` to search bookmarks exclusively, or just search normally to see bookmarks in results
4. Press Enter on a bookmark to open it in your browser
5. Select "Add New Bookmark" to add URLs from your clipboard

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

- ✅ SQLite database for bookmark storage
- ✅ TypeScript backend with type safety
- ✅ CRUD operations for bookmarks
- ✅ Full-text search across title, URL, description, and tags
- ✅ Walker launcher integration via Elephant menus
- ✅ Command-line interface for bookmark management
- ✅ Browser URL opening with xdg-open
- ✅ Quick-add from clipboard

## Database Schema

**bookmarks** table:
- `id`: Primary key
- `title`: Bookmark title
- `url`: URL (unique)
- `description`: Optional description
- `tags`: Space or comma-separated tags
- `created_at`: Timestamp
- `updated_at`: Timestamp
