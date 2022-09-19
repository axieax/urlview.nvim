local M = {}

local utils = require("urlview.utils")

--- Use command to open the URL
---@param cmd string @name of executable to run
---@param raw_url string @unescaped URL to be run by the executable
local function shell_exec(cmd, raw_url)
  if cmd and vim.fn.executable(cmd) then
    -- NOTE: `vim.fn.system` shellescapes arguments
    local err = vim.fn.system({ cmd, raw_url })
    if err ~= "" then
      utils.log(string.format("Could not navigate link with `%s`:\n%s", cmd, err))
    end
  else
    utils.log(string.format("Cannot use %s to navigate links", cmd), vim.log.levels.DEBUG)
  end
end

--- Use `netrw` to navigate to a URL
---@param raw_url string @unescaped URL
function M.netrw(raw_url)
  local url = vim.fn.shellescape(raw_url)
  local ok, err = pcall(vim.cmd, string.format("call netrw#BrowseX(%s, netrw#CheckIfRemote(%s))", url, url))
  if not ok and vim.startswith(err, "Vim(call):E117: Unknown function") then
    -- lazily use system action if netrw is disabled
    M.system(raw_url)
  end
end

--- Use the user's default browser to navigate to a URL
---@param raw_url string @unescaped URL
function M.system(raw_url)
  local os = vim.loop.os_uname().sysname
  if os == "Darwin" then -- MacOS
    shell_exec("open", raw_url)
  elseif os == "Linux" or os == "FreeBSD" then -- Linux and FreeBSD
    shell_exec("xdg-open", raw_url)
  else
    utils.log("Unsupported operating system for `system` action. Please raise a GitHub issue for " .. os)
  end
end

--- Copy URL to clipboard
---@param raw_url string @unescaped URL
function M.clipboard(raw_url)
  vim.api.nvim_command(string.format("let @+ = '%s'", raw_url))
  utils.log(string.format("URL %s copied to clipboard", raw_url))
end

function M.__index(_, k)
  if k ~= nil then
    return function(raw_url)
      return shell_exec(k, raw_url)
    end
  end
end

return setmetatable(M, M)
