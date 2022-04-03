local M = {}

local default_config = {
  -- Prompt title
  title = "Links: ",
  -- Default picker to display links with
  -- Options: "default" (vim.ui.select) or "telescope"
  default_picker = "default",
  -- set the default protocol for us to prefix URLs with if they don't start with http/https
  default_prefix = "https://",
  -- Command or method to open links with
  -- Options: "netrw", "auto" (default OS browser); or "firefox", "chromium" etc.
  navigate_method = "netrw",
  -- Logs user warnings
  debug = true,
  -- Custom search captures
  custom_searches = {},
}

M._options = default_config

return setmetatable(M, {
  __index = function(_, k)
    return M._options[k]
  end,
})
