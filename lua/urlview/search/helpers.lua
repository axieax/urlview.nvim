local M = {}

local utils = require("urlview.utils")

-- SEE: lua pattern matching (https://riptutorial.com/lua/example/20315/lua-pattern-matching)
-- regex equivalent: [A-Za-z0-9@:%._+~#=/\-?&]*
local pattern = "[%w@:%%._+~#=/%-?&]*"
local http_pattern = "https?://"
local www_pattern = "www%."

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

local function default_custom_generator(patterns)
	return function(opts)
		local content = opts.content or utils.get_buffer_content(opts.bufnr)
		return utils.extract_pattern(content, patterns.capture, patterns.format)
	end
end

function M.register_custom_searches(searchers)
	local search = require("urlview.search")
	for source, patterns in pairs(searchers) do
		if type(patterns) == "function" then
			-- TODO: test
			search[source] = patterns
		elseif type(patterns) == "table" and not vim.tbl_islist(patterns) then
			search[source] = default_custom_generator(patterns)
		else
			utils.log("Cannot register custom searcher " .. source .. ": invalid type (not a function or map table)")
		end
	end
end

return M
