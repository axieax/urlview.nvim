describe("multiple captures", function()
	local extract_urls = require("urlview").extract_urls
	local tbl_contains = require("tests.urlview.helpers").tbl_contains

	it("separate lines", function()
		local url = [[
			http://google.com
			https://www.google.com
		]]
		local result = extract_urls(url)

		assert.are.equal(2, #result)
		assert.truthy(tbl_contains(result, {
			url = "google.com",
			prefix = "http://",
		}))
		assert.truthy(tbl_contains(result, {
			url = "www.google.com",
			prefix = "https://",
		}))
	end)

	-- TODO: same line (or)
end)

describe("unique captures", function()
	local extract_urls = require("urlview").extract_urls
	local tbl_contains = require("tests.helpers").tbl_contains

	it("same link", function()
		local content = [[
			http://google.com
			http://google.com
		]]
		local result = extract_urls(content)

		assert.same({ { url = "google.com", prefix = "http://" } }, result)
	end)

	it("different prefix / uri protocol", function()
		local content = [[
			https://www.google.com
			www.google.com
		]]
		local result = extract_urls(content)

		assert.same({ { url = "www.google.com", prefix = "https://" } }, result)
	end)

	it("different paths", function()
		local content = [[
			https://www.google.com/search?q=vim
			https://www.google.com/search?q=nvim
		]]
		local result = extract_urls(content)

		assert.are.equal(2, #result)
		assert.truthy(tbl_contains(result, {
			url = "www.google.com/search?q=vim",
			prefix = "https://",
		}))
		assert.truthy(tbl_contains(result, {
			url = "www.google.com/search?q=nvim",
			prefix = "https://",
		}))
	end)
end)
