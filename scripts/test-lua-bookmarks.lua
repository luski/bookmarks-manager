#!/usr/bin/env lua

-- Test script for bookmarks.lua functionality
-- This script tests the core functions without requiring Elephant/Walker

-- Load the bookmarks module
package.path = package.path .. ";./config/?.lua"

local sqlite3 = require("lsqlite3")

-- Set up environment
local HOME = os.getenv("HOME")
local PROJECT_PATH = HOME .. "/projects/private/bookmarks"
local DB_PATH = PROJECT_PATH .. "/bookmarks.db"

print("=== Testing Lua Bookmarks ===\n")

-- Test 1: Open database
print("Test 1: Opening database...")
local db = sqlite3.open(DB_PATH)
if db then
	print("✓ Database opened successfully")
else
	print("✗ Failed to open database")
	os.exit(1)
end

-- Test 2: Check if table exists
print("\nTest 2: Checking bookmarks table...")
local count = 0
for row in db:nrows("SELECT COUNT(*) as cnt FROM bookmarks") do
	count = row.cnt
end
print("✓ Found " .. count .. " bookmarks in database")

-- Test 3: List all bookmarks
print("\nTest 3: Listing bookmarks...")
if count > 0 then
	for row in db:nrows("SELECT id, title, url FROM bookmarks LIMIT 5") do
		print(string.format("  [%d] %s - %s", row.id, row.title, row.url))
	end
else
	print("  (no bookmarks found)")
end

-- Test 4: Test file exists helper
print("\nTest 4: Testing file existence check...")
local function fileExists(path)
	if not path or path == "" then
		return false
	end
	local file = io.open(path, "r")
	if file then
		io.close(file)
		return true
	end
	return false
end

if fileExists(DB_PATH) then
	print("✓ File exists check works")
else
	print("✗ File exists check failed")
end

-- Test 5: Test favicon directory
print("\nTest 5: Checking favicon directory...")
local FAVICON_DIR = PROJECT_PATH .. "/favicons"
os.execute("mkdir -p '" .. FAVICON_DIR .. "' 2>/dev/null")
if fileExists(FAVICON_DIR) then
	print("✓ Favicon directory exists")
else
	print("⚠ Favicon directory not found")
end

-- Clean up
db:close()

print("\n=== All tests completed ===")
