local M = {}

local actions = require("urlview.actions")
local command = require("urlview.command")
local config = require("urlview.config")
local config_helpers = require("urlview.config.helpers")
local jump = require("urlview.jump")
local search = require("urlview.search")
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
  links = utils.process_links(links, opts)
  if links and not vim.tbl_isempty(links) then
    if type(opts.action) == "string" then
      opts.action = actions[opts.action]
    end
    pickers[picker](links, opts)
  else
    utils.log("No links found in context " .. ctx, vim.log.levels.INFO)
  end
end

local function autoload()
  config_helpers.reset_defaults()
  command.register_command()
end

autoload()

--- Custom setup function
--- Not required to be called unless user wants to modify the default config
---@param user_config table (optional)
function M.setup(user_config)
  user_config = utils.fallback(user_config, {})
  config_helpers.update_config(user_config)

  jump.register_mappings(config.jump)
end

return M
