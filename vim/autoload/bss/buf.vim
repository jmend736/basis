function! bss#buf#Create(bufnr = v:none) abort
  return {
        \   'Lines': function('bss#buf#Lines', [a:bufnr]),
        \   'Append': function('bss#buf#Append', [a:bufnr]),
        \   'AppendJson': function('bss#buf#AppendJson', [a:bufnr]),
        \   'Clear': function('bss#buf#Clear', [a:bufnr]),
        \   'Set': function('bss#buf#Set', [a:bufnr]),
        \   'Reset': function('bss#buf#Reset', [a:bufnr]),
        \ }
endfunction

function! bss#buf#Lines(bufnr = v:none) abort
  return getbufline(s:fix_bufnr(a:bufnr), 1, '$')
endfunction

function! bss#buf#Reset(bufnr, text) abort
  call bss#buf#Clear(a:bufnr)
  call bss#buf#Set(a:bufnr, '$', a:text)
endfunction

function! bss#buf#Clear(bufnr = v:none) abort
  call deletebufline(s:fix_bufnr(a:bufnr), 1, '$')
endfunction

function! bss#buf#Set(bufnr, line, text) abort
  call setbufline(s:fix_bufnr(a:bufnr), a:line, s:fix_text(a:text))
endfunction

function! bss#buf#Append(bufnr, text) abort
  call appendbufline(s:fix_bufnr(a:bufnr), '$', s:fix_text(a:text))
endfunction

function! bss#buf#AppendJson(bufnr, data) abort
  call appendbufline(s:fix_bufnr(a:bufnr), '$', json_encode(a:data))
endfunction

" If {bufnr} is v:none, return the current bufnr, otherwise {bufnr}
function! s:fix_bufnr(bufnr) abort
  return (a:bufnr is v:none) ? bufnr() : a:bufnr
endfunction

function! s:fix_text(text) abort
  if type(a:text) is v:t_list || type(a:text) is v:t_string
    return a:text
  else
    return string(a:text)
  endif
endfunction
