Name = "bookmarks"
NamePretty = "Bookmarks"
Icon = "bookmark"
Action = "/usr/bin/xdg-open %VALUE%"
Cache = false
Description = "Manage and open bookmarks"

-- Constants
local PROJECT_PATH = "{{PROJECT_PATH}}"
local BOOKMARKS_CLI = PROJECT_PATH .. "/dist/cli/bookmarks-cli.js"
local ADD_CLI = PROJECT_PATH .. "/dist/cli/add-interactive.js"

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

-- Helper: Run bookmarks CLI command
local function runCli(args)
	return io.popen("node " .. BOOKMARKS_CLI .. " " .. args .. " 2>/dev/null")
end

function GetEntries()
	local entries = {}
	local handle = runCli("list")

	if handle then
		for line in handle:lines() do
			local id, title, url, desc, favicon = line:match("^(%d+)|([^|]*)|([^|]*)|([^|]*)|(.*)$")
			if id and title and url then
				local icon = fileExists(favicon) and favicon or "text-html"

				table.insert(entries, {
					Text = title,
					Subtext = desc ~= "" and desc or url,
					Value = url,
					Icon = icon,
				})
			end
		end
		handle:close()
	end

	-- Add entry to create new bookmark (always first)
	table.insert(entries, 1, {
		Text = "Add New Bookmark",
		Subtext = "Add URL from clipboard or enter manually",
		Value = "add",
		Icon = "list-add",
		Actions = {
			open = "lua:AddBookmark",
		},
	})

	return entries
end

function DeleteBookmark(value, args)
	local id = value:match(":(%d+)$")

	if id then
		-- Get bookmark title for notification
		local title = "Unknown"
		local handle = runCli("list")
		if handle then
			for line in handle:lines() do
				local found_id, found_title = line:match("^(%d+)|([^|]*)|")
				if found_id == id then
					title = found_title
					break
				end
			end
			handle:close()
		end

		-- Delete the bookmark
		os.execute("node " .. BOOKMARKS_CLI .. " delete " .. id)
		os.execute("notify-send '🗑️  Bookmark Deleted' '" .. title .. "'")
	else
		os.execute("notify-send 'Error' 'Could not delete bookmark'")
	end
end

function AddBookmark(value, args)
	os.execute("node " .. ADD_CLI)
end
