Name = "bookmarks"
NamePretty = "Bookmarks"
Icon = "bookmark"
Actions = {
	open = "/usr/bin/xdg-open %VALUE%",
	delete = "lua:DeleteBookmark",
}
Cache = false
Description = "Manage and open bookmarks"

-- Load lsqlite3
local sqlite3 = require("lsqlite3")

-- Constants
local HOME = os.getenv("HOME")
local PROJECT_PATH = HOME .. "{{PROJECT_PATH}}"
local DB_PATH = PROJECT_PATH .. "/bookmarks.db"
local FAVICON_DIR = PROJECT_PATH .. "/favicons"

-- Database connection
local db = nil

-- Helper: Initialize database
local function initDatabase()
	db = sqlite3.open(DB_PATH)
	if not db then
		return nil
	end

	-- Enable WAL mode
	db:exec("PRAGMA journal_mode = WAL")

	-- Create tables if they don't exist
	db:exec([[
    CREATE TABLE IF NOT EXISTS bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      url TEXT NOT NULL UNIQUE,
      description TEXT,
      tags TEXT,
      favicon TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_bookmarks_title ON bookmarks(title);
    CREATE INDEX IF NOT EXISTS idx_bookmarks_tags ON bookmarks(tags);
    CREATE INDEX IF NOT EXISTS idx_bookmarks_created ON bookmarks(created_at);
  ]])

	return db
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

-- Helper: Ensure directory exists
local function ensureDir(path)
	os.execute("mkdir -p '" .. path .. "' 2>/dev/null")
end

-- Helper: Download favicon
local function downloadFavicon(url)
	local urlObj = url:match("^(https?://[^/]+)")
	if not urlObj then
		return nil
	end

	local domain = urlObj:match("://([^/:]+)")
	if not domain then
		return nil
	end

	ensureDir(FAVICON_DIR)

	local faviconPath = FAVICON_DIR .. "/" .. domain .. ".png"

	-- If favicon already exists, return it
	if fileExists(faviconPath) then
		return faviconPath
	end

	-- Try different favicon sources
	local faviconUrls = {
		urlObj .. "/favicon.ico",
		"https://www.google.com/s2/favicons?domain=" .. domain .. "&sz=64",
		"https://icons.duckduckgo.com/ip3/" .. domain .. ".ico",
	}

	for _, faviconUrl in ipairs(faviconUrls) do
		local cmd = string.format(
			"curl -sL -m 5 -o '%s' '%s' 2>/dev/null && test -s '%s'",
			faviconPath,
			faviconUrl,
			faviconPath
		)
		local success = os.execute(cmd)
		if success then
			return faviconPath
		end
	end

	return nil
end

-- Helper: Get clipboard content
local function getClipboard()
	local handle = io.popen("wl-paste 2>/dev/null || xclip -o -selection clipboard 2>/dev/null")
	if not handle then
		return nil
	end
	local content = handle:read("*a")
	handle:close()
	return content and content:match("^%s*(.-)%s*$") or nil
end

-- Helper: Show input dialog
local function showInput(prompt, default)
	default = default or ""
	local cmd = string.format("rofi -dmenu -p '%s' -theme-str 'entry { placeholder: \"%s\"; }'", prompt, default)
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result and result:match("^%s*(.-)%s*$") or nil
end

-- Helper: Get all bookmarks
local function getAllBookmarks()
	local bookmarks = {}
	if not db then
		db = initDatabase()
	end
	if not db then
		return bookmarks
	end

	for row in db:nrows("SELECT * FROM bookmarks ORDER BY created_at DESC") do
		table.insert(bookmarks, {
			id = row.id,
			title = row.title,
			url = row.url,
			description = row.description,
			tags = row.tags,
			favicon = row.favicon,
		})
	end

	return bookmarks
end

-- Helper: Add bookmark
local function addBookmark(url, title, description, tags)
	if not db then
		db = initDatabase()
	end
	if not db then
		return false, "Database not initialized"
	end

	-- Download favicon
	local favicon = downloadFavicon(url)

	local stmt = db:prepare([[
    INSERT INTO bookmarks (title, url, description, tags, favicon)
    VALUES (?, ?, ?, ?, ?)
  ]])

	if not stmt then
		return false, "Failed to prepare statement"
	end

	stmt:bind_values(title, url, description or "", tags or "", favicon or "")
	local result = stmt:step()
	stmt:finalize()

	if result == sqlite3.DONE then
		return true
	else
		return false, "Failed to insert bookmark"
	end
