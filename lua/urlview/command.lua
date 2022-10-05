local M = {}

local utils = require("urlview.utils")
local search_contexts = require("urlview.search")
local search_validation = require("urlview.search.validation")

--- Processes arguments provided through the `UrlView` command for `M.search`
local function command_search(res)
  local opts = {}
  local context = res.fargs[1]
  local option_args = vim.list_slice(res.fargs, 2)

  -- process provided options
  for _, arg in ipairs(option_args) do
    local split = vim.split(arg, "=", { plain = true })
    if #split == 1 then
      opts[arg] = true
    elseif #split == 2 then
      local key, value = unpack(split)
      -- remove beginning and trailing quotes from value if present
      local inner = value:match([[^['"](.*)['"]$]])
      if inner ~= nil then
        value = inner
      end
      -- type conversion
      if vim.tbl_contains({ "true", "false" }, value:lower()) then
        value = utils.string_to_boolean(value)
      end
      opts[key] = value
    else
      utils.log("Unable to parse argument " .. arg, vim.log.levels.ERROR)
      return
    end
  end

  require("urlview").search(context, opts)
end

local additional_opts = { "title", "picker", "action", "sorted" }

local function command_completion(_, line)
  local args = vim.split(line, "%s+")
  local nargs = #args - 2
  if nargs == 0 then
    -- search context completion
    local contexts = vim.tbl_keys(search_contexts)
    utils.alphabetical_sort(contexts)
    return contexts
  else
    -- opts completion
    local context = args[2]
    local context_opts = search_validation[context]()
    local accepted_opts = vim.list_extend(context_opts, additional_opts)
    utils.alphabetical_sort(accepted_opts)
    return vim.tbl_map(function(value)
      return value .. "="
    end, accepted_opts)
  end
end

function M.register_command()
  vim.api.nvim_create_user_command("UrlView", command_search, {
    desc = "Find URLs in the current buffer or another search context",
    complete = command_completion,
    nargs = "*",
  })
end

return M
