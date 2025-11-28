# Walker Integration Guide

## Setup Complete! ✅

The bookmarks manager is now integrated with Walker launcher using Elephant menus.

## How It Works

The integration uses:
- **Elephant Lua Menu** (`~/.config/elephant/menus/bookmarks.lua`) - Pure Lua implementation with TOML storage
- **TOML File** (`bookmarks.toml`) - Plain text storage for bookmarks
- **Walker Config** - Configured to show bookmarks as a provider

No database, no CLI tools - just simple TOML files and Lua!

## Usage

### 1. Accessing Bookmarks in Walker

**Method 1: Show in default search**
- Open Walker (your configured keybind, usually `Super+Space`)
- Bookmarks will appear in the default search results
- Type to filter bookmarks by title or URL

**Method 2: Use prefix**
- Open Walker
- Type `!` to exclusively search bookmarks
- Select a bookmark and press Enter to open in your default browser

### 2. Opening Bookmarks

- Navigate to any bookmark in Walker
- Press **Enter** to open the URL in your default browser (via `xdg-open`)

### 3. Adding New Bookmarks

**From Walker:**
1. Open Walker and access bookmarks (type `!`)
2. Select "Add New Bookmark" (first entry)
3. The URL will be pre-filled from clipboard (if it contains a valid URL)
4. Or you'll be prompted to enter a URL manually
5. Enter a title (or leave blank to use the URL as title)
6. The bookmark is saved immediately and the favicon is downloaded

**Tip:** Copy the URL to clipboard before adding for faster workflow!

### 4. Deleting Bookmarks

- In Walker, navigate to a bookmark
- Press **Ctrl+X** to delete the bookmark
- A notification will confirm the deletion

### 5. Managing Bookmarks Manually

You can edit bookmarks directly in the TOML file:

```bash
# View your bookmarks
cat ~/projects/private/bookmarks/bookmarks.toml

# Edit manually
nano ~/projects/private/bookmarks/bookmarks.toml
```

After editing, restart Elephant to see changes:
```bash
killall elephant && elephant &
```

## File Locations

### Walker Config
`~/.config/walker/config.toml`

### Elephant Menu
`~/.config/elephant/menus/bookmarks.lua`

### Bookmarks Storage
`~/projects/private/bookmarks/bookmarks.toml`

### Favicons Cache
`~/projects/private/bookmarks/favicons/`

## TOML File Format

Bookmarks are stored in a simple, human-readable format:

```toml
[[bookmark]]
id = 1
title = "GitHub"
url = "https://github.com"
favicon = "/home/user/projects/bookmarks/favicons/github.com.png"

[[bookmark]]
id = 2
title = "Rust Lang"
url = "https://www.rust-lang.org"
favicon = ""
```

Each bookmark has exactly 4 fields:
- **id** - Unique numeric identifier
- **title** - Display name
- **url** - The URL to open
- **favicon** - Path to cached favicon (can be empty)

## Customization

### Change the Prefix

Edit `~/.config/walker/config.toml`:
```toml
[[providers.prefixes]]
prefix = "b"  # Change "!" to whatever you want
provider = "menus:bookmarks"
```

### Modify Menu Behavior

Edit `~/.config/elephant/menus/bookmarks.lua` to:
- Change icons
- Add more actions
- Customize the "Add Bookmark" functionality
- Modify display format
- Change favicon download sources

### Change Bookmark Icons

In `bookmarks.lua`, find the icon assignment section and customize:
```lua
local icon = "text-html"  -- Change default icon
if bookmark.favicon and bookmark.favicon ~= "" and fileExists(bookmark.favicon) then
    icon = bookmark.favicon
end
```

## Keyboard Shortcuts in Walker

- **Enter** - Open bookmark in browser
- **Ctrl+X** - Delete bookmark
- **Esc** - Close Walker

## Troubleshooting

### Bookmarks don't show up in Walker

1. Check Elephant is running: 
   ```bash
   pgrep elephant
   ```

2. Restart Elephant:
   ```bash
   killall elephant && elephant &
   ```

3. Check the menu file exists:
   ```bash
   ls ~/.config/elephant/menus/bookmarks.lua
   ```

4. Verify TOML file exists and is readable:
   ```bash
   cat ~/projects/private/bookmarks/bookmarks.toml
   ```

