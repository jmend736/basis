function! bss#fish#Complete(findstart, base) abort
  if a:findstart
    return strridx(getline('.'), ' ') + 1
  endif
  let l:shell = &shell
  let &shell = exepath('fish')
  try
    let l:line = printf('%s %s', getline('.'), a:base)
    return systemlist(printf(
          \ 'complete -C %s',
          \ shellescape(l:line)))
          \->map({_, v -> v[:stridx(v, "\t")]})
          \->map({_, v -> trim(v, "\t")})
  finally
    let &shell = l:shell
  endtry
endfunction
