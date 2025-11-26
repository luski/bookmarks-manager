# Walker Integration Guide

## About Walker

Walker is a fast application launcher for Wayland/Hyprland written in Go. It supports custom modules that can be integrated to extend its functionality.

Repository: https://github.com/abenz1267/walker

## Integration Approaches

### Option 1: Custom Script Module

Walker can execute custom scripts and display their output. We'll create a script that:
1. Queries the SQLite database for bookmarks
2. Outputs results in Walker's expected format
3. Handles user selection to open URLs

### Option 2: Plugin/Module (if supported)

Check Walker's plugin API to create a native module for bookmarks.

## Implementation Plan

1. **Create a Walker-compatible script** (`src/walker/cli.ts`)
   - Already created: outputs JSON for search/list commands
   - Needs Walker-specific formatting

2. **Configure Walker** to use the bookmarks script
   - Add to Walker's config file
   - Map keybindings

3. **Add URL opening functionality**
   - Detect default browser (Hyprland)
   - Open selected bookmark URL

4. **Add quick-add feature**
   - Read from clipboard
   - Parse URL and title
   - Store in database

## Next Steps

To integrate with Walker, you'll need to:

1. Check Walker's configuration format (usually in `~/.config/walker/config.json`)
2. Add a custom module pointing to our CLI script
3. Build the TypeScript and make the CLI executable
4. Test the integration with Walker

Example Walker config snippet (may vary based on version):
```json
{
  "modules": {
    "bookmarks": {
      "cmd": "/path/to/bookmarks/dist/walker/cli.js search",
      "placeholder": "Search bookmarks..."
    }
  }
}
```
