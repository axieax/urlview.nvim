local jump = require("urlview.jump")
local utils = require("urlview.utils")
local assert_tbl_same_ordered = require("tests.urlview.helpers").assert_tbl_same_ordered

-- ASSUMPTION(cursor_pos): line numbers are 1-indexed, column numbers are 0-indexed

local active_windows = {}

local function set_cursor(pos)
  vim.api.nvim_win_get_cursor = function()
    return pos
  end
end

local function create_buffer(content, cursor_pos)
  local lines = vim.split(content, "\n")
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  local winnr =
    vim.api.nvim_open_win(bufnr, false, { relative = "editor", row = 0, col = 0, width = 1, height = 1, zindex = 1 })
  active_windows[winnr] = true

  vim.fn.getline = function(line_no)
    return lines[line_no]
  end
  vim.api.nvim_buf_line_count = function()
    return #lines
  end

  utils.fallback(cursor_pos, { 1, 0 })
  set_cursor(cursor_pos)
end

local function teardown_windows()
  local windows = vim.tbl_keys(active_windows)
  for _, winnr in ipairs(windows) do
    if vim.api.nvim_win_is_valid(winnr) then
      vim.api.nvim_win_close(winnr, true)
      active_windows[winnr] = nil
    end
  end
end

local function jump_forwards()
  local res = jump.find_url(0, false)
  if res then
    set_cursor(res)
  end
  return res
end

local function jump_backwards()
  local res = jump.find_url(0, true)
  if res then
    set_cursor(res)
  end
  return res
end

describe("line_match_positions unit tests", function()
  it("multiple substrings", function()
    local line = "abc abc abc"
    local res = jump.line_match_positions(line, "abc", 0)
    assert_tbl_same_ordered({ 1, 5, 9 }, res)
  end)

  it("single URL", function()
    local url = "https://www.google.com"
    local res = jump.line_match_positions(url, url, 0)
    assert_tbl_same_ordered({ 1 }, res) -- TEMP: 1-indexed
  end)
end)

describe("backwards jump", function()
  after_each(teardown_windows)

  it("empty buffer", function()
    local content = ""
    create_buffer(content, { 1, 0 })
    local res = jump_backwards()
    assert.is_nil(res)
  end)

  it("no URL", function()
    local content = "hello"
    create_buffer(content)
    for col = 0, #content do
      set_cursor({ 1, col })
      local res = jump_backwards()
      assert.is_nil(res)
    end
  end)

  it("simple jump start of single line", function()
    local content = "https://www.google.com some random content"
    create_buffer(content)
    for col = 22, #content do
      set_cursor({ 1, col })
      local res = jump_backwards()
      assert_tbl_same_ordered({ 1, 0 }, res)
    end
  end)

  -- it("same line double URL after first without gap", function()
  --   local content = "https://www.google.com https://www.github.com"
  --   local url1_start = 0
  --   local url2_start = 23
  --   create_buffer(content)
  --   for col = url2_start - 1, #content do
  --     set_cursor({ 1, col })
  --     local res = jump_backwards()
  --     assert_tbl_same_ordered({ 1, url1_start }, res)
  --   end
  -- end)
  --
  -- it("same line double URL after first with gap", function()
  --   local content = " https://www.google.com https://www.github.com "
  --   local url1_start = 1
  --   local url2_start = 24
  --   create_buffer(content)
  --   for col = url2_start - 1, #content do
  --     set_cursor({ 1, col })
  --     local res = jump_backwards()
  --     assert_tbl_same_ordered({ 1, url1_start }, res)
  --   end
  -- end)

  -- it("same line one URL on URL", function()
  --   local content = [[https://www.google.com]]
  --   -- multiple starting positions
  -- end)
end)

describe("forwards jump", function()
  after_each(teardown_windows)

  it("empty buffer", function()
    local content = ""
    create_buffer(content, { 1, 0 })
    local res = jump_forwards()
    assert.is_nil(res)
  end)

  it("no URL", function()
    local content = "hello"
    create_buffer(content)
    for col = 0, #content do
      set_cursor({ 1, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)

  it("same line single", function()
    local content = "abc https://www.google.com def"
    local url_start = 4
    create_buffer(content)
    for col = 0, url_start - 1 do
      set_cursor({ 1, col })
      local res = jump_forwards()
      assert_tbl_same_ordered({ 1, url_start }, res)
    end
  end)
end)
