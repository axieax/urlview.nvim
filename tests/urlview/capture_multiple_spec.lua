describe("multiple captures", function()
	local extract_urls = require("urlview").extract_urls
	local result_contains = require("tests.urlview.helpers").result_contains

	it("separate lines", function()
		local content = [[
			http://google.com
			https://www.google.com
		]]
		local result = extract_urls(content)

		assert.are.equal(2, #result)
		assert.truthy(result_contains(result, {
			url = "google.com",
			prefix = "http://",
		}))
		assert.truthy(result_contains(result, {
			url = "www.google.com",
			prefix = "https://",
		}))
	end)

	it("same line", function()
		local content = "http://google.com https://www.github.com"
		local result = extract_urls(content)

		assert.are.equal(2, #result)
		assert.truthy(result_contains(result, {
			url = "google.com",
			prefix = "http://",
		}))
		assert.truthy(result_contains(result, {
			url = "www.github.com",
			prefix = "https://",
		}))
	end)
end)

describe("unique captures", function()
	local extract_urls = require("urlview").extract_urls
	local result_contains = require("tests.urlview.helpers").result_contains

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
		assert.truthy(result_contains(result, {
			url = "www.google.com/search?q=vim",
			prefix = "https://",
		}))
		assert.truthy(result_contains(result, {
			url = "www.google.com/search?q=nvim",
			prefix = "https://",
		}))
	end)
end)
