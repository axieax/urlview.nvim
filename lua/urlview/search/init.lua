local M = {}

local utils = require("urlview.utils")
local search_helpers = require("urlview.search.helpers")

-- NOTE: make sure to add accepted params for `opts` to `urlview.search.validation` as well if needed

--- Extracts urls from the current buffer or a given buffer
---@param opts table (map)
---@return table (list) of strings (extracted links)
function M.buffer(opts)
  local content = search_helpers.get_buffer_content(opts.bufnr)
  return search_helpers.content(content)
end

--- Extracts urls from a given file
---@param opts table (map)
---@return table (list) of strings (extracted links)
function M.file(opts)
  local content = search_helpers.read_file(opts.filepath)
  return search_helpers.content(content)
end

--- Extracts urls of packer.nvim plugins
---@param opts table (map)
---@return table (list) of strings (extracted links)
function M.packer(opts)
  -- selene: allow(global_usage)
  local plugins = _G.packer_plugins or {}
  return search_helpers.extract_plugins_spec(plugins, "url", opts.include_branch)
end

--- Extracts urls of lazy.nvim plugins
---@param opts table (map)
---@return table (list) of strings (extracted links)
function M.lazy(opts)
  local ok, lazy = pcall(require, "lazy")
  local plugins = ok and lazy.plugins() or {}
  return search_helpers.extract_plugins_spec(plugins, "url", opts.include_branch)
end

--- Extracts urls of vim-plug plugins
---@param opts table (map)
---@return table (list) of strings (extracted links)
function M.vimplug(opts)
  local plugins = vim.g.plugs or {}
  return search_helpers.extract_plugins_spec(plugins, "uri", opts.include_branch)
end

return setmetatable(M, {
  -- error check for invalid searcher (still allow function calls, but return empty table)
  __index = function(_, k)
    if k ~= nil then
      utils.log("Cannot search context " .. k, vim.log.levels.WARN)
      return function()
        return {}
      end
    end
  end,
})
