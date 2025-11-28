Name = "bookmarks"
NamePretty = "Bookmarks"
Icon = "bookmark"
Actions = {
	open = "lua:OpenBookmark",
	delete = "lua:DeleteBookmark",
	add = "lua:AddBookmark",
}
Cache = false
Description = "Manage and open bookmarks"

-- Constants
local HOME = os.getenv("HOME")
local PROJECT_PATH = HOME .. "{{PROJECT_PATH}}"
local BOOKMARKS_FILE = PROJECT_PATH .. "/bookmarks.toml"
local FAVICON_DIR = PROJECT_PATH .. "/favicons"

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

-- TOML Writer
local function writeTOML(bookmarks)
	local lines = {}

	for _, bookmark in ipairs(bookmarks) do
		table.insert(lines, "[[bookmark]]")
		table.insert(lines, "id = " .. tostring(bookmark.id))
		table.insert(lines, "title = \"" .. bookmark.title:gsub('"', '\\"') .. "\"")
		table.insert(lines, "url = \"" .. bookmark.url:gsub('"', '\\"') .. "\"")
		if bookmark.favicon and bookmark.favicon ~= "" then
			table.insert(lines, "favicon = \"" .. bookmark.favicon:gsub('"', '\\"') .. "\"")
		else
			table.insert(lines, "favicon = \"\"")
		end
		table.insert(lines, "")
	end

	return table.concat(lines, "\n")
end

-- Helper: Read bookmarks from TOML file
local function readBookmarks()
	local file = io.open(BOOKMARKS_FILE, "r")
	if not file then
		return {}
	end

	local content = file:read("*all")
	file:close()

	if not content or content == "" then
		return {}
	end

	return parseTOML(content)
end

-- Helper: Write bookmarks to TOML file
local function writeBookmarks(bookmarks)
	-- Ensure directory exists
	os.execute("mkdir -p '" .. PROJECT_PATH .. "' 2>/dev/null")

	local file = io.open(BOOKMARKS_FILE, "w")
	if not file then
		return false
	end

	local content = writeTOML(bookmarks)
	file:write(content)
	file:close()

	return true
end

-- Helper: Get next available ID
local function getNextId(bookmarks)
	local maxId = 0
	for _, bookmark in ipairs(bookmarks) do
		if bookmark.id and bookmark.id > maxId then
			maxId = bookmark.id
		end
	end
	return maxId + 1
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
		return ""
	end

	local domain = urlObj:match("://([^/:]+)")
	if not domain then
		return ""
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

	return ""
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

-- Helper: Show input dialog using Walker dmenu mode
local function showInput(prompt, default)
	default = default or ""
	-- Use Walker's dmenu mode for input
	local cmd = string.format("echo '%s' | walker --dmenu", default)
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result and result:match("^%s*(.-)%s*$") or nil
end

-- Helper: Add bookmark
local function addBookmark(url, title)
	local bookmarks = readBookmarks()

	-- Check if URL already exists
	for _, bookmark in ipairs(bookmarks) do
		if bookmark.url == url then
			return false, "URL already exists"
		end
	end

	-- Download favicon
	local favicon = downloadFavicon(url)

	-- Create new bookmark
	local newBookmark = {
		id = getNextId(bookmarks),
		title = title,
		url = url,
		favicon = favicon,
	}

	table.insert(bookmarks, newBookmark)

	-- Write back to file
	local success = writeBookmarks(bookmarks)

	if success then
		return true
	else
		return false, "Failed to write bookmarks file"
	end
end

-- Helper: Delete bookmark by ID
local function deleteBookmark(id)
	local bookmarks = readBookmarks()
	local found = false

	for i, bookmark in ipairs(bookmarks) do
		if bookmark.id == id then
			table.remove(bookmarks, i)
			found = true
			break
		end
	end

	if not found then
		return false
	end

	return writeBookmarks(bookmarks)
end

-- Helper: Get bookmark by ID
local function getBookmarkById(id)
	local bookmarks = readBookmarks()

	for _, bookmark in ipairs(bookmarks) do
		if bookmark.id == id then
			return bookmark
		end
	end

	return nil
end

-- Walker function: Get entries for display
function GetEntries()
	local entries = {}

	-- Get all bookmarks
	local bookmarks = readBookmarks()

	-- If no bookmarks, show placeholder
	if #bookmarks == 0 then
		table.insert(entries, {
			Text = "No bookmarks yet",
			Subtext = "Press Ctrl+A to add your first bookmark",
			Value = "empty:placeholder",
			Icon = "bookmark",
		})
		return entries
	end

	for _, bookmark in ipairs(bookmarks) do
		local icon = "text-html"
		if bookmark.favicon and bookmark.favicon ~= "" and fileExists(bookmark.favicon) then
			icon = bookmark.favicon
		end

		table.insert(entries, {
			Text = bookmark.title,
			Subtext = bookmark.url,
			Value = "bookmark:" .. bookmark.id .. ":" .. bookmark.url,
			Icon = icon,
		})
	end

	return entries
end

-- Walker action: Open bookmark
function OpenBookmark(value, args)
	local url = value:match("^bookmark:%d+:(.+)$")

	if not url then
		os.execute("notify-send 'Error' 'Could not extract URL'")
		return
	end

	-- Get default browser
	local handle = io.popen("xdg-settings get default-web-browser 2>/dev/null")
	local default_browser = nil
	if handle then
		default_browser = handle:read("*a")
		handle:close()
		default_browser = default_browser and default_browser:match("^%s*(.-)%s*$")
	end

	-- Open with default browser
	if default_browser and default_browser ~= "" then
		-- Extract desktop file name without .desktop extension
		local browser_name = default_browser:match("(.+)%.desktop$") or default_browser
		os.execute(string.format("gtk-launch '%s' '%s' 2>/dev/null &", default_browser, url))
	else
		-- Fallback to xdg-open
		os.execute(string.format("xdg-open '%s' 2>/dev/null &", url))
	end
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

-- Walker action: Add bookmark (called by ctrl+a shortcut)
function AddBookmark(value, args)
	-- Get URL from clipboard if it's valid, otherwise use empty default
	local clipboard = getClipboard()
	local default_url = ""

	if clipboard and clipboard:match("^https?://") then
		default_url = clipboard
	end

	-- Always ask for URL, pre-fill with clipboard if valid
	local url = showInput("Enter URL", default_url ~= "" and default_url or "https://")

	if not url or url == "" or not url:match("^https?://") then
		os.execute("notify-send 'Cancelled' 'No valid URL provided'")
		return
	end

	-- Get title (default to URL)
	local title = showInput("Enter title", url)
	if not title or title == "" then
		title = url
	end

	-- Add the bookmark
	local success, err = addBookmark(url, title)

	if success then
		os.execute(string.format("notify-send '✅ Bookmark Added' '%s'", title))
	else
		os.execute(string.format("notify-send 'Error' 'Failed to add bookmark: %s'", err or "Unknown error"))
	end
end
