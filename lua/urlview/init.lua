local M = {}

local config = require("urlview.config")
local utils = require("urlview.utils")
local search = require("urlview.search")
local search_helpers = require("urlview.search.helpers")
local pickers = require("urlview.pickers")

--- Searchs the provided context for links
---@param ctx string where to search
---@param picker string (optional)
function M.search(ctx, picker, opts)
  picker = utils.fallback(picker, config.default_picker)
  opts = utils.fallback(opts, {})
  ctx = utils.fallback(ctx, opts.ctx) or "buffer"

  -- extract links from ctx
  local links = search[ctx](opts)
  if links then
    if vim.tbl_isempty(links) then
      utils.log("No links found in context " .. ctx)
    else
      return pickers[picker](links, opts)
    end
  end
end

--- Custom setup function
--- Not required to be called unless user wants to modify the default config
---@param user_config table (optional)
function M.setup(user_config)
  user_config = utils.fallback(user_config, {})
  local raw_config = rawget(config, "_options")
  local new_config = vim.tbl_deep_extend("force", raw_config, user_config)
  rawset(config, "_options", new_config)

  -- Register custom searches
  search_helpers.register_custom_searches(config.custom_searches)
end

return M
