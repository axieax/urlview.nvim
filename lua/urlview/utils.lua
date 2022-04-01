local M = {}

local config = require("urlview.config")

--- Opens the url in the browser
---@param url string
function M.navigate_url(url)
	local cmd = config.navigate_method
	if cmd == "netrw" then
		vim.cmd("call netrw#BrowseX('" .. url .. "',netrw#CheckIfRemote())")
		return
	end

	if cmd == "auto" then
		local os = vim.loop.os_uname().sysname
		if os == "Darwin" then -- MacOS
			cmd = "open"
		elseif os == "Linux" or os == "FreeBSD" then -- Linux and FreeBSD
			cmd = "xdg-open"
		end
	end

	if cmd and vim.fn.executable(cmd) then
		os.execute(cmd .. " " .. vim.fn.shellescape(url, 1))
	else
		vim.notify("Cannot use " .. cmd .. " to navigate links", vim.log.levels.DEBUG)
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
