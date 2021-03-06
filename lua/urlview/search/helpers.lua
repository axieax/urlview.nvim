local M = {}

local constants = require("urlview.config")._constants
local utils = require("urlview.utils")

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

--- Generates a simple search function from a template table
---@param patterns table (map) with `capture` and `format` keys
---@return function
local function default_custom_generator(patterns)
  if not patterns.capture or not patterns.format then
    return nil
  end

  return function(opts)
    local content = opts.content or utils.get_buffer_content(opts.bufnr)
    return utils.extract_pattern(content, patterns.capture, patterns.format)
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
          )
        )
      end
    else
      utils.log(
        string.format("Unable to register custom searcher %s: invalid type (not a function or map table)", source)
      )
    end
  end
end

--- Finds the remote url of a local Git respository
---@param path string @path to a local Git repository
---@return string|nil @remote url of the repository if found, otherwise nil
function M.git_remote_url(path)
  local url = vim.fn.system(string.format("cd %s && git remote get-url origin", vim.fn.shellescape(path)))
  return utils.ternary(vim.v.shell_error == 0, url:gsub("%.git\n$", ""), nil)
end

return M