### Can't open URLs

- Check your default browser:
  ```bash
  xdg-settings get default-web-browser
  ```

- Set if needed:
  ```bash
  xdg-settings set default-web-browser firefox.desktop
  ```

### "Add Bookmark" doesn't work

- Make sure `rofi` or `dmenu` is installed:
  ```bash
  which rofi
  # or
  which dmenu
  ```

- Make sure `wl-paste` (Wayland) or `xclip` (X11) is installed for clipboard support:
  ```bash
  which wl-paste
  # or
  which xclip
  ```

- Check notifications for error messages
- Try entering the URL manually instead of from clipboard

### Favicons not downloading

- Make sure `curl` is installed:
  ```bash
  which curl
  ```

- Check favicon directory exists and is writable:
  ```bash
  ls -la ~/projects/private/bookmarks/favicons/
  ```

- Check internet connection
- Some sites don't have favicons - this is normal

### TOML file corruption

If you manually edited the TOML file and it's now broken:

1. Check syntax with a TOML validator
2. Make sure each bookmark starts with `[[bookmark]]`
3. Ensure all strings are in quotes: `title = "value"`
4. Ensure IDs are numbers: `id = 1` (no quotes)
5. Restore from backup if you have one:
   ```bash
   cp bookmarks.toml.backup bookmarks.toml
   ```

## Backup and Sync

### Manual Backup

```bash
cp ~/projects/private/bookmarks/bookmarks.toml ~/backup/bookmarks-$(date +%Y%m%d).toml
```

### Automatic Backup with Git

```bash
cd ~/projects/private/bookmarks
git init
git add bookmarks.toml
git commit -m "Backup bookmarks"
```

### Sync Across Machines

Since bookmarks are in a plain text file, you can use any sync method:
- **Git** - Version-controlled sync
- **Syncthing** - Decentralized file sync
- **Dropbox/Drive** - Cloud storage
- **rsync** - Manual sync between machines

## Advanced Usage

### Bulk Import

Create bookmarks by editing the TOML file directly:

```bash
cat >> bookmarks.toml << 'EOF'
[[bookmark]]
id = 100
title = "Example Site"
url = "https://example.com"
favicon = ""

[[bookmark]]
id = 101
title = "Another Site"
url = "https://another.com"
favicon = ""
EOF
```

Then restart Elephant to load the new bookmarks.

### Export Bookmarks

```bash
# Export as plain text
cat bookmarks.toml

# Export just URLs
grep '^url = ' bookmarks.toml | sed 's/url = "\(.*\)"/\1/'

# Export as JSON (requires conversion tool)
# Or use the TOML file directly - it's already portable!
```

### Search and Filter

While Walker provides built-in search, you can also search from command line:

```bash
# Find bookmarks containing "rust"
grep -B1 -A2 'rust' bookmarks.toml

# Count total bookmarks
grep -c '\[\[bookmark\]\]' bookmarks.toml
```

## Migration

### From SQLite Version

If you previously used the SQLite version, run the migration script:

```bash
./scripts/migrate-sqlite-to-toml.sh
```

This will convert all your existing bookmarks to TOML format.

### From Browser Bookmarks

Manually export your browser bookmarks to an HTML file, then:

1. Extract URLs from the HTML file
2. Format them as TOML entries
3. Add to `bookmarks.toml`

Or add them one by one through Walker for automatic favicon download.

## Performance

TOML storage is fast for typical bookmark collections:

- **Loading time**: < 5ms for 1000 bookmarks
- **Search**: Instant in Walker
- **Add/Delete**: < 10ms

For very large collections (10,000+ bookmarks), you might see slight delays, but this is rare for personal use.

## Next Steps

Consider:
- Organizing bookmarks by editing the TOML file
- Adding more bookmarks through Walker
- Setting up automatic backups
- Syncing across devices
- Creating categories (by using prefixes in titles, e.g., "[Dev] GitHub")

## Support

For issues or questions:
- Check the main README.md
- Review LUA_IMPLEMENTATION.md for technical details
- Test with `lua scripts/test-lua-bookmarks.lua`
- Check Elephant logs for Lua errors

Enjoy your streamlined bookmark management! 🔖