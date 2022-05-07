local urlview = require("urlview")
local config = require("urlview.config")
local search = require("urlview.search")

describe("mock vim.ui.select", function()
  local default_prefix = "test-"
  before_each(function()
    urlview.setup({
      default_prefix = default_prefix,
      custom_searches = {
        test = {
          capture = "%w+",
          format = "%s",
        },
      },
    })
    assert.is.Not.Nil(search.test)
  end)

  after_each(function()
    search.test = nil
    config._reset_defaults()
  end)

  local original_ui_select = vim.ui.select

  it("unique, sorted", function()
    config.unique = true
    config.sorted = true

    local content = "pears watermelon banana apple apple peach apricot watermelon"
    local expected = vim.tbl_map(function(v)
      return default_prefix .. v
    end, { "apple", "apricot", "banana", "peach", "pears", "watermelon" })

    vim.ui.select = function(items, ...)
      assert.are.same(expected, items)
    end

    urlview.search("test", { content = content })
    vim.ui.select = original_ui_select
  end)
end)

describe("mock telescope", function() end)
