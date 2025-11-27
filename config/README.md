# Configuration Files

This directory contains configuration files for integrating the Bookmarks Manager with Walker launcher and Elephant menus.

## Files

### `bookmarks.lua`
Elephant menu configuration that provides the bookmarks interface in Walker.

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

Run the setup script from the project root:

```bash
./scripts/setup-walker-integration.sh
```

This will:
1. ✓ Check if Walker and Elephant are installed
2. ✓ Build the project if needed
3. ✓ Copy `bookmarks.lua` to Elephant menus directory
4. ✓ Update paths to match your project location
5. ✓ Guide you through Walker configuration
6. ✓ Restart Elephant to load the menu

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

The `bookmarks.lua` file automatically detects Node.js in your PATH. If you use a version manager like fnm, ensure Node is in your PATH or update the fallback path in the Lua file.

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

## Related Documentation

- [WALKER_INTEGRATION.md](../WALKER_INTEGRATION.md) - Full integration guide
- [IMPLEMENTATION.md](../IMPLEMENTATION.md) - Implementation details
- [README.md](../README.md) - Main project documentation