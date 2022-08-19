local M = {}

local utils = require("urlview.utils")
local search_helpers = require("urlview.search.helpers")

-- NOTE: make sure to add accepted params for `opts` to `urlview.search.validation` as well if needed

--- Extracts urls from the current buffer or a given buffer
---@param opts table (map, optional)
---@return table (list) of strings (extracted links)
function M.buffer(opts)
  local content = utils.get_buffer_content(opts.bufnr)
  return search_helpers.content(content)
end

--- Extracts urls from a given file
---@param opts table (map, optional)
---@return table (list) of strings (extracted links)
function M.file(opts)
  local content = utils.fallback(utils.read_file(opts.filepath), "")
  return search_helpers.content(content)
end

--- Extracts urls of packer.nvim plugins
---@return table (list) of strings (extracted links)
function M.packer()
  local links = {}
  local missing_plugins = {}
  -- selene: allow(undefined_variable)
  for name, info in pairs(packer_plugins or {}) do
    local is_file = vim.startswith(info.url, "/")
    if info.url and not is_file then
      table.insert(links, info.url)
    else
      table.insert(missing_plugins, name)
    end
  end

  -- find links for missing plugins
  -- HACK: addresses https://github.com/axieax/urlview.nvim/issues/19
  if not vim.tbl_isempty(missing_plugins) then
    local failed_plugins = {}
    local opt_plugins, start_plugins = require("packer.plugin_utils").list_installed_plugins()
    local packer_root = require("packer").config.package_root

    for _, name in ipairs(missing_plugins) do
      local url
      local start_path = string.format("%s/packer/start/%s", packer_root, name)
      local opt_path = string.format("%s/packer/opt/%s", packer_root, name)

      -- check if the plugin is in the `start` or `opt` directories
      if start_plugins[start_path] then
        url = search_helpers.git_remote_url(start_path)
      elseif opt_plugins[opt_path] then
        url = search_helpers.git_remote_url(opt_path)
      end

      if url then
        table.insert(links, url)
      else
        table.insert(failed_plugins, name)
      end
    end

    -- missing plugins whose url still cannot be found
    if not vim.tbl_isempty(failed_plugins) then
      utils.log("Failed to find links for plugins: " .. vim.inspect(failed_plugins))
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
  -- error check for invalid searcher (still allow function calls, but return nil)
  __index = function(_, k)
    if k ~= nil then
      utils.log("Cannot search context " .. k)
      return function()
        return nil
      end
    end
  end,
})
