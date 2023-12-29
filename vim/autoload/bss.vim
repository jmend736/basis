" Entrypoints to Features
" ======================================================================
function! bss#ParseClassFile(fname) abort
  return bss#java#classfile#Parse(a:fname)
endfunction

function! bss#Type(Desc) abort
  return bss#type#Type(a:Desc)
endfunction

function! bss#Typed(Desc, value) abort
  return bss#type#Typed(a:Desc, a:value)
endfunction

function! bss#Query(data, ...) abort
  return bss#data#LQuery(a:data, a:000)
endfunction

function! bss#LQuery(data, path) abort
  return bss#data#LQuery(a:data, a:path)
endfunction

function! bss#ClassFiles(files) abort
  return bss#java#classfiles#Open(a:files)
endfunction

" Generic Getters/Setters
" ======================================================================
function! bss#Get(data, index, default = v:none) abort
  if a:data is v:none
    return v:none
  endif
  return get(a:data, a:index, a:default)
endfunction

function! bss#SetDefault(data, index, Default = { -> v:none }) abort
  let l:result = bss#Get(a:data, a:index)
  if l:result isnot v:none
    return l:result
  endif
  let a:data[a:index] = a:Default()
  return bss#Get(a:data, a:index)
endfunction

" Printing Functions
" ======================================================================
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

function! bss#PL(mutline_str) abort
  for l:line in split(a:mutline_str, "\n")
    echom l:line
  endfor
endfunction

function! bss#PP(data, with_methods = v:false) abort
  for l:line in bss#pretty#PPLines(a:data, a:with_methods)
    echom l:line
  endfor
endfunction

function! bss#PB(data, with_methods = v:false) abort
  return bss#view#DataView(a:data, a:with_methods)
        \.GoToWindow()
endfunction

function! bss#PN(data) abort
  call bss#nav#Navigate(a:data)
endfunction

function! bss#PA(array, with_methods = v:false) abort
  eval a:array.ToString(v:true)
endfunction

" Array Functions
" ======================================================================
function! bss#Array(data) abort
  return bss#array#Array(a:data)
endfunction

function! bss#Eye(n) abort
  return bss#array#Eye(a:n)
endfunction

function! bss#Ones(n) abort
  return bss#array#Ones(a:n)
endfunction

function! bss#Zeroes(n) abort
  return bss#array#Zeroes(a:n)
endfunction

function! bss#ArrayMap(Fn) abort
  return bss#array#Map(a:Fn)
endfunction

function! bss#ArrayMap(dims, Fn) abort
  return bss#array#MapIndexed(a:dims, a:Fn)
endfunction

function! bss#M(n, Fn) abort
  return bss#array#MapIndexed([a:n, a:n], a:Fn)
endfunction

" Functional Programming Helpers
" ======================================================================

""
" Useful function for using raw-lambdas when chaining
function! bss#Then(v, Fn) abort
  return call(a:Fn, [a:v])
endfunction
