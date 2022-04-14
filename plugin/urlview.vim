" Registers the UrlView command with completion

function! s:UrlViewCompletion(argLead, cmdLine, cursorPos)
  let l:head = split(a:cmdLine[:a:cursorPos - 1], ' ', 1)
  let l:nargs = len(l:head) - index(l:head, 'UrlView') - 2

  if l:nargs == 0
    " search context completion
    let l:contexts = luaeval("vim.tbl_keys(require('urlview.search'))")
    let l:contexts = sort(filter(l:contexts, 'v:val !~ "__*"'))
    return join(l:contexts, "\n")
  elseif l:nargs == 1
    " picker completion
    let l:pickers = luaeval("vim.tbl_keys(require('urlview.pickers'))")
    let l:pickers = sort(filter(l:pickers, 'v:val !~ "__*"'))
    return join(l:pickers, "\n")
  else
    " opts completion
    let l:context = l:head[1]
    let l:accepted_opts = luaeval("require('urlview.search.validation')['" . l:context . "']()")
    let l:accepted_opts = map(l:accepted_opts, {_, v -> v:val . '='})
    return join(l:accepted_opts, "\n")
  endif
endfunction

command! -nargs=* -range -complete=custom,s:UrlViewCompletion UrlView lua require("urlview").command_search(<f-args>)
