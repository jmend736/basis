" :h complete-functions
function! bss#fish#Complete(findstart, base) abort
  if a:findstart
    return strridx(getline('.'), ' ') + 1
  endif
  let l:shell = &shell
  try
    let &shell = exepath('fish')
    let l:cmd = printf(
          \ 'complete -C %s',
          \  join([getline('.'), a:base])->shellescape())
    return systemlist(l:cmd)
          \->map('substitute(v, "\t.*$", "")')
  finally
    let &shell = l:shell
  endtry
endfunction
