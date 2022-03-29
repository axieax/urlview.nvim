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
			utils.navigate_url(item)
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
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values

	pickers.new(opts, {
		prompt_title = config.title,
		finder = finders.new_table({
			results = items,
		}),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection[1] then
					utils.navigate_url(selection[1])
				end
			end)
			return true
		end,
	}):find()
end

function M.__index(_, k)
	if k ~= nil then
		utils.log(k .. " is not a valid picker, defaulting to vim.ui.select picker.")
		return M.default
	end
end

return setmetatable(M, M)
