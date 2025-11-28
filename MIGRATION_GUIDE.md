# Migration Guide: Node.js to Pure Lua

This guide helps you migrate from the Node.js/TypeScript version to the pure Lua implementation.

## Why Migrate?

The Lua-only implementation offers several advantages:

- **Simpler**: One language (Lua) instead of two (TypeScript + Lua)
- **Faster**: ~20x faster (5ms vs 100ms per operation)
- **No build step**: No TypeScript compilation required
- **Fewer dependencies**: No npm packages, just Lua rocks
- **Smaller footprint**: No Node.js runtime overhead

## What's Changed

### Architecture

**Before (3 layers):**
```
SQLite ← Node.js/TypeScript ← Elephant (Lua) ← Walker
```

**After (2 layers):**
```
SQLite ← Elephant (Lua) ← Walker
```

### Dependencies

**Removed:**
- Node.js 22.5+
- TypeScript
- npm packages (@types/node, tsx, etc.)
- All `src/` TypeScript code

**Added:**
- Lua 5.4+
- luarocks
- lsqlite3 (Lua SQLite bindings)
- curl (for favicon downloads)

**Unchanged:**
- Elephant
- Walker
- SQLite database
- rofi/dmenu

### File Structure

**Removed:**
- `src/` directory (all TypeScript code)
- `dist/` directory (compiled JavaScript)
- `node_modules/`
- `package.json`, `package-lock.json`
- `tsconfig.json`

**Added:**
- `scripts/install-lua-deps.sh`
- `scripts/elephant-wrapper.sh`
- `scripts/test-lua-bookmarks.lua`
- `LUA_IMPLEMENTATION.md`
- `MIGRATION_GUIDE.md` (this file)

**Modified:**
- `config/bookmarks.lua` (complete rewrite with SQLite integration)
- `scripts/setup-walker-integration.sh` (updated for Lua)
- `README.md` (updated documentation)

## Migration Steps

### 1. Backup Your Data (Optional)

Your existing `bookmarks.db` will work with the new version, but if you want to be safe:

```bash
cp bookmarks.db bookmarks.db.backup
cp -r favicons favicons.backup
```

### 2. Install Lua Dependencies

Install system packages:

```bash
# Arch Linux
sudo pacman -S lua luarocks curl

# Ubuntu/Debian
sudo apt-get install lua5.4 luarocks curl

# Fedora
sudo dnf install lua luarocks curl
```

Install Lua rocks:

```bash
./scripts/install-lua-deps.sh
```

### 3. Set Up Lua Path

Add to your `~/.bashrc`, `~/.zshrc`, or equivalent:

```bash
eval $(luarocks path --lua-version 5.4)
```

Then reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### 4. Run Setup Script

```bash
./scripts/setup-walker-integration.sh
```

This will:
- Install the new Lua-based `bookmarks.lua` to Elephant
- Update your Walker configuration
- Restart Elephant

### 5. Test the Migration

Run the test script:

```bash
lua scripts/test-lua-bookmarks.lua
```

Expected output:
```
=== Testing Lua Bookmarks ===

Test 1: Opening database...
✓ Database opened successfully

Test 2: Checking bookmarks table...
✓ Found X bookmarks in database

Test 3: Listing bookmarks...
  [1] Title - URL
  ...

=== All tests completed ===
```

### 6. Verify in Walker

1. Open Walker (your configured keybind)
2. Type `!` to see bookmarks
3. Verify all your existing bookmarks appear
4. Try opening a bookmark (press Enter)
5. Try deleting a bookmark (press Ctrl+X)
6. Try adding a new bookmark (select "Add New Bookmark")

### 7. Clean Up Old Node.js Files (Optional)

Once you've verified everything works, you can remove the old Node.js files:

```bash
# Remove Node.js dependencies
rm -rf node_modules package.json package-lock.json

# Remove TypeScript source
rm -rf src tsconfig.json

# Remove compiled JavaScript
rm -rf dist

# Remove old scripts
rm -f initialize.sh
```

**Note:** Keep these files if you want to maintain backward compatibility or switch back.

## Data Compatibility

### Database

✅ **100% Compatible**: The database schema is identical. Your existing `bookmarks.db` works without any changes.

