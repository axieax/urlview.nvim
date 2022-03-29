local M = {}

local extract_urls = require("urlview.utils").extract_urls

function M.assert_no_match(content)
	local result = extract_urls(content)
	assert.equal(0, #result)
end

function M.assert_single_match(url)
	local result = extract_urls(url)
	assert.same({ url }, result)
end

function M.assert_tbl_same_any_order(expected, actual)
	assert.same(#expected, #actual)
	for _, e in ipairs(expected) do
		assert.truthy(vim.tbl_contains(actual, e))
	end
end

return M
