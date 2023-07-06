function! bss#ParseClassFile(fname) abort
  return bss#java#classfile#Parse(a:fname)
endfunction

function! bss#Type(Desc) abort
  return bss#type#Type(a:Desc)
endfunction

function! bss#Typed(Desc, value) abort
  return bss#type#Typed(a:Desc, a:value)
endfunction

function! bss#ClassFiles(files) abort
  return bss#java#classfiles#Open(a:files)
endfunction

function! bss#P(fmt, ...) abort
  let l:msg = (type(a:fmt) is v:t_string)
        \ ? call('printf', [a:fmt] + a:000)
        \ : printf("%s", a:fmt)
  echom l:msg
endfunction

function! bss#E(fmt, ...) abort
  let l:msg = (type(a:fmt) is v:t_string)
        \ ? call('printf', [a:fmt] + a:000)
        \ : printf("%s", a:fmt)
  echoerr l:msg
endfunction

function! bss#PP(data) abort
  for l:line in bss#pretty#PPLines(a:data)
    echom l:line
  endfor
endfunction

function! bss#UnicodeGraph(...) abort
  let l:bufnr = bufnr('')
  let l:view = winsaveview()
  let l:lnum = l:view.lnum
  let l:col = l:view.col

  echom l:bufnr l:lnum l:col
endfunction
