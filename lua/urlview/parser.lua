local M = {}

local utils = require("urlview.utils")
local ns = vim.api.nvim_create_namespace("urlview_ns")

function M.parse()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, query = pcall(require, "nvim-treesitter.query")
  if not ok then
    utils.log("nvim-treesitter not installed", vim.log.levels.ERROR)
    return
  end

  local matches = query.get_capture_matches(bufnr, "@spell", "highlights")
  for _, match in pairs(matches) do
    local node = match.node
    local content = vim.treesitter.get_node_text(node, bufnr)
    local start_row, start_col, end_row, _ = vim.treesitter.get_node_range(node)
    local urls = require("urlview.search.helpers").content(content)
    for _, url in pairs(urls) do
      local offset = string.find(content, url, 1, true)
      local new_start_col = start_col + offset - 1
      local new_end_col = new_start_col + #url
      vim.highlight.range(
        bufnr,
        ns,
        "@text.uri",
        { start_row, new_start_col },
        { end_row, new_end_col },
        { priority = 10000 }
      )
    end
  end
end

return M
