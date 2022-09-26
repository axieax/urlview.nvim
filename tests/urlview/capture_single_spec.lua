local urlview = require("urlview")
local reset_config = require("urlview.config.helpers").reset_defaults
local assert_no_match = require("tests.urlview.helpers").assert_no_match
local assert_single_match = require("tests.urlview.helpers").assert_single_match

describe("no capture", function()
  it("empty string", function()
    assert_no_match("")
  end)

  it("random", function()
    assert_no_match("asdfwiueyfksdlckvj")
  end)

  it("com only", function()
    assert_no_match("test.com")
  end)

  it("com path", function()
    assert_no_match("test.com/idk")
  end)
end)

describe("url-only simple capture", function()
  local default_prefix = "https://"
  before_each(function()
    urlview.setup({
      default_prefix = default_prefix,
    })
  end)

  after_each(function()
    reset_config()
  end)

  it("http capture", function()
    local url = "http://google.com"
    assert_single_match(url, url)
  end)

  it("https capture", function()
    local url = "https://google.com"
    assert_single_match(url, url)
  end)

  it("www capture", function()
    local url = "www.google.com"
    assert_single_match(url, url)
  end)

  it("http www capture", function()
    local url = "http://www.google.com"
    assert_single_match(url, url)
  end)

  it("https www capture", function()
    local url = "https://www.google.com"
    assert_single_match(url, url)
  end)

  it("trailing slash", function()
    local url = "www.google.com/"
    assert_single_match(url, url)
  end)
end)

describe("url-only path capture", function()
  local default_prefix = "http://"
  before_each(function()
    urlview.setup({
      default_prefix = default_prefix,
    })
  end)

  after_each(function()
    reset_config()
  end)

  it("lol php capture", function()
    local url = "https://who.even.uses/index.php"
    assert_single_match(url, url)
  end)

  it("https path capture", function()
    local url = "https://google.com/path/to/idk"
    assert_single_match(url, url)
  end)

  it("www path capture", function()
    local url = "www.google.com/path/to/idk"
    assert_single_match(url, url)
  end)

  it("url-encoded path query capture", function()
    local url = "www.google.com/P%40%2Bh%20t35T%2F/1dk%3F?q=%3Da%25%3B"
    assert_single_match(url, url)
  end)

  it("query capture", function()
    local url = "https://example.com/path/to/idk?q=axie&ax"
    assert_single_match(url, url)
  end)
end)
