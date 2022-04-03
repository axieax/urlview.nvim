local M = {}

local config = require("urlview.config")
local pickers = require("urlview.pickers")
local search = require("urlview.search")
local search_helpers = require("urlview.search.helpers")
local utils = require("urlview.utils")

--- Searchs the provided context for links
---@param ctx string where to search (default: search buffer)
---@param picker string (optional)
---@param opts table (map, optional)
function M.search(ctx, picker, opts)
  picker = utils.fallback(picker, config.default_picker)
  opts = utils.fallback(opts, {})
  ctx = utils.fallback(ctx, opts.ctx) or "buffer"
  if not opts.title then
    local should_capitalise = string.match(config.default_title, "^%u")
    local ctx_title = utils.ternary(should_capitalise, ctx:gsub("^%l", string.upper), ctx)
    opts.title = string.format("%s %s", ctx_title, config.default_title)
  end

  -- search ctx for links and display with picker
  local links = search[ctx](opts)
  if links and not vim.tbl_isempty(links) then
    pickers[picker](links, opts)
  else
    utils.log("No links found in context " .. ctx)
  end
end

--- Custom setup function
--- Not required to be called unless user wants to modify the default config
---@param user_config table (optional)
function M.setup(user_config)
  user_config = utils.fallback(user_config, {})
  config._options = vim.tbl_deep_extend("force", config._options, user_config)

  search_helpers.register_custom_searches(config.custom_searches)
end

return M
