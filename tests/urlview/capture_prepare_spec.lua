local urlview = require("urlview")
local config = require("urlview.config")
local search = require("urlview.search")
local assert_tbl_same_any_order = require("tests.urlview.helpers").assert_tbl_same_any_order
local extract_links_from_content = require("urlview.search.helpers").content
local prepare_links = require("urlview.utils").prepare_links

describe("HTTP(s) protocol", function()
  local default_prefix = "https://"
  before_each(function()
    urlview.setup({
      default_prefix = default_prefix,
    })
  end)

  after_each(function()
    config._reset_defaults()
  end)

  it("link with http protocol", function()
    local url = "http://example.com"
    local links = extract_links_from_content(url)
    local prepared_links = prepare_links(links)
    assert.same({ url }, prepared_links)
  end)

  it("link with https protocol", function()
    local url = "https://example.com"
    local links = extract_links_from_content(url)
    local prepared_links = prepare_links(links)
    assert.same({ url }, prepared_links)
  end)

  it("link missing either protocol", function()
    local url = "www.example.com"
    local links = extract_links_from_content(url)
    local prepared_links = prepare_links(links)
    assert.same({ default_prefix .. url }, prepared_links)
  end)
end)

describe("unique links", function()
  before_each(function()
    urlview.setup({
      default_prefix = "",
      custom_searches = {
        test = {
          capture = "%d",
          format = "%s",
        },
      },
    })
    assert.is_not.Nil(search.test)
  end)

  after_each(function()
    search.test = nil
    config._reset_defaults()
  end)

  local content = "1 1 2 2 3 3 4 4 5 5"

  it("keep duplicates", function()
    config.unique = false

    local links = search.test({ content = content })
    local prepared_links = prepare_links(links)
    assert_tbl_same_any_order({ "1", "1", "2", "2", "3", "3", "4", "4", "5", "5" }, prepared_links)
  end)

  it("filter duplicates", function()
    config.unique = true

    local links = search.test({ content = content })
    local prepared_links = prepare_links(links)
    assert.same({ "1", "2", "3", "4", "5" }, prepared_links)
  end)
end)

describe("sorted links", function()
  local default_prefix = "https://"
  before_each(function()
    urlview.setup({
      default_prefix = default_prefix,
    })
  end)

  after_each(function()
    config._reset_defaults()
  end)

  it("full urls sorted alphabetically", function()
    local content = [[
    www.google.com
    https://google.com
    https://github.com/axieax/urlview.nvim
    www.example.com
    http://github.com/helloM
    http://github.com/helloP
    http://github.com/hellon
    ]]

    local links = extract_links_from_content(content)
    local prepared_links = prepare_links(links)
    local expected = {
      "http://github.com/helloM",
      "http://github.com/hellon",
      "http://github.com/helloP",
      "https://github.com/axieax/urlview.nvim",
      "https://google.com",
      default_prefix .. "www.example.com",
      default_prefix .. "www.google.com",
    }

    assert.same(expected, prepared_links)
  end)

  it("urls missing protocol fixed and sorted alphabetically", function() end)
end)
