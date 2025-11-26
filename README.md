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

Walker is a launcher for Wayland (Hyprland) that can be extended with custom modules.
Integration will be implemented to allow:
- Searching bookmarks through Walker
- Quick access to bookmarks via launcher
- Adding new bookmarks from clipboard

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
- 🚧 Walker launcher integration (next step)

## Database Schema

**bookmarks** table:
- `id`: Primary key
- `title`: Bookmark title
- `url`: URL (unique)
- `description`: Optional description
- `tags`: Space or comma-separated tags
- `created_at`: Timestamp
- `updated_at`: Timestamp
