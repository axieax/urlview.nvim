local M = {}

-- NOTE: line numbers are 0-indexed, column numbers are 1-indexed
-- BUG: prev_url jumps to end of url
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

local function find_url(reversed)
  local line_no = vim.fn.line(".")
  local col_no = vim.fn.col(".")
  local total_lines = vim.api.nvim_buf_line_count(0)
  col_no = correct_start_col(line_no, col_no, reversed)

  local line_last = utils.ternary(reversed, 0, total_lines)
  while line_no ~= line_last do
    local full_line = vim.fn.getline(line_no)
    col_no = utils.ternary(col_no == END_COL, #full_line, col_no)
    local line = utils.ternary(reversed, full_line:sub(1, col_no), full_line:sub(col_no))
    print(line_no, col_no)
    local matches = search_helpers.content(line)

    if not vim.tbl_isempty(matches) then
      -- sorted table(list) of starting column numbers for URLs in line
      -- normal order: ascending, reversed order: descending
      local indices = {}
      for _, match in ipairs(matches) do
        vim.list_extend(indices, line_match_positions(line, match, col_no - 1))
      end
      table.sort(indices, function(a, b)
        return utils.ternary(reversed, a > b, a < b)
      end)
      -- find first valid (before or after current column)
      for _, index in ipairs(indices) do
        local valid = utils.ternary(reversed, index < col_no, index > col_no)
        if valid then
          -- NOTE: nvim_win_set_cursor takes a 0-indexed column number
          return { line_no, index - 1 }
        end
      end
    end

    line_no = utils.ternary(reversed, line_no - 1, line_no + 1)
    col_no = utils.ternary(reversed, END_COL, 1)
  end
end

function M.next_url()
  local pos = find_url(false)
  vim.pretty_print(pos)
  if pos then
    vim.api.nvim_win_set_cursor(0, pos)
  end
end

function M.prev_url()
  local pos = find_url(true)
  vim.pretty_print(pos)
  if pos then
    vim.api.nvim_win_set_cursor(0, pos)
  end
end

return M
