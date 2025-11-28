# Testing Checklist for Lua Implementation

Use this checklist to verify the Lua-only implementation works correctly.

## Prerequisites Check

- [ ] Lua 5.4+ installed: `lua -v`
- [ ] luarocks installed: `luarocks --version`
- [ ] lsqlite3 installed: `lua -e "require('lsqlite3')"`
- [ ] Elephant installed: `which elephant`
- [ ] Walker installed: `which walker`
- [ ] curl installed: `which curl`
- [ ] rofi or dmenu installed: `which rofi` or `which dmenu`

## Installation Test

- [ ] Run `./scripts/install-lua-deps.sh`
  - [ ] lsqlite3 installs successfully
  - [ ] No error messages

- [ ] Run `./scripts/setup-walker-integration.sh`
  - [ ] Lua dependencies check passes
  - [ ] Elephant menu installed
  - [ ] Walker config updated
  - [ ] Elephant restarted

## Database Test

- [ ] Run `lua scripts/test-lua-bookmarks.lua`
  - [ ] Database opens successfully
  - [ ] Can read existing bookmarks
  - [ ] File exists check works
  - [ ] Favicon directory exists

- [ ] Manually check database:
  ```bash
  sqlite3 bookmarks.db ".schema bookmarks"
  sqlite3 bookmarks.db "SELECT COUNT(*) FROM bookmarks;"
  ```

## Walker Integration Test

- [ ] Open Walker
- [ ] Type `!` to filter bookmarks
  - [ ] Bookmarks appear
  - [ ] Favicons display correctly
  - [ ] "Add New Bookmark" entry appears first

- [ ] Test opening bookmark:
  - [ ] Select a bookmark
  - [ ] Press Enter
  - [ ] URL opens in default browser

- [ ] Test deleting bookmark:
  - [ ] Select a bookmark
  - [ ] Press Ctrl+X
  - [ ] Confirmation notification appears
  - [ ] Bookmark removed from list
  - [ ] Database updated: `sqlite3 bookmarks.db "SELECT COUNT(*) FROM bookmarks;"`

## Add Bookmark Test

- [ ] Copy a URL to clipboard: `echo "https://example.com" | wl-copy`
- [ ] Open Walker and select "Add New Bookmark"
  - [ ] URL pre-filled from clipboard
  - [ ] Title dialog appears
  - [ ] Description dialog appears (optional)
  - [ ] Tags dialog appears (optional)
  - [ ] Success notification appears
  - [ ] Bookmark appears in Walker
  - [ ] Favicon downloaded (check `favicons/` directory)

## Favicon Test

- [ ] Add bookmark with new domain
- [ ] Check `favicons/` directory for `domain.png`
- [ ] Verify favicon shows in Walker
- [ ] Try opening bookmark with favicon
- [ ] Check that existing favicons are reused (no re-download)

## Performance Test

Run this simple benchmark:

```bash
time for i in {1..10}; do
  sqlite3 bookmarks.db "SELECT * FROM bookmarks LIMIT 10;" > /dev/null
done
```

Should complete in < 100ms total (~10ms per iteration).

## Error Handling Test

- [ ] Try adding duplicate URL
  - [ ] Error notification appears
  - [ ] No crash

- [ ] Try deleting non-existent bookmark
  - [ ] Graceful handling
  - [ ] Error notification

- [ ] Test with no clipboard content
  - [ ] Input dialog appears with empty/placeholder

- [ ] Test with invalid URL
  - [ ] Validation or graceful handling

## Elephant/Walker Integration Test

- [ ] Restart Elephant: `killall elephant && elephant &`
- [ ] Check Elephant logs: `journalctl -f | grep elephant`
  - [ ] No Lua errors
  - [ ] bookmarks.lua loads successfully

- [ ] Restart Walker (if applicable)
- [ ] Verify bookmarks still appear

## Migration Test (if upgrading from Node.js version)

- [ ] Existing bookmarks preserved
- [ ] Existing favicons preserved
- [ ] No data loss
- [ ] All URLs still open correctly

## Cleanup Test

- [ ] Lua path set in shell RC file
  - [ ] `eval $(luarocks path --lua-version 5.4)` in `~/.bashrc` or `~/.zshrc`
- [ ] Test in new shell session
  - [ ] Open new terminal
  - [ ] Run `lua -e "require('lsqlite3')"`
  - [ ] Should work without manual path setup

## Documentation Test

- [ ] README.md accurate
- [ ] LUA_IMPLEMENTATION.md comprehensive
- [ ] MIGRATION_GUIDE.md helpful
- [ ] WALKER_INTEGRATION.md up to date

## Final Verification

- [ ] All tests pass
- [ ] No error messages
- [ ] Performance is fast
- [ ] User experience is smooth
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
- **Version**: `feat/lua-only-refactor`
- **Status**: [ ] Pass [ ] Fail

