local urlview = require("urlview")
local search = require("urlview.search")
local assert_tbl_same_any_order = require("tests.urlview.helpers").assert_tbl_same_any_order

describe("custom Jira searcher", function()
	before_each(function()
		urlview.setup({
			custom_searches = {
				jira = {
					capture = "AXIE%-%d+",
					format = "https://jira.axieax.com/browse/%s",
				},
			},
		})
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
		urlview.setup({
			custom_searches = {
				buffer = {
					capture = "l.ve",
					format = "i-%s-testing",
				},
			},
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
