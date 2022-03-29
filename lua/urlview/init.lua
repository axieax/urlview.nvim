local M = {}

local pickers = require("urlview.pickers")
local config = require("urlview.config")
local utils = require("urlview.utils")

--- Display the urls in the current buffer
---@param picker string (optional)
function M.search(picker, ...)
	picker = utils.ternary(pickers[picker] ~= nil, picker, config.picker)

	local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local items = utils.extract_urls(content)
	if vim.tbl_isempty(items) then
		utils.log("No URLs found in buffer")
	else
		return pickers[picker](items, ...)
	end
end

--- urlview custom setup
---@param user_config table (optional)
function M.setup(user_config)
	user_config = utils.fallback(user_config, {})
	config = vim.tbl_deep_extend("force", config, user_config)
end

function M.available_pickers()
	return vim.tbl_keys(pickers)
end

return M
