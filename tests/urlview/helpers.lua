local M = {}

local function contains_common_key(a, b, key)
	return a[key] ~= nil and a[key] == b[key]
end

function M.result_contains(result, tbl)
	for _, v in pairs(result) do
		if contains_common_key(v, tbl, "url") and contains_common_key(v, tbl, "prefix") then
			return true
		end
	end
	return false
end

return M
