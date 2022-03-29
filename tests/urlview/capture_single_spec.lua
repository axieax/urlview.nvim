describe("url-only simple capture", function()
	local extract_urls = require("urlview").extract_urls

	it("http capture", function()
		local url = "http://google.com"
		local result = extract_urls(url)
		assert.same({ { url = "google.com", prefix = "http://" } }, result)
	end)

	it("https capture", function()
		local url = "https://google.com"
		local result = extract_urls(url)
		assert.same({ { url = "google.com", prefix = "https://" } }, result)
	end)

	it("www capture", function()
		local url = "www.google.com"
		local result = extract_urls(url)
		assert.same({ { url = url, prefix = "" } }, result)
	end)

	it("http www capture", function()
		local url = "http://www.google.com"
		local result = extract_urls(url)
		assert.same({ { url = "www.google.com", prefix = "http://" } }, result)
	end)

	it("https www capture", function()
		local url = "https://www.google.com"
		local result = extract_urls(url)
		assert.same({ { url = "www.google.com", prefix = "https://" } }, result)
	end)

	it("trailing slash", function()
		local url = "www.google.com/"
		local result = extract_urls(url)
		assert.same({ { url = url, prefix = "" } }, result)
	end)
end)

describe("url-only path capture", function()
	local extract_urls = require("urlview").extract_urls

	it("lol php capture", function()
		local url = "https://who.even.uses/index.php"
		local result = extract_urls(url)
		assert.same({ { url = "who.even.uses/index.php", prefix = "https://" } }, result)
	end)

	it("https path capture", function()
		local url = "https://google.com/path/to/idk.html"
		local result = extract_urls(url)
		assert.same({ { url = "google.com/path/to/idk.html", prefix = "https://" } }, result)
	end)

	it("www path capture", function()
		local url = "www.google.com/path/to/idk"
		local result = extract_urls(url)
		assert.same({ { url = url, prefix = "" } }, result)
	end)

	it("url-encoded path query capture", function()
		local url = "www.google.com/P%40%2Bh%20t35T%2F/1dk%3F?q=%3Da%25%3B"
		local result = extract_urls(url)
		assert.same({ { url = url, prefix = "" } }, result)
	end)
end)
