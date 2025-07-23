local urlview = require("urlview")
local actions = require("urlview.actions")
local stub = require("luassert.stub")
local netrw_action = require("urlview.actions").netrw

describe("M.netrw fallback when netrw is disabled", function()
  before_each(function()
    -- disable netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "Here is a link: https://example.com",
    })
    urlview.setup({})
  end)

  it("calls the system fallback", function()
    stub(actions, "system")

    netrw_action("https://example.com")

    assert.stub(actions.system).was.called_with("https://example.com")
  end)
end)
