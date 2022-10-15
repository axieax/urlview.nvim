local M = {}

local config = require("urlview.config")
local constants = require("urlview.config.constants")

M.os = vim.loop.os_uname().sysname

function M.alphabetical_sort(tbl)
  table.sort(tbl, function(a, b)
    return a:lower() < b:lower()
  end)
end

--- Processes links before being displayed
---@param links table @list of extracted links
---@param opts table @Optional options
---@return table @list of prepared links
function M.process_links(links, opts)
  opts = M.fallback(opts, {})
  local new_links = {}

  -- Attach missing HTTP(s) protocol
  for _, link in ipairs(links) do
    if not link:match("^" .. constants.http_pattern) then
      link = config.default_prefix .. link
    end
    table.insert(new_links, link)
  end

  -- Filter duplicate links
  -- NOTE: links with different protocols / www prefix / trailing slashes are not filtered to ensure links do not break
  if M.fallback(opts.unique, config.unique) then
    local map = {}
    for _, link in ipairs(new_links) do
      map[link] = true
    end
    new_links = vim.tbl_keys(map)
  end

  -- Sort links alphabetically (case insensitive)
  if M.fallback(opts.sorted, config.sorted) then
    M.alphabetical_sort(new_links)
  end

  return new_links
end

--- Determines whether to accept the current value or use a fallback value
---@param value any @value to check
---@param fallback_value any @fallback value to use
---@param fallback_comparison any @fallback comparison, defaults to nil
---@return any @value, or @fallback if @value is @fallback_comparison
function M.fallback(value, fallback_value, fallback_comparison)
  return (value == fallback_comparison and fallback_value) or value
end

--- Mimics the ternary operator
---@param condition boolean @condition to check
---@param if_true any @value to return if @condition is true
---@param if_false any @value to return if @condition is false
---@return any @condition ? if_true : if_false
function M.ternary(condition, if_true, if_false)
  return (condition and if_true) or if_false
end

--- Logs user warnings
---@param message string @message to log
---@param level integer|nil @log level, defaults to "warning"
function M.log(message, level)
  level = M.fallback(level, vim.log.levels.WARN)
  if level >= config.log_level_min then
    vim.notify("[urlview.nvim] " .. message, level)
  end
end

--- Converts a boolean to a string
---@param value string @value to convert
---@return boolean|nil @value as a boolean, or nil if not a boolean
function M.string_to_boolean(value)
  value = value:lower()
  local bool_map = { ["true"] = true, ["false"] = false }
  if not bool_map[value] then
    M.log("Could not convert " .. value .. " to boolean")
  end
  return bool_map[value]
end

return M
