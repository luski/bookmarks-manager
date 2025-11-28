#!/usr/bin/env lua

-- Test script for bookmarks.lua functionality
-- This script tests the core functions without requiring Elephant/Walker

-- Set up environment
local HOME = os.getenv("HOME")
local PROJECT_PATH = HOME .. "/projects/private/bookmarks"
local BOOKMARKS_FILE = PROJECT_PATH .. "/bookmarks.toml"
local FAVICON_DIR = PROJECT_PATH .. "/favicons"

print("=== Testing Lua Bookmarks (TOML) ===\n")

-- TOML Parser (simple implementation for our use case)
local function parseTOML(content)
	local bookmarks = {}
	local current = nil

	for line in content:gmatch("[^\r\n]+") do
		line = line:match("^%s*(.-)%s*$") -- trim

		if line:match("^%[%[bookmark%]%]$") then
			if current then
				table.insert(bookmarks, current)
			end
			current = {}
		elseif current and line ~= "" and not line:match("^#") then
			local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
			if key and value then
				-- Remove quotes from strings
				if value:match('^".*"$') or value:match("^'.*'$") then
					value = value:sub(2, -2)
				end
				-- Convert to number if it's a number
				if tonumber(value) then
					value = tonumber(value)
				end
				current[key] = value
			end
		end
	end

	if current then
		table.insert(bookmarks, current)
	end

	return bookmarks
end

-- Helper: Check if file exists
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

-- Test 1: Check if TOML file exists
print("Test 1: Checking TOML file...")
if fileExists(BOOKMARKS_FILE) then
	print("✓ Bookmarks file exists: " .. BOOKMARKS_FILE)
else
	print("⚠ Bookmarks file not found, creating empty file...")
	os.execute("mkdir -p '" .. PROJECT_PATH .. "' 2>/dev/null")
	os.execute("touch '" .. BOOKMARKS_FILE .. "'")
	print("✓ Created empty bookmarks file")
end

-- Test 2: Read and parse TOML file
print("\nTest 2: Reading bookmarks from TOML...")
local file = io.open(BOOKMARKS_FILE, "r")
if not file then
	print("✗ Failed to open bookmarks file")
	os.exit(1)
end

local content = file:read("*all")
file:close()

local bookmarks = {}
if content and content ~= "" then
	bookmarks = parseTOML(content)
	print("✓ Parsed " .. #bookmarks .. " bookmarks from file")
else
	print("✓ File is empty (no bookmarks yet)")
end

-- Test 3: List all bookmarks
print("\nTest 3: Listing bookmarks...")
if #bookmarks > 0 then
	for i, bookmark in ipairs(bookmarks) do
		if i <= 5 then
			print(string.format("  [%d] %s - %s", bookmark.id or 0, bookmark.title or "?", bookmark.url or "?"))
		end
	end
	if #bookmarks > 5 then
		print(string.format("  ... and %d more", #bookmarks - 5))
	end
else
	print("  (no bookmarks found)")
end

-- Test 4: Test file exists helper
print("\nTest 4: Testing file existence check...")
if fileExists(BOOKMARKS_FILE) then
	print("✓ File exists check works")
else
	print("✗ File exists check failed")
end

-- Test 5: Test favicon directory
print("\nTest 5: Checking favicon directory...")
os.execute("mkdir -p '" .. FAVICON_DIR .. "' 2>/dev/null")
local handle = io.popen("test -d '" .. FAVICON_DIR .. "' && echo 'yes' || echo 'no'")
local result = handle:read("*a"):match("^%s*(.-)%s*$")
handle:close()

if result == "yes" then
	print("✓ Favicon directory exists: " .. FAVICON_DIR)
else
	print("⚠ Favicon directory not found")
end

-- Test 6: Validate bookmark structure
print("\nTest 6: Validating bookmark structure...")
local allValid = true
for _, bookmark in ipairs(bookmarks) do
	if not bookmark.id or not bookmark.title or not bookmark.url then
		print("✗ Invalid bookmark found (missing required fields)")
		allValid = false
		break
	end
end
if allValid then
	print("✓ All bookmarks have valid structure")
end

print("\n=== All tests completed ===")
