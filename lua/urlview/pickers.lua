local M = {}

local utils = require("urlview.utils")

--- Displays items using the vim.ui.select picker
---@param items table (list) of strings
---@param opts table (map) of options
function M.native(items, opts)
  local options = { prompt = opts.title }
  local function on_choice(item, _)
    if item then
      opts.action(item)
    end
  end

  vim.ui.select(items, options, on_choice)
end

--- Displays items using the Telescope picker
---@param items table (list) of strings
---@param opts table (map) of options
function M.telescope(items, opts)
  local telescope = pcall(require, "telescope")
  if not telescope then
    utils.log("Telescope is not installed, defaulting to native vim.ui.select picker.", vim.log.levels.INFO)
    return M.native(items, opts)
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local conf = require("telescope.config").values
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")

  pickers
    .new(opts, {
      prompt_title = opts.title,
      finder = finders.new_table({
        results = items,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local multi = picker:get_multi_selection()
          local single = picker:get_selection()
          actions.close(prompt_bufnr)
          if #multi > 0 then
            for _, entry in ipairs(multi) do
              opts.action(entry[1])
            end
          elseif single[1] then
            opts.action(single[1])
          end
        end)
        return true
      end,
    })
    :find()
end

return setmetatable(M, {
  -- use default `vim.ui.select` when provided an invalid picker
  __index = function(_, k)
    if k ~= nil then
      utils.log(k .. " is not a valid picker, defaulting to native vim.ui.select picker.", vim.log.levels.INFO)
      return M.native
    end
  end,
})
