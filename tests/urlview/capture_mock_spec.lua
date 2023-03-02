local urlview = require("urlview")
local reset_config = require("urlview.config.helpers").reset_defaults
local search = require("urlview.search")
local search_helpers = require("urlview.search.helpers")

describe("mock vim.ui.select", function()
  local default_prefix = "test-"
  before_each(function()
    urlview.setup({ default_prefix = default_prefix })
    search.test = search_helpers.generate_custom_search({
      capture = "%w+",
      format = "%s",
    })
    assert.is_not.Nil(search.test)
  end)

  after_each(function()
    search.test = nil
    reset_config()
  end)

  local original_ui_select = vim.ui.select

  it("unique, sorted", function()
    local content = "pears watermelon banana apple apple peach apricot watermelon"
    local expected = vim.tbl_map(function(v)
      return default_prefix .. v
    end, { "apple", "apricot", "banana", "peach", "pears", "watermelon" })

    vim.ui.select = function(items)
      assert.same(expected, items)
    end

    urlview.search("test", { content = content, unique = true, sorted = true })
    vim.ui.select = original_ui_select
  end)
end)

describe("mock telescope", function() end)
