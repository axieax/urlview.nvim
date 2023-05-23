local M = {}

local utils = require("urlview.utils")
local config = require("urlview.config")

--- Validates `value` is of `expected_type` and casts to expected type
---@param value any @value to validate
---@param expected_type string @expected type
local function validate_and_cast_type(value, expected_type)
  if type(value) == expected_type then
    return value
  else
    -- try to convert to expected type
    if expected_type == "number" then
      return tonumber(value)
    elseif expected_type == "boolean" then
      return utils.string_to_boolean(value)
    elseif expected_type == "string" then
      return tostring(value)
    end
  end
end

--- Verifies `opts` if `opts` is provided, otherwise returns all possible accepted options
---@param opts table (map) of user options
---@param accepted_opts table (map) of accepted options
---       (option_key (string) -> { type (string), optional: boolean, default: any })
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
local function verify_or_accept(opts, accepted_opts)
  if not opts then
    -- return valid options if `opts` not provided
    return vim.tbl_keys(accepted_opts)
  end

  -- validate provided options if `opts` provided
  local new_opts = vim.deepcopy(opts)
  for expected_key, expected_v in pairs(accepted_opts) do
    local expected_type = expected_v[1]
    local is_optional = expected_v.optional
    local user_option = opts[expected_key]

    if user_option == nil and not is_optional then
      utils.log(string.format("Missing required option `%s`", expected_key), vim.log.levels.WARN)
    elseif user_option == nil and is_optional then
      if expected_v.default == nil then
        utils.log(
          string.format("Missing default validation field for optional key `%s`", expected_key),
          vim.log.levels.WARN
        )
      end
      new_opts[expected_key] = expected_v.default
    else
      new_opts[expected_key] = validate_and_cast_type(user_option, expected_type)
      if new_opts[expected_key] == nil then
        utils.log(
          string.format("Invalid type for option `%s` (expected: %s)", expected_key, expected_type),
          vim.log.levels.WARN
        )
      end
    end
  end
  return new_opts
end

-- NOTE: validation for `urlview.search.init` functions go below

--- Validation for the "buffer" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.buffer(opts)
  return verify_or_accept(opts, {
    bufnr = { "number", optional = true },
  })
end

--- Validation for the "file" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.file(opts)
  return verify_or_accept(opts, {
    filepath = { "string", optional = false },
  })
end

--- Validation for the "packer" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.packer(opts)
  return verify_or_accept(opts, {
    include_branch = { "boolean", optional = true, default = config.default_include_branch },
  })
end

--- Validation for the "lazy" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.lazy(opts)
  return verify_or_accept(opts, {
    include_branch = { "boolean", optional = true, default = config.default_include_branch },
  })
end

--- Validation for the "vimplug" search context
---@param opts table (map, optional) of user options
---@return table (map) of updated user options if `opts` is provided, otherwise returns all possible accepted options as a table (list)
function M.vimplug(opts)
  return verify_or_accept(opts, {
    include_branch = { "boolean", optional = true, default = config.default_include_branch },
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
