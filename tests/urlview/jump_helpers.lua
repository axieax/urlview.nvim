local M = {}

local jump = require("urlview.jump")
local utils = require("urlview.utils")

local active_windows = {}

function M.set_cursor(pos)
  vim.api.nvim_win_get_cursor = function()
    return pos
  end
end

function M.create_buffer(content, cursor_pos)
  local lines = vim.split(content, "\n")
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  local winnr = vim.api.nvim_open_win(bufnr, false, {
    relative = "editor",
    row = 0,
    col = 0,
    width = 1,
    height = 1,
    zindex = 1,
  })
  active_windows[winnr] = true

  vim.fn.getline = function(line_no)
    return lines[line_no]
  end
  vim.api.nvim_buf_line_count = function()
    return #lines
  end

  utils.fallback(cursor_pos, { 1, 0 })
  M.set_cursor(cursor_pos)
end

function M.teardown_windows()
  local windows = vim.tbl_keys(active_windows)
  for _, winnr in ipairs(windows) do
    if vim.api.nvim_win_is_valid(winnr) then
      vim.api.nvim_win_close(winnr, true)
      active_windows[winnr] = nil
    end
  end
end

function M.jump_forwards()
  local res = jump.find_url(0, false)
  if res then
    M.set_cursor(res)
  end
  return res
end

function M.jump_backwards()
  local res = jump.find_url(0, true)
  if res then
    M.set_cursor(res)
  end
  return res
end

return M
