local jump = require("urlview.jump")
local assert_tbl_same_ordered = require("tests.urlview.helpers").assert_tbl_same_ordered

local jump_helpers = require("tests.urlview.jump_helpers")
local set_cursor = jump_helpers.set_cursor
local create_buffer = jump_helpers.create_buffer
local teardown_windows = jump_helpers.teardown_windows
local jump_forwards = jump_helpers.jump_forwards
local jump_backwards = jump_helpers.jump_backwards

-- ASSUMPTION(cursor_pos): line numbers are 1-indexed, column numbers are 0-indexed

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

  it("on last URL + no more", function()
    local content = "abc https://www.google.com def"
    local url_start = 4
    create_buffer(content)
    for col = url_start, #content do
      set_cursor({ 1, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)

  it("multiline jump from anywhere in line", function()
    local content = [[
https://www.google.com
https://www.github.com
https://www.amazon.com
https://www.reddit.com]]
    local url_length = #"https://www.google.com"
    create_buffer(content)
    -- jumps to next line
    for line = 1, 3 do
      for col = 0, url_length do
        set_cursor({ line, col })
        local res = jump_forwards()
        assert_tbl_same_ordered({ line + 1, 0 }, res)
      end
    end
    -- last line
    for col = 0, url_length do
      set_cursor({ 4, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)
end)
