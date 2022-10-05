local M = {}

local extract_links_from_content = require("urlview.search.helpers").content

function M.assert_no_match(content)
  local result = extract_links_from_content(content)
  assert.equals(0, #result)
end

function M.assert_single_match(url, expected_url)
  local result = extract_links_from_content(url)
  assert.same({ expected_url }, result)
end

function M.assert_tbl_same_any_order(expected, actual)
  assert.same(#expected, #actual)
  for _, e in ipairs(expected) do
    assert.truthy(vim.tbl_contains(actual, e))
  end
end

return M
