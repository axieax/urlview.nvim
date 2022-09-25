local M = {}

local constants = require("urlview.config")._constants
local utils = require("urlview.utils")

--- Extracts content from a given buffer
---@param bufnr number (optional)
---@return string @content of buffer
function M.get_buffer_content(bufnr)
  bufnr = M.fallback(bufnr, 0)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end

--- Extracts content from a given file
---@param filepath string @path to file
---@return string @content of file (or empty string if file cannot be open)
function M.read_file(filepath)
  local f, err = io.open(vim.fn.expand(filepath), "r")
  if f == nil then
    M.log(err, vim.log.levels.ERROR)
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
---@param format string @format pattern to display
---@return table @list of extracted links
function M.extract_pattern(content, capture, format)
  local captures = {}
  for c in content:gmatch(capture) do
    table.insert(captures, string.format(format, c))
  end
  return captures
end

--- Generates a simple search function from a template table
---@param patterns table (map) with `capture` and `format` keys
---@return function|nil
local function default_custom_generator(patterns)
  if not patterns.capture or not patterns.format then
    return nil
  end

  return function(opts)
    local content = opts.content or M.get_buffer_content(opts.bufnr)
    return M.extract_pattern(content, patterns.capture, patterns.format)
  end
end

--- Registers custom searchers
---@param searchers table (map) of { source: patterns (function or table) }
function M.register_custom_searches(searchers)
  local search = require("urlview.search")
  for source, patterns in pairs(searchers) do
    if type(patterns) == "function" then
      search[source] = patterns
    elseif type(patterns) == "table" and not vim.tbl_islist(patterns) then
      local func = default_custom_generator(patterns)
      if func then
        search[source] = func
      else
        utils.log(
          string.format(
            "Unable to register custom searcher %s: please ensure that the table has 'capture' and 'format' fields",
            source
          ),
          vim.log.levels.WARN
        )
      end
    else
      utils.log(
        string.format("Unable to register custom searcher %s: invalid type (not a function or map table)", source),
        vim.log.levels.WARN
      )
    end
  end
end

return M
