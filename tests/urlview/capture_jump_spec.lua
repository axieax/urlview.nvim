local jump = require("urlview.jump")
local jump_helpers = require("tests.urlview.jump_helpers")
local set_cursor = jump_helpers.set_cursor
local create_buffer = jump_helpers.create_buffer
local teardown_windows = jump_helpers.teardown_windows
local jump_forwards = jump_helpers.jump_forwards
local jump_backwards = jump_helpers.jump_backwards

-- ASSUMPTION(cursor_pos): line numbers are 1-indexed, column numbers are 0-indexed

local examples = {
  empty = "",
  invalid = "hello",
  single_line_middle = "abc https://www.google.com def",
  standard_url = "https://www.google.com",
  multi_line_just_links = [[
https://www.google.com
https://www.github.com
https://www.amazon.com
https://www.reddit.com]],
  multi_line_sandwich = [[

https://www.google.com
]],
}

describe("line_match_positions unit tests", function()
  it("multiple substrings", function()
    local line = "abc abc abc"
    local expected_no_offset = { 0, 4, 8 }
    for offset = 0, 100 do
      local res = jump.line_match_positions(line, "abc", offset)
      local expected = vim.tbl_map(function(x)
        return x + offset
      end, expected_no_offset)
      vim.deep_equal(expected, res)
    end
  end)

  it("single URL", function()
    local url = examples.standard_url
    local res = jump.line_match_positions(url, url, 0)
    vim.deep_equal({ 0 }, res)
  end)

  it("correct single index", function()
    local url = examples.standard_url
    local line = examples.single_line_middle
    local res = jump.line_match_positions(line, url, 0)
    vim.deep_equal({ 4 }, res)
  end)
end)

describe("correct starting column", function()
  it("backwards no URL", function()
    local line = examples.invalid
    create_buffer(line)
    for col = 0, #line do
      local new_col = jump.correct_start_col(1, col, true)
      assert.equals(col, new_col)
    end
  end)

  it("backwards before URL", function()
    local line = examples.single_line_middle
    create_buffer(line)
    local url_start = 4
    for col = 0, url_start - 1 do
      local new_col = jump.correct_start_col(1, col, true)
      assert.equals(col, new_col)
    end
  end)

  it("backwards on start of URL", function()
    local line = examples.single_line_middle
    local url_start = 4
    create_buffer(line)
    local new_col = jump.correct_start_col(1, url_start, true)
    assert.equals(url_start - 1, new_col)
  end)

  it("backwards on rest of URL", function()
    local line = examples.single_line_middle
    create_buffer(line)
    local url_start = 4
    local url_end = url_start + #examples.standard_url
    for col = url_start + 1, url_end - 1 do
      local new_col = jump.correct_start_col(1, col, true)
      assert.equals(url_end, new_col)
    end
  end)

  it("backwards after URL", function()
    local line = examples.single_line_middle
    local url_start = 4
    local url_end = url_start + #examples.standard_url
    for col = url_end, #line do
      local new_col = jump.correct_start_col(1, col, true)
      assert.equals(col, new_col)
    end
  end)

  it("forwards no URL", function()
    local line = examples.invalid
    create_buffer(line)
    for col = 0, #line do
      local new_col = jump.correct_start_col(1, col, false)
      assert.equals(col, new_col)
    end
  end)

  it("forwards before URL", function()
    local line = examples.single_line_middle
    create_buffer(line)
    local url_start = 4
    for col = 0, url_start - 1 do
      local new_col = jump.correct_start_col(1, col, false)
      assert.equals(col, new_col)
    end
  end)

  it("forwards on URL", function()
    local line = examples.single_line_middle
    create_buffer(line)
    local url_start = 4
    local url_end = url_start + #examples.standard_url
    for col = url_start, url_end - 1 do
      local new_col = jump.correct_start_col(1, col, false)
      assert.equals(url_end, new_col)
    end
  end)

  it("forwards after URL", function()
    local line = examples.single_line_middle
    local url_start = 4
    local url_end = url_start + #examples.standard_url
    for col = url_end, #line do
      local new_col = jump.correct_start_col(1, col, false)
      assert.equals(col, new_col)
    end
  end)
end)

describe("backwards jump", function()
  after_each(teardown_windows)

  it("empty buffer", function()
    local content = examples.empty
    create_buffer(content, { 1, 0 })
    local res = jump_backwards()
    assert.is_nil(res)
  end)

  it("no URL", function()
    local content = examples.invalid
    create_buffer(content)
    for col = 0, #content do
      set_cursor({ 1, col })
      local res = jump_backwards()
      assert.is_nil(res)
    end
  end)

  it("just URL", function()
    local content = examples.standard_url
    create_buffer(content, { 1, 0 })
    local res = jump_backwards()
    assert.is_nil(res)

    for col = 1, #content do
      set_cursor({ 1, col })
      res = jump_backwards()
      vim.deep_equal({ 1, 0 }, res)
    end
  end)

  it("invalid jump before URL and start of URL", function()
    local content = examples.single_line_middle
    local url_start = 4
    create_buffer(content)
    for col = 0, url_start do
      set_cursor({ 1, col })
      local res = jump_backwards()
      assert.is_nil(res)
    end
  end)

  it("simple jump to start of URL", function()
    local content = examples.single_line_middle
    local url_start = 4
    create_buffer(content)
    for col = url_start + 1, #content do
      set_cursor({ 1, col })
      local res = jump_backwards()
      vim.deep_equal({ 1, url_start }, res)
    end
  end)

  it("multiline jump from anywhere in line", function()
    local content = examples.multi_line_just_links
    local url_length = #examples.standard_url
    create_buffer(content)

    -- invalid jump
    set_cursor({ 1, 0 })
    local res = jump_backwards()
    assert.is_nil(res)

    -- jump to start of previous URL
    local line_last = 4
    for line = 1, line_last do
      local expected = { line, 0 }
      for col = 1, url_length do
        set_cursor({ line, col })
        res = jump_backwards()
        vim.deep_equal(expected, res)
      end
      if line ~= line_last then
        set_cursor({ line + 1, 0 })
        vim.deep_equal(expected, res)
      end
    end
  end)

  it("multiline sandwich", function()
    local content = examples.multi_line_sandwich
    local url_length = #examples.standard_url
    create_buffer(content)

    -- invalid jumps
    for line = 1, 2 do
      set_cursor({ line, 0 })
      local res = jump_backwards()
      assert.is_nil(res)
    end

    -- jumps to correct position
    local expected = { 2, 0 }
    for col = 1, url_length do
      set_cursor({ 2, col })
      local res = jump_backwards()
      vim.deep_equal(expected, res)
    end

    -- line 3 jumps to line 2
    set_cursor({ 3, 0 })
    local res = jump_backwards()
    vim.deep_equal(expected, res)
  end)

  it("jump chain", function()
    local content = examples.multi_line_just_links
    local url_length = #examples.standard_url
    create_buffer(content, { 4, url_length })

    for line = 4, 1, -1 do
      local res = jump_backwards()
      vim.deep_equal({ line, 0 }, res)
    end

    local res = jump_backwards()
    assert.is_nil(res)
  end)
end)

describe("forwards jump", function()
  after_each(teardown_windows)

  it("empty buffer", function()
    local content = examples.empty
    create_buffer(content, { 1, 0 })
    local res = jump_forwards()
    assert.is_nil(res)
  end)

  it("no URL", function()
    local content = examples.invalid
    create_buffer(content)
    for col = 0, #content do
      set_cursor({ 1, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)

  it("just URL", function()
    local content = examples.standard_url
    create_buffer(content)
    for col = 0, #content do
      set_cursor({ 1, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)

  it("same line single", function()
    local content = examples.single_line_middle
    local url_start = 4
    create_buffer(content)
    for col = 0, url_start - 1 do
      set_cursor({ 1, col })
      local res = jump_forwards()
      vim.deep_equal({ 1, url_start }, res)
    end
  end)

  it("on last URL + no more", function()
    local content = examples.single_line_middle
    local url_start = 4
    create_buffer(content)
    for col = url_start, #content do
      set_cursor({ 1, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)

  it("multiline jump from anywhere in line", function()
    local content = examples.multi_line_just_links
    local url_length = #examples.standard_url
    create_buffer(content)
    -- jumps to next line
    for line = 1, 3 do
      for col = 0, url_length do
        set_cursor({ line, col })
        local res = jump_forwards()
        vim.deep_equal({ line + 1, 0 }, res)
      end
    end
    -- last line
    for col = 0, url_length do
      set_cursor({ 4, col })
      local res = jump_forwards()
      assert.is_nil(res)
    end
  end)

  it("multiline sandwich", function()
    local content = examples.multi_line_sandwich
    local url_length = #examples.standard_url
    create_buffer(content, { 1, 0 })

    -- line 1 jumps to line 2
    local res = jump_forwards()
    vim.deep_equal({ 2, 0 }, res)

    -- line 2 onwards invalid
    for col = 0, url_length do
      set_cursor({ 2, col })
      res = jump_forwards()
      assert.is_nil(res)
    end
    set_cursor({ 3, 0 })
    res = jump_forwards()
    assert.is_nil(res)
  end)

  it("jump chain", function()
    local content = examples.multi_line_just_links
    create_buffer(content, { 1, 0 })

    for line = 1, 3 do
      local res = jump_forwards()
      vim.deep_equal({ line + 1, 0 }, res)
    end

    local res = jump_forwards()
    assert.is_nil(res)
  end)
end)
