local M = {}

local config = require("urlview.config")

-- SEE: lua pattern matching (https://riptutorial.com/lua/example/20315/lua-pattern-matching)
-- regex equivalent: [A-Za-z0-9@:%._+~#=/\-?&]*
local pattern = "[%w@:%%._+~#=/%-?&]*"
local http_pattern = "https?://"
local www_pattern = "www%."

--- Extracts urls from the given content
---@param content string
---@return table (list) of captures (prefix, url map)
function M.extract_urls(content)
	---@type table (set)
	local captures = {}

	-- Extract URLs starting with http:// or https://
	for capture in content:gmatch(http_pattern .. "%w" .. pattern) do
		local prefix = capture:match(http_pattern)
		local url = capture:gsub(http_pattern, "")
		captures[url] = prefix
	end

	-- Extract URLs starting with www, excluding already extracted http(s) URLs
	for capture in content:gmatch(www_pattern .. "%w" .. pattern) do
		if not captures[capture] then
			captures[capture] = ""
		end
	end

	-- Combine captures
	local result = {}
	for url, prefix in pairs(captures) do
		local link = prefix .. url
		if link ~= "" then
			table.insert(result, link)
		end
	end

	return result
end

--- Opens the url in the browser
---@param url string
function M.navigate_url(url)
	if config.use_netrw then
		vim.cmd("call netrw#BrowseX('" .. url .. "',netrw#CheckIfRemote())")
	else
		-- supports MacOS, Linux, and FreeBSD
		local cmd = nil
		if vim.fn.has "mac" == 1 then -- MacOS
			cmd = "open "
		elseif vim.fn.has "linux" == 1 or vim.fn.has "bsd" then -- Linux and FreeBSD
			cmd = "xdg-open "
		end

		if cmd then
			os.execute(cmd .. vim.fn.shellescape(url, 1))
		else
			vim.notify("Unsupported OS for opening url from the command line", vim.log.levels.DEBUG)
		end
	end
end

--- Determines whether to accept the current value or use a fallback value
---@param value any @value to check
---@param fallback_value any @fallback value to use
---@param fallback_comparison any @fallback comparison, defaults to nil
---@return any @value, or @fallback if @value is @fallback_comparison
function M.fallback(value, fallback_value, fallback_comparison)
	return (value == fallback_comparison and fallback_value) or value
end

--- Mimics the ternary operator
---@param condition boolean @condition to check
---@param if_true any @value to return if @condition is true
---@param if_false any @value to return if @condition is false
---@return any @condition ? if_true : if_false
function M.ternary(condition, if_true, if_false)
	return (condition and if_true) or if_false
end

--- Logs user warnings
---@param message string @message to log
function M.log(message)
	if config.debug then
		vim.api.nvim_echo({ { message, "WarningMsg" } }, false, {})
	end
end

return M
