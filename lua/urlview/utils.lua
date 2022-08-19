local M = {}

local config = require("urlview.config")
local constants = config._constants

--- Extracts content from a given buffer
---@param bufnr number (optional)
---@return string @content of buffer
function M.get_buffer_content(bufnr)
  bufnr = M.fallback(bufnr, 0)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end

--- Extracts content from a given file
---@param filepath string @path to file
---@return string|nil @content of file (or nil if file cannot be open)
function M.read_file(filepath)
  local f = io.open(vim.fn.expand(filepath), "r")
  if f == nil then
    M.log("Could not open file: " .. filepath)
    return nil
  end
  local content = f:read("*all")
  f:close()
  return content
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

--- Opens the url in the browser
---@param url string
function M.navigate_url(url)
  local cmd = config.navigate_method
  if cmd == "netrw" then
    local ok, res = pcall(vim.cmd, string.format("call netrw#BrowseX('%s', netrw#CheckIfRemote('%s'))", url, url))
    if not ok and vim.startswith(res, "Vim(call):E117: Unknown function") then
      -- lazily update default navigate method if netrw is disabled
      config.navigate_method = "system"
      cmd = "system"
    else
      return
    end
  end

  if cmd == "system" then
    local os = vim.loop.os_uname().sysname
    if os == "Darwin" then -- MacOS
      cmd = "open"
    elseif os == "Linux" or os == "FreeBSD" then -- Linux and FreeBSD
      cmd = "xdg-open"
    end
  end

  if cmd and vim.fn.executable(cmd) then
    os.execute(cmd .. " " .. vim.fn.shellescape(url, 1))
  else
    vim.notify("Cannot use " .. cmd .. " to navigate links", vim.log.levels.DEBUG)
  end
end

--- Prepare links before being displayed
---@param links table @list of extracted links
---@param opts table @Optional options
---@return table @list of prepared links
function M.prepare_links(links, opts)
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
  -- NOTE: links with different protocols / www prefix / trailing slashes
  -- are not filtered to ensure links do not break
  if M.fallback(opts.unique, config.unique) then
    local map = {}
    for _, link in ipairs(new_links) do
      map[link] = true
    end
    new_links = vim.tbl_keys(map)
  end

  -- Sort links alphabetically (case insensitive)
  if M.fallback(opts.sorted, config.sorted) then
    table.sort(new_links, function(a, b)
      return a:lower() < b:lower()
    end)
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
function M.log(message)
  if config.debug then
    vim.notify("[urlview.nvim] " .. message, vim.log.levels.WARN)
  end
end

--- Converts a boolean to a string
---@param value string @value to convert
---@return boolean|nil @value as a boolean, or nil if not a boolean
function M.string_to_boolean(value)
  local bool_map = { ["true"] = true, ["false"] = false }
  if not bool_map[value] then
    M.log("Could not convert " .. value .. " to boolean")
  end
  return bool_map[value]
end

return M
