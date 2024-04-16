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
  return bss#fish#SystemList(shellescape(a:command))
          \->map('substitute(v:val, "\t.*$", "", "")')
endfunction

" bss#fish#SystemList('ls ~')
" :   systemlist(...)
"
" bss#fish#SystemList(['ls', '~'])
" :   systemlist(join(...))
"
" bss#fish#SystemList('ls %s', 'a')
" :   systemlist(printf(...))
function! bss#fish#SystemList(...) abort
  if a:0 == 0
    throw 'ERROR(InvalidArguments): bss#fish#SystemList() needs arguments'
  elseif a:0 == 1 && type(a:1) is v:t_list
    return bss#fish#SystemList(join(a:1))
  elseif a:0 >= 2 && type(a:1) is v:t_string
    return bss#fish#SystemList(call('printf', a:000))
  elseif a:0 == 1 && type(a:1) is v:t_string
    let l:shell = &shell
    try
      let &shell = exepath('fish')
      return systemlist(a:1)
    finally
      let &shell = l:shell
    endtry
  endif
endfunction
