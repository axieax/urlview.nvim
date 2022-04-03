local urlview = require("urlview")
local config = require("urlview.config")
local assert_tbl_same_any_order = require("tests.urlview.helpers").assert_tbl_same_any_order
local extract_links_from_content = require("urlview.search.helpers").content

describe("multiple captures", function()
  it("separate lines", function()
    local content = [[
      http://google.com
      https://www.google.com
    ]]
    local result = extract_links_from_content(content)
    assert_tbl_same_any_order({ "http://google.com", "https://www.google.com" }, result)
  end)

  it("same line", function()
    local content = "http://google.com https://www.github.com"
    local result = extract_links_from_content(content)
    assert_tbl_same_any_order({ "http://google.com", "https://www.github.com" }, result)
  end)
end)

describe("unique captures", function()
  it("same link", function()
    local content = [[
      http://google.com
      http://google.com
    ]]
    local result = extract_links_from_content(content)
    assert_tbl_same_any_order({ "http://google.com" }, result)
  end)

  it("different prefix / uri protocol, same default prefix", function()
    urlview.setup({
      default_prefix = "https://",
    })

    local content = [[
      https://www.google.com
      www.google.com
    ]]
    local result = extract_links_from_content(content)
    assert_tbl_same_any_order({ "https://www.google.com" }, result)

    config._reset_config()
  end)

  it("different prefix / uri protocol, prefer specified", function()
    urlview.setup({
      default_prefix = "http://",
    })

    local content = [[
      https://www.google.com
      www.google.com
    ]]
    local result = extract_links_from_content(content)
    assert_tbl_same_any_order({ "https://www.google.com" }, result)

    config._reset_config()
  end)

  it("different paths", function()
    local content = [[
      https://www.google.com/search?q=vim
      https://www.google.com/search?q=nvim
    ]]
    local result = extract_links_from_content(content)
    assert_tbl_same_any_order({ "https://www.google.com/search?q=vim", "https://www.google.com/search?q=nvim" }, result)
  end)
end)
