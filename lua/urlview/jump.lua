local M = {}

-- NOTE: line numbers are 0-indexed, column numbers are 1-indexed

local utils = require("urlview.utils")
local search_helpers = require("urlview.search.helpers")

local END_COL = -1

local function line_match_positions(line, match, offset)
  local start, _ = line:find(vim.pesc(match))
  if start == nil then
    return {}
  end

  local index = start + offset
  local new_offset = index + #match
  return vim.list_extend({ index }, line_match_positions(line:sub(new_offset), match, new_offset))
end

local function correct_start_col(line_start, col_start, reversed)
  local full_line = vim.fn.getline(line_start)
  local matches = search_helpers.content(full_line)
  for _, match in ipairs(matches) do
    local positions = line_match_positions(full_line, match, 0)
    for _, position in ipairs(positions) do
      -- if on a URL, move starting col to after the url
      if col_start >= position and col_start < position + #match then
        return utils.ternary(reversed, position - 1, position + #match)
      end
    end
  end
  return col_start
end

--- Forward / backward jump generator
---@param reversed boolean @direction false for forward, true for backwards
---@return function @when called, jumps to the URL in the given direction
local function goto_url(reversed)
  local sort_function = utils.ternary(reversed, function(a, b)
    return a > b
  end, function(a, b)
    return a < b
  end)

  return function()
    local line_no = vim.fn.line(".")
    local col_no = vim.fn.col(".")
    local total_lines = vim.api.nvim_buf_line_count(0)
    col_no = correct_start_col(line_no, col_no, reversed)

    local line_last = utils.ternary(reversed, 0, total_lines)
    while line_no ~= line_last do
      local full_line = vim.fn.getline(line_no)
      col_no = utils.ternary(col_no == END_COL, #full_line, col_no)
      local line = utils.ternary(reversed, full_line:sub(1, col_no), full_line:sub(col_no))
      local matches = search_helpers.content(line)

      if not vim.tbl_isempty(matches) then
        -- sorted table(list) of starting column numbers for URLs in line
        -- normal order: ascending, reversed order: descending
        local indices = {}
        for _, match in ipairs(matches) do
          local offset = utils.ternary(reversed, 0, col_no - 1)
          vim.list_extend(indices, line_match_positions(line, match, offset))
        end
        table.sort(indices, sort_function)
        -- find first valid (before or after current column)
        for _, index in ipairs(indices) do
          local valid = utils.ternary(reversed, index < col_no, index > col_no)
          if valid then
            -- add to jump list
            vim.cmd("normal! m'")
            -- NOTE: it seems nvim_win_set_cursor takes a 0-indexed column number
            local pos = { line_no, index - 1 }
            vim.api.nvim_win_set_cursor(0, pos)
            return
          end
        end
      end

      line_no = utils.ternary(reversed, line_no - 1, line_no + 1)
      col_no = utils.ternary(reversed, END_COL, 1)
    end
  end
end

--- Jump to the next URL
M.next_url = goto_url(false)

--- Jump to the previous URL
M.prev_url = goto_url(true)

--- Register URL jump mappings
---@param jump_opts table
function M.register_mappings(jump_opts)
  if type(jump_opts) ~= "table" then
    utils.log("Invalid type for option `jump` (expected: table with prev_url and next_url keys)")
  else
    utils.keymap(
      "n",
      jump_opts.prev,
      [[<Cmd>lua require("urlview.jump").prev_url()<CR>]],
      { desc = "Previous URL", noremap = true }
    )
    utils.keymap(
      "n",
      jump_opts.next,
      [[<Cmd>lua require("urlview.jump").next_url()<CR>]],
      { desc = "Next URL", noremap = true }
    )
  end
end

return M
