local M = {}

-- NOTE: line numbers are 1-indexed, column numbers are 0-indexed

local utils = require("urlview.utils")
local search_helpers = require("urlview.search.helpers")

local END_COL = -1

--- Return the starting positions of `match` in `line`
---@param line string
---@param match string
---@param offset number @added to each position
---@return table (list) of offsetted starting indicies
function M.line_match_positions(line, match, offset)
  local res = {}
  local init = 1
  while init <= #line do
    local start, finish = line:find(match, init, true)
    if start == nil then
      return res
    end

    table.insert(res, start + offset - 1)
    init = finish
  end

  return res
end

--- Returns a starting column position not on a URL
---@param line_start number @line number at cursor
---@param col_start number @column number at cursor
---@param reversed boolean @direction
---@return number @corrected starting column
function M.correct_start_col(line_start, col_start, reversed)
  local full_line = vim.fn.getline(line_start)
  local matches = search_helpers.content(full_line)
  for _, match in ipairs(matches) do
    local positions = M.line_match_positions(full_line, match, 0)
    for _, position in ipairs(positions) do
      local url_end = position + #match
      local on_url = col_start >= position and col_start < url_end
      -- edge case for going backwards with cursor at start of URL
      if on_url and reversed and position == col_start then
        return math.max(col_start - 1, 0)
      -- generally if on a URL, move column to be after the URL
      elseif on_url then
        return url_end
      end
    end
  end
  return col_start
end

local reversed_sort_function_lookup = {
  -- reversed == true: descending sort
  [true] = function(a, b)
    return a > b
  end,
  -- reversed == false: ascending sort
  [false] = function(a, b)
    return a < b
  end,
}

--- Finds the position of the previous / next URL
---@param winnr number @id of current window
---@param reversed boolean @direction false for forward, true for backwards
---@return table|nil @position
function M.find_url(winnr, reversed)
  local line_no, col_no = unpack(vim.api.nvim_win_get_cursor(winnr))
  local total_lines = vim.api.nvim_buf_line_count(0)
  col_no = M.correct_start_col(line_no, col_no, reversed)

  local sort_function = reversed_sort_function_lookup[reversed]
  local line_last = utils.ternary(reversed, 0, total_lines + 1)
  while line_no ~= line_last do
    local full_line = vim.fn.getline(line_no)
    col_no = utils.ternary(col_no == END_COL, #full_line, col_no)
    local line = utils.ternary(reversed, full_line:sub(1, col_no), full_line:sub(col_no + 1))
    local matches = search_helpers.content(line)

    if not vim.tbl_isempty(matches) then
      -- sorted table(list) of starting column numbers for URLs in line
      -- normal order: ascending, reversed order: descending
      local indices = {}
      for _, match in ipairs(matches) do
        local offset = utils.ternary(reversed, 0, col_no)
        vim.list_extend(indices, M.line_match_positions(line, match, offset))
      end
      table.sort(indices, sort_function)
      -- find first valid (before or after current column)
      for _, index in ipairs(indices) do
        local valid = utils.ternary(reversed, index <= col_no, index >= col_no)
        if valid then
          return { line_no, index }
        end
      end
    end

    line_no = utils.ternary(reversed, line_no - 1, line_no + 1)
    col_no = utils.ternary(reversed, END_COL, 0)
  end
end

--- Forward / backward jump generator
---@param reversed boolean @direction false for forward, true for backwards
---@return function @when called, jumps to the URL in the given direction
local function goto_url(reversed)
  return function()
    local direction = utils.ternary(reversed, "previous", "next")
    local winnr = vim.api.nvim_get_current_win()
    local pos = M.find_url(winnr, reversed)
    if not pos then
      utils.log(string.format("Cannot find any %s URLs in buffer", direction), vim.log.levels.INFO)
      return
    end

    if vim.api.nvim_win_is_valid(winnr) then
      vim.cmd("normal! m'") -- add to jump list
      vim.api.nvim_win_set_cursor(winnr, pos)
    else
      utils.log(
        string.format("The %s URL was found in window number %s, which is no longer valid", direction, winnr),
        vim.log.levels.WARN
      )
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
    utils.log(
      "Invalid type for option `jump` (expected: table with `prev` and `next` key mappings)",
      vim.log.levels.WARN
    )
  else
    if jump_opts.prev ~= "" then
      vim.keymap.set("n", jump_opts.prev, function()
        require("urlview.jump").prev_url()
      end, { desc = "Previous URL" })
    end
    if jump_opts.next ~= "" then
      vim.keymap.set("n", jump_opts.next, function()
        require("urlview.jump").next_url()
      end, { desc = "Next URL" })
    end
  end
end

return M