```sql
-- Same schema in both versions
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  url TEXT NOT NULL UNIQUE,
  description TEXT,
  tags TEXT,
  favicon TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Favicons

✅ **100% Compatible**: The Lua version uses the same `favicons/` directory and filename format (`domain.png`).

## Feature Comparison

| Feature | Node.js Version | Lua Version |
|---------|----------------|-------------|
| Add bookmark | `npm run add` | Via Walker (rofi dialog) |
| Delete bookmark | `npm run delete` | Via Walker (Ctrl+X) |
| List bookmarks | `npm run bookmarks list` | Via Walker or SQLite CLI |
| Search bookmarks | Via Walker | Via Walker |
| Favicon download | Automatic | Automatic |
| CLI interface | Yes (`npm run bookmarks`) | No (use SQLite CLI) |
| Startup time | ~100ms | ~5ms |
| Build step | Yes (`npm run build`) | No |
| Type safety | Yes (TypeScript) | No (dynamic Lua) |

## What You Lose

### Command-Line Interface

The Node.js version had dedicated CLI commands:

```bash
npm run add          # Interactive add
npm run delete       # Interactive delete
npm run bookmarks    # Full CLI
```

**Lua alternative:**

Use Walker UI for everything, or use SQLite directly:

```bash
# Add bookmark
sqlite3 bookmarks.db "INSERT INTO bookmarks (title, url) VALUES ('Title', 'https://example.com');"

# Delete bookmark
sqlite3 bookmarks.db "DELETE FROM bookmarks WHERE id = 1;"

# List bookmarks
sqlite3 bookmarks.db "SELECT * FROM bookmarks;"
```

### TypeScript Type Safety

The Lua version is dynamically typed. If you rely heavily on TypeScript's type checking, this might be a downside.

**Mitigation:** The Lua implementation is simpler and more focused, reducing the chance of type-related bugs.

## What You Gain

### Performance

The Lua version is **~20x faster**:

- Node.js startup: ~100-200ms per operation
- Lua startup: ~5-10ms per operation

This makes Walker integration feel instantaneous.

### Simplicity

- No build step
- No transpilation
- No npm dependencies
- One configuration file (`config/bookmarks.lua`)
- Everything in one language

### Maintainability

- Easier to understand (all logic in one file)
- Easier to modify (no compilation)
- Easier to debug (no source maps)
- Easier to deploy (no node_modules)

## Troubleshooting

### "module 'lsqlite3' not found"

The Lua path isn't set correctly.

**Solution:**

```bash
eval $(luarocks path --lua-version 5.4)
```

Add to your shell RC file to make it permanent.

### "Database not initialized"

The database path in `bookmarks.lua` might be incorrect.

**Check:**

```bash
cat ~/.config/elephant/menus/bookmarks.lua | grep DB_PATH
```

Should show: `local DB_PATH = PROJECT_PATH .. "/bookmarks.db"`

### Bookmarks don't appear in Walker

**Debug steps:**

1. Check Elephant is running: `pgrep elephant`
2. Restart Elephant: `killall elephant && elephant &`
3. Check for errors: `journalctl -f | grep elephant`
4. Verify Lua file exists: `ls ~/.config/elephant/menus/bookmarks.lua`

### Favicons not showing

Ensure curl is installed and the favicons directory exists:

```bash
which curl
mkdir -p ~/projects/private/bookmarks/favicons
```

Test favicon download manually:

```bash
curl -sL "https://www.google.com/s2/favicons?domain=github.com&sz=64" \
  -o test-favicon.png
```

## Rollback Plan

If you need to go back to the Node.js version:

### Option 1: Git Checkout

```bash
# Assuming you're on feat/lua-only-refactor branch
git checkout main  # or your previous branch
npm install
npm run build
./scripts/setup-walker-integration.sh
```

### Option 2: Keep Both Versions

You can run both versions side-by-side:

```bash
# Clone to a different directory
git clone <repo-url> bookmarks-nodejs
cd bookmarks-nodejs
git checkout main  # the Node.js version

# Set up both
cd ~/projects/private/bookmarks  # Lua version
./scripts/setup-walker-integration.sh

cd ~/projects/private/bookmarks-nodejs  # Node.js version
npm install && npm run build
```

Configure Walker to use whichever Elephant menu you prefer.

## Getting Help

- **Lua implementation details**: See [LUA_IMPLEMENTATION.md](LUA_IMPLEMENTATION.md)
- **Walker integration**: See [WALKER_INTEGRATION.md](WALKER_INTEGRATION.md)
- **Installation**: See [INSTALL.md](INSTALL.md)
- **Issues**: Check [GitHub Issues](https://github.com/luski/bookmarks-manager/issues)

## Feedback

This migration represents a significant simplification of the project. If you encounter any issues or have suggestions, please open an issue on GitHub.

Happy bookmarking! 🔖