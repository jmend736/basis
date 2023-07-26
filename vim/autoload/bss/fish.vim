" :h complete-functions
function! bss#fish#CompleteFunc(findstart, base) abort
  if a:findstart
    return strridx(getline('.'), ' ') + 1
  endif
  return bss#fish#Complete(join([getline('.'), a:base])->shellescape())
endfunction

function! bss#fish#Complete(command) abort
  let l:shell = &shell
  try
    let &shell = exepath('fish')
    let l:cmd = printf(
          \ 'complete -C %s',
          \  shellescape(a:command))
    return systemlist(l:cmd)
          \->map('substitute(v:val, "\t.*$", "", "")')
  finally
    let &shell = l:shell
  endtry
endfunction
