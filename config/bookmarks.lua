Name = "bookmarks"
NamePretty = "Bookmarks"
Icon = "bookmark"
Action = "/usr/bin/xdg-open %VALUE%"
Cache = false
Description = "Manage and open bookmarks"

function GetEntries()
	local entries = {}
	local bookmark_cli = "{{PROJECT_PATH}}/dist/cli/bookmarks-cli.js"
	local node_path = io.popen("which node"):read("*l")

	-- Fallback to fnm if node not in PATH
	if not node_path or node_path == "" then
		local fnm_base = os.getenv("HOME") .. "/.local/share/fnm/node-versions"
		-- Try to find latest Node version in fnm
		local handle = io.popen("ls -1 " .. fnm_base .. " 2>/dev/null | sort -V | tail -1")
		if handle then
			local latest_version = handle:read("*l")
			handle:close()
			if latest_version and latest_version ~= "" then
				node_path = fnm_base .. "/" .. latest_version .. "/installation/bin/node"
			end
		end
	end

	-- Final fallback
	if not node_path or node_path == "" then
		node_path = "/usr/bin/node"
	end

	local handle = io.popen(node_path .. " " .. bookmark_cli .. " list 2>/dev/null")
	if handle then
		for line in handle:lines() do
			local id, title, url, desc, favicon = line:match("^(%d+)|([^|]*)|([^|]*)|([^|]*)|(.*)$")
			if id and title and url then
				local icon = "text-html"
				-- Use favicon if available and file exists
				if favicon and favicon ~= "" then
					local file = io.open(favicon, "r")
					if file then
						io.close(file)
						icon = favicon
					end
				end

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

	-- Add entry to create new bookmark
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
	local bookmark_cli = "{{PROJECT_PATH}}/dist/cli/bookmarks-cli.js"
	local node_path = io.popen("which node"):read("*l")

	-- Fallback to fnm if node not in PATH
	if not node_path or node_path == "" then
		local fnm_base = os.getenv("HOME") .. "/.local/share/fnm/node-versions"
		local handle = io.popen("ls -1 " .. fnm_base .. " 2>/dev/null | sort -V | tail -1")
		if handle then
			local latest_version = handle:read("*l")
			handle:close()
			if latest_version and latest_version ~= "" then
				node_path = fnm_base .. "/" .. latest_version .. "/installation/bin/node"
			end
		end
	end

	if not node_path or node_path == "" then
		node_path = "/usr/bin/node"
	end

	-- The ID is passed in the args from the action
	local id = value:match(":(%d+)$")

	if id then
		-- Get the bookmark title for notification
		local handle = io.popen(node_path .. " " .. bookmark_cli .. " list 2>/dev/null")
		local title = "Unknown"
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
		os.execute(node_path .. " " .. bookmark_cli .. " delete " .. id)
		os.execute("notify-send '🗑️  Bookmark Deleted' '" .. title .. "'")
	else
		os.execute("notify-send 'Error' 'Could not delete bookmark'")
	end
end

function AddBookmark(value, args)
	local add_interactive = "{{PROJECT_PATH}}/dist/cli/add-interactive.js"
	local node_path = io.popen("which node"):read("*l")

	-- Fallback to fnm if node not in PATH
	if not node_path or node_path == "" then
		local fnm_base = os.getenv("HOME") .. "/.local/share/fnm/node-versions"
		local handle = io.popen("ls -1 " .. fnm_base .. " 2>/dev/null | sort -V | tail -1")
		if handle then
			local latest_version = handle:read("*l")
			handle:close()
			if latest_version and latest_version ~= "" then
				node_path = fnm_base .. "/" .. latest_version .. "/installation/bin/node"
			end
		end
	end

	if not node_path or node_path == "" then
		node_path = "/usr/bin/node"
	end

	-- Run the interactive add script
	os.execute(node_path .. " " .. add_interactive)
end
