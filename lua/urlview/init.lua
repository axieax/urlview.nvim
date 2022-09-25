local M = {}

local actions = require("urlview.actions")
local config = require("urlview.config")
local jump = require("urlview.jump")
local search = require("urlview.search")
local search_helpers = require("urlview.search.helpers")
local search_validation = require("urlview.search.validation")
local pickers = require("urlview.pickers")
local utils = require("urlview.utils")

--- Searchs the provided context for links
---@param ctx string where to search (default: search buffer)
---@param opts table (map, optional)
function M.search(ctx, opts)
  ctx = utils.fallback(ctx, "buffer")
  opts = utils.fallback(opts, {})
  opts.action = utils.fallback(opts.action, config.default_action)
  local picker = utils.fallback(opts.picker, config.default_picker)
  if not opts.title then
    local should_capitalise = string.match(config.default_title, "^%u")
    local ctx_title = utils.ternary(should_capitalise, ctx:gsub("^%l", string.upper), ctx)
    opts.title = string.format("%s %s", ctx_title, config.default_title)
  end

  -- search ctx for links and display with picker
  opts = search_validation[ctx](opts)
  local links = search[ctx](opts)
  links = utils.prepare_links(links, opts)
  if links and not vim.tbl_isempty(links) then
    if type(opts.action) == "string" then
      opts.action = actions[opts.action]
    end
    pickers[picker](links, opts)
  else
    utils.log("No links found in context " .. ctx, vim.log.levels.INFO)
  end
end

-- index of `opts` parameter in `M.search`
local OPTS_INDEX = 2

--- Processes arguments provided through the `UrlView` command for `M.search`
function M.command_search(...)
  local args = { ... }
  local opts = {}
  if #args >= OPTS_INDEX then
    -- process provided options
    for i = OPTS_INDEX, #args do
      local equals_index = string.find(args[i], "=")
      if equals_index then
        local key = string.sub(args[i], 1, equals_index - 1)
        local value = string.sub(args[i], equals_index + 1)
        -- remove beginning and trailing quotes from value if present
        if string.match(value, "^[\"']") and string.match(value, "[\"']$") then
          value = string.sub(value, 2, -2)
        end
        -- type conversion
        if vim.tbl_contains({ "unique", "sorted" }, key) then
          value = utils.string_to_boolean(value)
        end
        opts[key] = value
      end
    end
  end
  M.search(args[1], opts)
end

local function check_breaking()
  if config.navigate_method ~= nil then
    utils.log([[`config.navigate_method` has been deprecated for `config.default_action`
    Please see https://github.com/axieax/urlview.nvim/issues/37#issuecomment-1251246520]])
  end
  if config.debug ~= nil then
    utils.log([[`config.debug` has been deprecated for `config.log_level_min`
    Please see https://github.com/axieax/urlview.nvim/issues/37#issuecomment-1257113527]])
  end
end

--- Custom setup function
--- Not required to be called unless user wants to modify the default config
---@param user_config table (optional)
function M.setup(user_config)
  user_config = utils.fallback(user_config, {})
  config._options = vim.tbl_deep_extend("force", config._options, user_config)
  check_breaking()

  search_helpers.register_custom_searches(config.custom_searches)
  jump.register_mappings(config.jump)
end

return M
