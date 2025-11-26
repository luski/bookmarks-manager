# Walker Integration Guide

## Setup Complete! ✅

The bookmarks manager is now integrated with Walker launcher using Elephant menus.

## How It Works

The integration uses:
- **Elephant Lua Menu** (`~/.config/elephant/menus/bookmarks.lua`) - Provides dynamic bookmark listing
- **CLI Tool** (`dist/cli/bookmarks-cli.js`) - Handles database operations
- **Walker Config** - Configured to show bookmarks as a provider

## Usage

### 1. Accessing Bookmarks in Walker

**Method 1: Show in default search**
- Open Walker (your configured keybind)
- Bookmarks will appear in the default search results
- Type to filter bookmarks by title, URL, description, or tags

**Method 2: Use prefix**
- Open Walker
- Type `b` to exclusively search bookmarks
- Select a bookmark and press Enter to open in your default browser

### 2. Opening Bookmarks

- Navigate to any bookmark in Walker
- Press **Enter** to open the URL in your default browser (via `xdg-open`)

### 3. Adding New Bookmarks

**From Walker:**
1. Open Walker and access bookmarks (type `b`)
2. Select "Add New Bookmark" (first entry)
3. Copy a URL to clipboard first (the script reads from `wl-paste`)
4. Press Enter to add it

**From Command Line:**
```bash
cd /home/lgo/projects/private/bookmarks
npm run bookmarks add "https://example.com" "Example Site" "Description" "tags"
```

### 4. Deleting Bookmarks

- In Walker, navigate to a bookmark
- Look for available actions (check Walker's action hints)
- Use the delete action if available

### 5. Managing Bookmarks via CLI

```bash
cd /home/lgo/projects/private/bookmarks

# List all bookmarks
npm run bookmarks list

# Search bookmarks
npm run bookmarks search "query"

# Add bookmark
npm run bookmarks add "URL" "Title" "Description" "tags"

# Delete bookmark by ID
npm run bookmarks delete 1
```

## Configuration

### Walker Config Location
`~/.config/walker/config.toml`

### Elephant Menu Location
`~/.config/elephant/menus/bookmarks.lua`

### Database Location
`/home/lgo/projects/private/bookmarks/bookmarks.db`

## Customization

### Change the Prefix
Edit `~/.config/walker/config.toml`:
```toml
[[providers.prefixes]]
prefix = "your-prefix"  # Change "b" to whatever you want
provider = "menus:bookmarks"
```

### Modify Menu Behavior
Edit `~/.config/elephant/menus/bookmarks.lua` to:
- Change icons
- Add more actions
- Customize the "Add Bookmark" functionality
- Modify display format

## Troubleshooting

### Bookmarks don't show up in Walker
1. Make sure elephant is running: `pgrep elephant`
2. Restart elephant: `killall elephant && elephant &`
3. Check the menu file exists: `ls ~/.config/elephant/menus/bookmarks.lua`
4. Test the CLI: `node /home/lgo/projects/private/bookmarks/dist/cli/bookmarks-cli.js list`

### Can't open URLs
- Check your default browser: `xdg-settings get default-web-browser`
- Set if needed: `xdg-settings set default-web-browser firefox.desktop`

### "Add Bookmark" doesn't work
- Make sure `wl-paste` is installed (for Wayland clipboard)
- Copy a URL before trying to add
- Check notifications for error messages

## Next Steps

Consider adding:
- Browser extension to quick-add bookmarks
- Bookmark categories/folders
- Import from browser bookmarks
- Bookmark tags for better organization
- Favicon support

