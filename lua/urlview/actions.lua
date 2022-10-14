local M = {}

local utils = require("urlview.utils")

--- Use command to open the URL
---@param cmd string @name of executable to run
---@param raw_url string @unescaped URL to be run by the executable
local function shell_exec(cmd, raw_url)
  -- NOTE: `vim.fn.system` shellescapes arguments
  local function exec()
    -- HACK: `start` cmd itself doesn't exist but lives under `cmd`
    if utils.os:match("Windows") then
      return true, vim.fn.system({ "cmd", "/c", cmd, raw_url })
    end
    return vim.fn.executable(cmd) == 1, vim.fn.system({ cmd, raw_url })
  end

  local is_executable, err = exec()
  if is_executable then
    if err ~= "" then
      utils.log(string.format("Could not navigate link with `%s`:\n%s", cmd, err), vim.log.levels.ERROR)
    end
  else
    utils.log(
      string.format("Cannot use command `%s` to navigate links (either empty or non-executable)", cmd),
      vim.log.levels.ERROR
    )
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
  if utils.os == "Darwin" then -- MacOS
    shell_exec("open", raw_url)
  elseif utils.os == "Linux" or utils.os == "FreeBSD" then -- Linux and FreeBSD
    shell_exec("xdg-open", raw_url)
  elseif utils.os:match("Windows") then -- Windows
    shell_exec("start", raw_url)
  else
    utils.log(
      "Unsupported operating system for `system` action. Please raise a GitHub issue for " .. os,
      vim.log.levels.WARN
    )
  end
end

--- Copy URL to clipboard
---@param raw_url string @unescaped URL
function M.clipboard(raw_url)
  vim.api.nvim_command(string.format("let @+ = '%s'", raw_url))
  utils.log(string.format("URL %s copied to clipboard", raw_url), vim.log.levels.INFO)
end

return setmetatable(M, {
  -- execute action as command if it is not one of the above module keys
  __index = function(_, k)
    if k ~= nil then
      return function(raw_url)
        return shell_exec(k, raw_url)
      end
    end
  end,
})
