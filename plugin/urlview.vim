" Registers the UrlView command with completion

function! s:UrlViewCompletion(argLead, cmdLine, cursorPos)
  let l:head = split(a:cmdLine[:a:cursorPos - 1], ' ', 1)
  let l:nargs = len(l:head) - index(l:head, 'UrlView') - 2

  let l:result = []
  if l:nargs == 0
    " search context completion
    let l:contexts = luaeval("vim.tbl_keys(require('urlview.search'))")
    let l:result = filter(l:contexts, 'v:val !~ "__*"')
  else
    " opts completion
    let l:context = l:head[1]
    let l:accepted_opts = luaeval("require('urlview.search.validation')['" . l:context . "']()")
    let l:accepted_opts = l:accepted_opts + ['title', 'picker']
    let l:result = map(l:accepted_opts, {_, v -> v:val . '='})
  endif
  return join(sort(l:result), "\n")
endfunction

command! -nargs=* -range -complete=custom,s:UrlViewCompletion UrlView lua require("urlview").command_search(<f-args>)
