local M = {}

local utils = require("urlview.utils")

-- SEE: lua pattern matching (https://riptutorial.com/lua/example/20315/lua-pattern-matching)
-- regex equivalent: [A-Za-z0-9@:%._+~#=/\-?&]*
local pattern = "[%w@:%%._+~#=/%-?&]*"
local http_pattern = "https?://"
local www_pattern = "www%."

--- Extracts urls from the current buffer
---@param opts table (map, optional) containing bufnr (number, optional)
---@return table (list) of extracted links
function M.buffer(opts)
	local bufnr = utils.fallback(opts.bufnr, 0)
	local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	return M.content(content)
end

--- Extracts urls from the given content
---@param content string
---@return table (list) of extracted links
function M.content(content)
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
	local links = {}
	for url, prefix in pairs(captures) do
		local link = prefix .. url
		if link ~= "" then
			table.insert(links, link)
		end
	end

	return links
end

--- Extracts urls of packer.nvim plugins
---@return table (list) of extracted links
function M.packer()
	local links = {}
	for _, info in pairs(packer_plugins or {}) do
		table.insert(links, info.url)
	end
	return links
end

function M.__index(_, k)
	if k ~= nil then
		utils.log("Cannot search context " .. k)
		return function()
			return nil
		end
	end
end

return setmetatable(M, M)
