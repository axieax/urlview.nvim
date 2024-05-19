local M = {}

local utils = require("urlview.utils")
local config = require("urlview.config")

--- Validates `opts` and sets default values if `opts` is provided, otherwise returns all possible accepted options
---@param opts table (map) of user options
---@param rules table (map) of vim.validate rules (with an optional fourth tuple member for default value)
---       (option_key (string) -> { type (string), optional: boolean, default: any })
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
local function verify_or_accept(opts, rules)
  if not opts then
    -- return valid options if `opts` not provided
    return vim.tbl_keys(rules)
  end

  local new_opts = vim.deepcopy(opts)
  for key, value in pairs(rules) do
    if #value == 4 and value[3] and opts[key] == nil then
      local default = value[4]
      new_opts[key] = default
      rules[key][1] = default
    end
  end

  vim.validate(rules)
  return new_opts
end

-- NOTE: validation for `urlview.search.init` functions go below

--- Validation for the "buffer" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.buffer(opts)
  return verify_or_accept(opts, {
    bufnr = { opts.bufnr, "number", true, 0 },
  })
end

--- Validation for the "file" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.file(opts)
  return verify_or_accept(opts, {
    filepath = { opts.filepath, "string", false },
  })
end

--- Validation for the "packer" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.packer(opts)
  return verify_or_accept(opts, {
    include_branch = { opts.include_branch, "boolean", true, config.default_include_branch },
  })
end

--- Validation for the "lazy" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.lazy(opts)
  return verify_or_accept(opts, {
    include_branch = { opts.include_branch, "boolean", true, config.default_include_branch },
  })
end

--- Validation for the "vimplug" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.vimplug(opts)
  return verify_or_accept(opts, {
    include_branch = { opts.include_branch, "boolean", true, config.default_include_branch },
  })
end

return setmetatable(M, {
  __index = function(_, _)
    return function(opts)
      -- if `opts` provided, return `opts`, otherwise return all possible accepted options
      return utils.fallback(opts, {})
    end
  end,
})
