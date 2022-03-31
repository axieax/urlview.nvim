" Registers the UrlView command
function! s:UrlViewCompletion(...)
  let l:pickers = luaeval("vim.tbl_keys(require('urlview.search'))")
  let l:pickers = sort(filter(l:pickers, 'v:val !~ "content" && v:val !~ "__*"'))
  return join(l:pickers, "\n")
endfunction

command! -nargs=? -complete=custom,s:UrlViewCompletion UrlView lua require("urlview").search(<f-args>)