end

-- Helper: Delete bookmark by ID
local function deleteBookmark(id)
	if not db then
		db = initDatabase()
	end
	if not db then
		return false
	end

	local stmt = db:prepare("DELETE FROM bookmarks WHERE id = ?")
	if not stmt then
		return false
	end

	stmt:bind_values(id)
	local result = stmt:step()
	stmt:finalize()

	return result == sqlite3.DONE
end

-- Helper: Get bookmark by ID
local function getBookmarkById(id)
	if not db then
		db = initDatabase()
	end
	if not db then
		return nil
	end

	local stmt = db:prepare("SELECT * FROM bookmarks WHERE id = ?")
	if not stmt then
		return nil
	end

	stmt:bind_values(id)
	if stmt:step() == sqlite3.ROW then
		local bookmark = {
			id = stmt:get_value(0),
			title = stmt:get_value(1),
			url = stmt:get_value(2),
			description = stmt:get_value(3),
			tags = stmt:get_value(4),
			favicon = stmt:get_value(5),
		}
		stmt:finalize()
		return bookmark
	end
	stmt:finalize()
	return nil
end

-- Walker function: Get entries for display
function GetEntries()
	local entries = {}

	-- Initialize database
	if not db then
		db = initDatabase()
	end

	-- Add "Add New Bookmark" entry first
	table.insert(entries, {
		Text = "Add New Bookmark",
		Subtext = "Add URL from clipboard or enter manually",
		Value = "action:add",
		Icon = "list-add",
		Actions = {
			open = "lua:AddBookmark",
		},
	})

	-- Get all bookmarks
	local bookmarks = getAllBookmarks()

	for _, bookmark in ipairs(bookmarks) do
		local icon = "text-html"
		if bookmark.favicon and fileExists(bookmark.favicon) then
			icon = bookmark.favicon
		end

		local subtext = bookmark.description
		if not subtext or subtext == "" then
			subtext = bookmark.url
		end

		table.insert(entries, {
			Text = bookmark.title,
			Subtext = subtext,
			Value = "bookmark:" .. bookmark.id .. ":" .. bookmark.url,
			Icon = icon,
		})
	end

	return entries
end

-- Walker action: Delete bookmark
function DeleteBookmark(value, args)
	local id = value:match("^bookmark:(%d+):")

	if not id then
		os.execute("notify-send 'Error' 'Could not find bookmark ID'")
		return
	end

	-- Get bookmark details for notification
	local bookmark = getBookmarkById(tonumber(id))
	local title = bookmark and bookmark.title or "Unknown"

	-- Delete the bookmark
	local success = deleteBookmark(tonumber(id))

	if success then
		os.execute(string.format("notify-send '🗑️  Bookmark Deleted' '%s'", title))
	else
		os.execute("notify-send 'Error' 'Could not delete bookmark'")
	end
end

-- Walker action: Add bookmark
function AddBookmark(value, args)
	-- Get URL from clipboard or input
	local url = getClipboard()

	-- Validate or ask for URL
	if not url or not url:match("^https?://") then
		url = showInput("Enter URL", url or "https://")
	end

	if not url or url == "" or not url:match("^https?://") then
		os.execute("notify-send 'Cancelled' 'No valid URL provided'")
		return
	end

	-- Get title (default to URL)
	local title = showInput("Enter title", url)
	if not title or title == "" then
		title = url
	end

	-- Get description (optional)
	local description = showInput("Enter description (optional)", "")

	-- Get tags (optional)
	local tags = showInput("Enter tags (optional, comma-separated)", "")

	-- Add the bookmark
	local success, err = addBookmark(url, title, description, tags)

	if success then
		os.execute(string.format("notify-send '✅ Bookmark Added' '%s'", title))
	else
		os.execute(string.format("notify-send 'Error' 'Failed to add bookmark: %s'", err or "Unknown error"))
	end
end
