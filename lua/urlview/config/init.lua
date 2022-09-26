local M = {
  _options = {},
}

return setmetatable(M, {
  -- general get and set operations refer to the internal table `_options`
  __index = function(_, k)
    return M._options[k]
  end,
  __newindex = function(_, k, v)
    M._options[k] = v
  end,
})
