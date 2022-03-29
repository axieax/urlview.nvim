local M = {}

local config = require("urlview.config")
local utils = require("urlview.utils")

--- Display the urls in the current buffer using vim.ui.select
---@param items table (list) of captures { url, prefix }
function M.default(items)
	local options = {
		prompt = config.title,
	}
	local function on_choice(item, _)
		if item then
			vim.cmd("call netrw#BrowseX('" .. item .. "',netrw#CheckIfRemote())")
		end
	end

	vim.ui.select(items, options, on_choice)
end

--- Displays the urls in the current buffer using Telescope
---@param items table (list) of captures { url, prefix }
function M.telescope(items, opts)
	local telescope = pcall(require, "telescope")
	if not telescope then
		utils.log("Telescope is not installed, defaulting to vim.ui.select picker.")
		return M.default(items)
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values

	pickers.new(opts, {
		prompt_title = config.title,
		finder = finders.new_table({
			results = items,
		}),
		sorter = conf.generic_sorter(opts),
	}):find()
end

function M.__index(_, k)
	if k ~= nil then
		utils.log(k .. " is not a valid picker, defaulting to vim.ui.select picker.")
		return M.default
	end
end

return setmetatable(M, M)
