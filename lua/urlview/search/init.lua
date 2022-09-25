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
---@return table (list) of strings (extracted links)
function M.packer()
  local links = {}
  -- selene: allow(undefined_variable)
  for _, info in pairs(packer_plugins or {}) do
    local is_file = vim.startswith(info.url, "/")
    if not is_file then
      table.insert(links, info.url)
    end
  end
  return links
end

--- Extracts urls of vim-plug plugins
---@return table (list) of strings (extracted links)
function M.vimplug()
  local links = {}
  for _, info in pairs(vim.g.plugs or {}) do
    table.insert(links, info.uri)
  end
  return links
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
