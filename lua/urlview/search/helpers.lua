local M = {}

local constants = require("urlview.config.constants")
local utils = require("urlview.utils")

--- Extracts content from a given buffer
---@param bufnr number (optional)
---@return string @content of buffer
function M.get_buffer_content(bufnr)
  bufnr = utils.fallback(bufnr, 0)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    utils.log(string.format("Invalid buffer number provided: %s", bufnr), vim.log.levels.ERROR)
    return ""
  end
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end

--- Extracts content from a given file
---@param filepath string @path to file
---@return string @content of file (or empty string if file cannot be open)
function M.read_file(filepath)
  local f, err = io.open(vim.fn.expand(filepath), "r")
  if f == nil then
    utils.log(err, vim.log.levels.ERROR)
    return ""
  end
  local content = f:read("*all")
  f:close()
  return content
end

--- Extracts urls from the given content
---@param content string
---@return table (list) of strings (extracted links)
function M.content(content)
  ---@type table (map) of string (url base pattern) to string (prefix / uri protocol)
  local captures = {}

  -- NOTE: this method enforces unique matches regardless of config (before a general pattern is implemented)

  -- Extract URLs starting with http:// or https://
  for capture in content:gmatch(constants.http_pattern .. "%w" .. constants.pattern) do
    local prefix = capture:match(constants.http_pattern)
    local url = capture:gsub(constants.http_pattern, "")
    captures[url] = prefix
  end

  -- Extract URLs starting with www, excluding already extracted http(s) URLs
  for capture in content:gmatch(constants.www_pattern .. "%w" .. constants.pattern) do
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

--- Extract @captures from @content and display them as @formats
---@param content string @content to extract from
---@param capture string @capture pattern to extract
---@param format string @Optional format pattern to display
---@return table @list of extracted links
function M.extract_pattern(content, capture, format)
  local captures = {}
  for c in content:gmatch(capture) do
    local fmt = format and string.format(format, c) or c
    table.insert(captures, fmt)
  end
  return captures
end

--- Extract Git links from @plugins_spec
---@param plugins_spec table @map of specs for plugins
---@param uri_key string @key in plugin_spec containing the Git URL
---@param include_branch boolean @whether to include the branch in the URL
---@return table @list of extracted links
function M.extract_plugins_spec(plugins_spec, uri_key, include_branch)
  local function filter_files(plugin_url)
    if plugin_url == nil then
      return false
    end
    local fs_stat = vim.loop.fs_stat(plugin_url)
    return not fs_stat or vim.tbl_isempty(fs_stat)
  end

  local function extract_key(plugin_spec)
    if plugin_spec[uri_key] == nil then
      return nil
    end
    local uri = plugin_spec[uri_key]:gsub("%.git$", "") -- remove `.git` suffix
    if include_branch and plugin_spec.branch then
      uri = string.format("%s/tree/%s", uri, plugin_spec.branch)
    end
    return uri
  end

  local plugins = vim.tbl_map(extract_key, vim.tbl_values(plugins_spec or {}))
  return vim.tbl_filter(filter_files, plugins)
end

--- Generates a simple search function from a template table
---@param pattern table (map) with `capture` key and optional `format` key
---@return function|nil
function M.generate_custom_search(pattern)
  if not pattern.capture then
    utils.log("Unable to generate custom search: please ensure that the table has 'capture' field", vim.log.levels.WARN)
    return nil
  end

  return function(opts)
    local content = opts.content or M.get_buffer_content(opts.bufnr)
    return M.extract_pattern(content, pattern.capture, pattern.format)
  end
end

return M
