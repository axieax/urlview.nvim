local search = require("urlview.search")
local search_helpers = require("urlview.search.helpers")
local assert_tbl_same_any_order = require("tests.urlview.helpers").assert_tbl_same_any_order

describe("custom Jira searcher (template table)", function()
  before_each(function()
    search.jira = search_helpers.generate_custom_search({
      capture = "AXIE%-%d+",
      format = "https://jira.axieax.com/browse/%s",
    })
    assert.is_not.Nil(search.jira)
  end)

  after_each(function()
    search.jira = nil
  end)

  it("capture single", function()
    local content = "AXIE-1"
    local links = search.jira({ content = content })
    assert_tbl_same_any_order({
      "https://jira.axieax.com/browse/AXIE-1",
    }, links)
  end)

  it("capture multiple", function()
    local content = [[
      AXIE-1
      AXIE-12
      AXIE-123
      AXIE-1234
      AXIE-12345
      AXIE-123456
      AXIE-1234567
      AXIE-12345678
      AXIE-123456789
      AXIE-1234567890
    ]]
    local links = search.jira({ content = content })
    assert_tbl_same_any_order({
      "https://jira.axieax.com/browse/AXIE-1",
      "https://jira.axieax.com/browse/AXIE-12",
      "https://jira.axieax.com/browse/AXIE-123",
      "https://jira.axieax.com/browse/AXIE-1234",
      "https://jira.axieax.com/browse/AXIE-12345",
      "https://jira.axieax.com/browse/AXIE-123456",
      "https://jira.axieax.com/browse/AXIE-1234567",
      "https://jira.axieax.com/browse/AXIE-12345678",
      "https://jira.axieax.com/browse/AXIE-123456789",
      "https://jira.axieax.com/browse/AXIE-1234567890",
    }, links)
  end)

  it("invalid captures ignored", function()
    local content = [[
    AXIE
    AXIE1
    AXIE--123
    AXIE%-1
    AXIE-!
    AXIE-AXIE
    AXIE-ax
    ]]
    local links = search.jira({ content = content })
    assert_tbl_same_any_order({}, links)
  end)
end)

describe("overwrite default searcher", function()
  local builtin_search_buffer = search.buffer

  before_each(function()
    search.buffer = search_helpers.generate_custom_search({
      capture = "l.ve",
      format = "i-%s-testing",
    })
  end)

  after_each(function()
    search.buffer = builtin_search_buffer
  end)

  it("capture single", function()
    local content = "i love testing"
    local result = search.buffer({ content = content })
    assert_tbl_same_any_order({
      "i-love-testing",
    }, result)
  end)

  it("capture multiple", function()
    local content = "I live to see another day, I love Neovim"
    local result = search.buffer({ content = content })
    assert_tbl_same_any_order({
      "i-love-testing",
      "i-live-testing",
    }, result)
  end)
end)

describe("custom function", function()
  before_each(function()
    search.test = function(opts)
      return { opts.a or "default", opts.b or "default", opts.c or "default" }
    end
  end)

  after_each(function()
    search.test = nil
  end)

  it("capture one", function()
    local result = search.test({ a = "a" })
    assert_tbl_same_any_order({ "a", "default", "default" }, result)
  end)

  it("capture two", function()
    local result = search.test({ a = "a", c = "c" })
    assert_tbl_same_any_order({ "a", "c", "default" }, result)
  end)

  it("capture three", function()
    local result = search.test({ a = "a", b = "b", c = "c" })
    assert_tbl_same_any_order({ "a", "b", "c" }, result)
  end)

  it("ignore extra", function()
    local result = search.test({ a = "a", b = "b", c = "c", d = "d" })
    assert_tbl_same_any_order({ "a", "b", "c" }, result)
  end)
end)

describe("register custom search", function()
  it("captures git uris", function()
    search.git = search_helpers.generate_custom_search({
      capture = "git@[^%s]+%.git",
    })

    local content = [[
      git@github.com:axieax/urlview.nvim.git
      git@github.com:axieax/typo.nvim.git
    ]]

    local links = search.git({ content = content })
    assert_tbl_same_any_order({
      "git@github.com:axieax/urlview.nvim.git",
      "git@github.com:axieax/typo.nvim.git",
    }, links)
    search.git = nil
  end)

  it("captures ssh uris iwthout the prefix", function()
    search.ssh = search_helpers.generate_custom_search({
      capture = "ssh://([^%s]+)",
    })

    local content = [[
      ssh://git@github.com:axieax/urlview.nvim.git
      ssh://git@github.com:axieax/typo.nvim.git
      ssh://192.168.1.1
      ssh://192.168.1.1:4000
    ]]

    local links = search.ssh({ content = content })
    assert_tbl_same_any_order({
      "git@github.com:axieax/urlview.nvim.git",
      "git@github.com:axieax/typo.nvim.git",
      "192.168.1.1",
      "192.168.1.1:4000",
    }, links)
    search.ssh = nil
  end)

  it("captures ftp uris", function()
    search.ftp = search_helpers.generate_custom_search({
      capture = "ftp://[^%s]+",
    })

    local content = [[
      ftp://ftp.example.com
      ftp://user@host/%2Ffoo/bar.txt
      ftp://user:password@server/pathname;type=a
    ]]

    local links = search.ftp({ content = content })
    assert_tbl_same_any_order({
      "ftp://ftp.example.com",
      "ftp://user@host/%2Ffoo/bar.txt",
      "ftp://user:password@server/pathname;type=a",
    }, links)
    search.ftp = nil
  end)
end)
