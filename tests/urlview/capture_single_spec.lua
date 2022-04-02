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
  it("http capture", function()
    assert_single_match("http://google.com")
  end)

  it("https capture", function()
    assert_single_match("https://google.com")
  end)

  it("www capture", function()
    assert_single_match("www.google.com")
  end)

  it("http www capture", function()
    assert_single_match("http://www.google.com")
  end)

  it("https www capture", function()
    assert_single_match("https://www.google.com")
  end)

  it("trailing slash", function()
    assert_single_match("www.google.com/")
  end)
end)

describe("url-only path capture", function()
  it("lol php capture", function()
    assert_single_match("https://who.even.uses/index.php")
  end)

  it("https path capture", function()
    assert_single_match("https://google.com/path/to/idk")
  end)

  it("www path capture", function()
    assert_single_match("www.google.com/path/to/idk")
  end)

  it("url-encoded path query capture", function()
    assert_single_match("www.google.com/P%40%2Bh%20t35T%2F/1dk%3F?q=%3Da%25%3B")
  end)

  it("query capture", function()
    assert_single_match("https://example.com/path/to/idk?q=axie&ax")
  end)
end)
