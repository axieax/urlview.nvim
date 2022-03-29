local M = {}

local pattern = "[%w@:%%._+~#=/%-?&]*"
local http_pattern = "https?://"
local www_pattern = "www%."
local default_prefix = "https://"

--- Display the urls in the current buffer using vim.ui.select
---@param bufnr number (optional)
function M.search(bufnr)
	bufnr = bufnr or 0
	local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	local items = M.extract_urls(content)
	local options = {
		prompt = "URLs: ",
		format_item = function(item)
			return item.prefix .. item.url
		end,
	}
	local function on_choice(item, _)
		if item ~= nil then
			local prefix = (item.prefix == "" and default_prefix) or item.prefix
			vim.cmd("call netrw#BrowseX('" .. prefix .. item.url .. "',netrw#CheckIfRemote())")
		end
	end

	vim.ui.select(items, options, on_choice)
end

--- Extracts urls from the given content
---@param content string
---@return table (list) of captures (prefix, url map)
function M.extract_urls(content)
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
		table.insert(result, {
			prefix = prefix,
			url = url,
		})
	end

	return result
end

return M
