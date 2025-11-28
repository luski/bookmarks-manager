# Testing Checklist for TOML Implementation

Use this checklist to verify the TOML-based implementation works correctly.

## Prerequisites Check

- [ ] Lua 5.4+ installed: `lua -v`
- [ ] Elephant installed: `which elephant`
- [ ] Walker installed: `which walker`
- [ ] curl installed: `which curl`
- [ ] rofi or dmenu installed: `which rofi` or `which dmenu`

## Installation Test

- [ ] Run `./scripts/setup-walker-integration.sh`
  - [ ] System dependencies check passes
  - [ ] Empty bookmarks.toml created (if doesn't exist)
  - [ ] Favicons directory created
  - [ ] Elephant menu installed to `~/.config/elephant/menus/bookmarks.lua`
  - [ ] Walker config updated
  - [ ] Elephant restarted
  - [ ] No error messages

## TOML File Test

- [ ] Check TOML file exists: `ls -la bookmarks.toml`
- [ ] Run `lua scripts/test-lua-bookmarks.lua`
  - [ ] TOML file opens successfully
  - [ ] Can parse TOML content
  - [ ] Can read existing bookmarks
  - [ ] File exists check works
  - [ ] Favicon directory exists
  - [ ] Bookmark structure validation passes

- [ ] Manually check TOML file:
  ```bash
  cat bookmarks.toml
  ```
  - [ ] Format is valid TOML
  - [ ] Each bookmark has `[[bookmark]]` header
  - [ ] Each bookmark has id, title, url, favicon fields

## Walker Integration Test

- [ ] Open Walker (your configured keybind, usually `Super+Space`)
- [ ] Type `!` to filter bookmarks
  - [ ] Bookmarks appear
  - [ ] Favicons display correctly
  - [ ] "Add New Bookmark" entry appears first

- [ ] Test searching without prefix:
  - [ ] Type part of a bookmark title
  - [ ] Bookmarks appear in results
  - [ ] Can switch between different providers

- [ ] Test opening bookmark:
  - [ ] Select a bookmark
  - [ ] Press Enter
  - [ ] URL opens in default browser

- [ ] Test deleting bookmark:
  - [ ] Select a bookmark
  - [ ] Press Ctrl+X
  - [ ] Confirmation notification appears
  - [ ] Bookmark removed from list
  - [ ] TOML file updated: `cat bookmarks.toml | grep -c "[[bookmark]]"`

## Add Bookmark Test

- [ ] Copy a URL to clipboard: `echo "https://example.com" | wl-copy`
- [ ] Open Walker and select "Add New Bookmark"
  - [ ] URL pre-filled from clipboard
  - [ ] Title dialog appears
  - [ ] Success notification appears
  - [ ] Bookmark appears in Walker immediately
  - [ ] Favicon downloaded (check `favicons/` directory)
  - [ ] TOML file updated: `cat bookmarks.toml`

- [ ] Test adding bookmark without clipboard:
  - [ ] Clear clipboard or copy non-URL
  - [ ] Select "Add New Bookmark"
  - [ ] URL input dialog appears
  - [ ] Enter URL manually
  - [ ] Bookmark saves successfully

## Favicon Test

- [ ] Add bookmark with new domain (e.g., `https://github.com`)
- [ ] Check `favicons/` directory for `github.com.png`
- [ ] Verify favicon shows in Walker
- [ ] Add another bookmark from same domain
- [ ] Verify favicon is reused (no re-download)
- [ ] Check that bookmark without favicon still works

## Manual Editing Test

- [ ] Open `bookmarks.toml` in text editor
- [ ] Manually add a bookmark:
  ```toml
  [[bookmark]]
  id = 999
  title = "Test Bookmark"
  url = "https://test.example.com"
  favicon = ""
  ```
- [ ] Save file
- [ ] Restart Elephant: `killall elephant && elephant &`
- [ ] Open Walker
- [ ] Verify manual bookmark appears

- [ ] Edit an existing bookmark title
- [ ] Restart Elephant
- [ ] Verify changes appear in Walker

## Performance Test

Add several bookmarks and test responsiveness:

```bash
# Add 10 bookmarks quickly
for i in {1..10}; do
  echo "[[bookmark]]
id = $i
title = \"Test Bookmark $i\"
url = \"https://example$i.com\"
favicon = \"\"
" >> bookmarks.toml
done
```

- [ ] Restart Elephant
- [ ] Open Walker and search bookmarks
- [ ] Should be instant (< 50ms)
- [ ] No lag or delay

Clean up test bookmarks:
```bash
# Remove test bookmarks manually or reset the file
```

## Error Handling Test

- [ ] Try adding duplicate URL
  - [ ] Error notification appears
  - [ ] No duplicate entry in TOML file
  - [ ] No crash

- [ ] Try deleting non-existent bookmark
  - [ ] Graceful handling
  - [ ] Error notification or silent failure
  - [ ] No corruption of TOML file

- [ ] Test with no clipboard content
  - [ ] Input dialog appears with empty/placeholder
  - [ ] Can enter URL manually

- [ ] Test with invalid URL format
  - [ ] Validation or graceful handling
  - [ ] Can re-enter correct URL

- [ ] Test with corrupted TOML file
  - [ ] Create backup first
  - [ ] Add invalid syntax to TOML file
  - [ ] Check Elephant doesn't crash
  - [ ] Restore from backup

## Elephant/Walker Integration Test

- [ ] Restart Elephant: `killall elephant && elephant &`
- [ ] Verify Elephant is running: `pgrep elephant`
- [ ] Check for Lua errors in system logs (if available)
  - [ ] No Lua errors
  - [ ] bookmarks.lua loads successfully

- [ ] Restart Walker (if applicable)
- [ ] Verify bookmarks still appear

- [ ] Check Elephant menu file:
  ```bash
  cat ~/.config/elephant/menus/bookmarks.lua | grep "TOML"
  ```
  - [ ] TOML parser code is present
  - [ ] No references to SQLite/lsqlite3

## File Permissions Test

- [ ] Check TOML file permissions: `ls -la bookmarks.toml`
  - [ ] File is readable and writable by user
  
- [ ] Check favicons directory: `ls -la favicons/`
  - [ ] Directory is writable by user
  - [ ] Favicon files are readable

## Backup and Restore Test

- [ ] Create backup: `cp bookmarks.toml bookmarks.backup.toml`
- [ ] Add a test bookmark via Walker
- [ ] Restore from backup: `cp bookmarks.backup.toml bookmarks.toml`
- [ ] Restart Elephant
- [ ] Verify test bookmark is gone
- [ ] Verify original bookmarks are intact

## Migration Test (if upgrading from SQLite version)

- [ ] If `bookmarks.db` exists, bookmarks can be migrated
- [ ] Run migration command (see LUA_IMPLEMENTATION.md)
- [ ] All bookmarks transferred to TOML
- [ ] Favicons preserved
- [ ] No data loss
- [ ] All URLs still open correctly
- [ ] Can safely delete old `bookmarks.db` file

## Multi-line and Special Characters Test

- [ ] Add bookmark with special characters in title:
  - [ ] Title with quotes: `My "Favorite" Site`
  - [ ] Title with emoji: `🔖 Bookmarks Manager`
  - [ ] Title with ampersand: `Q&A Site`
  
- [ ] Verify they save correctly in TOML
- [ ] Verify they display correctly in Walker
- [ ] Verify they can be deleted

## Edge Cases Test

- [ ] Add bookmark with very long title (100+ characters)
  - [ ] Saves correctly
  - [ ] Displays (possibly truncated) in Walker
  
- [ ] Add bookmark with very long URL (500+ characters)
  - [ ] Saves correctly
  - [ ] Opens correctly
  
- [ ] Add bookmark with international characters
  - [ ] Title: `日本語 Chinese Русский العربية`
  - [ ] Saves and displays correctly

- [ ] Test with empty bookmarks file
  - [ ] Create empty `bookmarks.toml`
  - [ ] Restart Elephant
  - [ ] Only "Add New Bookmark" appears
  - [ ] Can add first bookmark successfully

## Documentation Test

- [ ] README.md accurate and up-to-date
- [ ] LUA_IMPLEMENTATION.md reflects TOML implementation
- [ ] WALKER_INTEGRATION.md still relevant
- [ ] No references to SQLite in docs

## Final Verification

- [ ] All tests pass
- [ ] No error messages
- [ ] Performance is fast
- [ ] User experience is smooth
- [ ] TOML files are human-readable
- [ ] Easy to backup and restore
- [ ] No external Lua dependencies required
- [ ] Ready for daily use!

---

## Notes

Record any issues or observations here:

```
(your notes)
```

## Sign-off

- **Tested by**: _______________
- **Date**: _______________
- **Version**: TOML implementation
- **Status**: [ ] Pass [ ] Fail

## Comparison with SQLite Version

Benefits observed:
- [ ] Simpler installation (no luarocks/lsqlite3)
- [ ] Bookmarks are human-readable
- [ ] Easy to manually edit/backup
- [ ] No Elephant compatibility issues
- [ ] Faster or same performance
- [ ] No database corruption risk