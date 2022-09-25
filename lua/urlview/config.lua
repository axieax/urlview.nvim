local M = {
  _constants = {
    -- SEE: lua pattern matching (https://riptutorial.com/lua/example/20315/lua-pattern-matching)
    -- regex equivalent: [A-Za-z0-9@:%._+~#=/\-?&]*
    pattern = "[%w@:%%._+~#=/%-?&]*",
    http_pattern = "https?://",
    www_pattern = "www%.",
  },
}

-- NOTE: ensure this is in sync with README config
local default_config = {
  -- Prompt title (`<context> <default_title>`, e.g. `Buffer Links:`)
  default_title = "Links:",
  -- Default picker to display links with
  -- Options: "native" (vim.ui.select) or "telescope"
  default_picker = "native",
  -- Set the default protocol for us to prefix URLs with if they don't start with http/https
  default_prefix = "https://",
  -- Command or method to open links with
  -- Options: "netrw", "system" (default OS browser); or "firefox", "chromium" etc.
  -- By default, this is "netrw", or "system" if netrw is disabled
  default_action = "netrw",
  -- Ensure links shown in the picker are unique (no duplicates)
  unique = true,
  -- Ensure links shown in the picker are sorted alphabetically
  sorted = true,
  -- Minimum log level (recommended at least `vim.log.levels.WARN` for error detection warnings)
  debug_level_min = vim.log.levels.INFO,
  -- Keymaps for jumping to previous / next URL in buffer
  jump = {
    prev = "[u",
    next = "]u",
  },
  -- Custom search captures
  custom_searches = {},
}

--- Resets the internal config to the default options
M._reset_defaults = function()
  M._options = default_config
end

-- Used to auto-load the default config
M._reset_defaults()

return setmetatable(M, {
  -- general get and set operations refer to the internal config table M._options
  __index = function(_, k)
    return M._options[k]
  end,
  __newindex = function(_, k, v)
    M._options[k] = v
  end,
})
