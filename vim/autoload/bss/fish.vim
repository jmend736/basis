" :h complete-functions
"
" eg. `set completefunc=bss#fish#CompleteFunc`
function! bss#fish#CompleteFunc(findstart, base) abort
  if a:findstart
    return strridx(getline('.'), ' ') + 1
  endif
  return bss#fish#Complete(join([getline('.'), a:base])->shellescape())
endfunction

" :h :command-completion-custom
" :h :command-completion-customlist
"
" eg. `command! -complete=customlist,bss#fish#CompleteCustomList ...`
" eg. `command! -complete=customlist,<SID>Fn ...`
function! bss#fish#CompleteCustomList(arg_lead, cmd_line, cursor_pos) abort
  return bss#fish#Complete(a:cmd_line->substitute('\w\+\s\?', '', ''))
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
