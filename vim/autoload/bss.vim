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

function! bss#BlazeTargets() abort
  return bss#blaze#BlazeTargets()
endfunction

function! bss#BlazeTarget() abort
  return bss#blaze#BlazeTarget()
endfunction

function! bss#BlazeGuess(...) abort
  return call('bss#blaze#BlazeGuessCommand', a:000)
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

function! bss#PF(data) abort
  return bss#PB(a:data, v:true)
endfunction

function! bss#PN(data) abort
  call bss#nav#Navigate(a:data)
endfunction

function! bss#PA(array, with_methods = v:false) abort
  eval a:array.ToString(v:true)
endfunction

""
" Eg. bss#ThreadedPrint('Hello {} world {}', [1, 2], ['hello', 'world'])
"
function! bss#ThreadedPrint(fmt, ...) abort
  let l:fmt       = a:fmt
  let l:lists     = a:000
  let l:arg_lists = bss#T(l:lists)
  let l:arg_lens  = l:lists->mapnew('bss#MaxStrLen(v:val)')

  for l:len in l:arg_lens
    let l:fmt = substitute(l:fmt, '{\([-]\)\?}', '%\1'..l:len..'s', "")
  endfor

  for l:args in l:arg_lists
    echo call('printf', [l:fmt] + l:args)
  endfor
endfunction

""
" Eg. bss#ThreadedPrint('| {} | {}', {a: b, ...}, ['a', ...])
"
function! bss#ThreadedPrintKeys(fmt, dict, keys) abort
  let l:vals = a:keys->mapnew("a:dict[v:val]")
  call call('bss#ThreadedPrint', [a:fmt, a:keys, l:vals])
endfunction

" Array Functions
" ======================================================================
function! bss#Array(data) abort
  return bss#math#array#Array(a:data)
endfunction

function! bss#Eye(n) abort
  return bss#math#array#Eye(a:n)
endfunction

function! bss#Ones(n) abort
  return bss#math#array#Ones(a:n)
endfunction

function! bss#Zeroes(n) abort
  return bss#math#array#Zeroes(a:n)
endfunction

function! bss#ArrayMap(Fn) abort
  return bss#math#array#Map(a:Fn)
endfunction

function! bss#ArrayMap(dims, Fn) abort
  return bss#math#array#MapIndexed(a:dims, a:Fn)
endfunction

function! bss#M(n, Fn) abort
  return bss#math#array#MapIndexed([a:n, a:n], a:Fn)
endfunction

" List Functions
" ======================================================================

function! bss#First(list) abort
  return get(a:list, 0, v:none)
endfunction

function! bss#Last(list) abort
  return get(a:list, len(a:list)-1, v:none)
endfunction

function! bss#Rest(list) abort
  return empty(a:list) ? [] : a:list[1:len(a:list) - 1]
endfunction

function! bss#Most(list) abort
  return empty(a:list) ? [] : a:list[:len(a:list) - 2]
endfunction

function! bss#MaxLen(list) abort
  return a:list->mapnew('len(v:val)')->max()
endfunction

function! bss#MaxStrLen(list) abort
  let Op = {i, v -> len(type(v) is v:t_string ? v : string(v))}
  return a:list->mapnew(Op)->max()
endfunction

" Functional Programming Helpers
" ======================================================================

""
" Non-modifying Map
function! bss#NMap(list, Func) abort
  return copy(a:list)->map(a:Func)
endfunction

""
" Useful function for using raw-lambdas when chaining
function! bss#Then(v, Fn) abort
  return call(a:Fn, [a:v])
endfunction

function! bss#Apply(v, Fn) abort
  return a:v is v:none ? v:none : call(a:Fn, [a:v])
endfunction

function! bss#Or(v, a) abort
  return a:v is v:none ? a:a : a:v
endfunction

"
" Func(accumulator, delta)
function! bss#Reduce(list, init, Func) abort
  let l:value = a:init
  for l:val in a:list
    let l:value = a:Func(l:value, l:val)
  endfor
  return l:value
endfunction

function! bss#ApplyAll(args, Func_list) abort
  if type(a:Func_list) is v:t_func
    return call(a:Func_list, a:args)
  endif
  return copy(a:Func_list)
        \->map({_, Fn -> call(Fn, a:args)})
endfunction

function! s:ExtendAllImpl(func_list, ...) abort
  let l:self = {}
  for l:Fn in a:func_list
    call extend(l:self, call(l:Fn, [l:self] + a:000))
  endfor
  return l:self
endfunction

function! bss#ExtendAll(func_list) abort
  return function('s:ExtendAllImpl', [a:func_list])
endfunction

" Math helpers
" ======================================================================

function! bss#Sum(list) abort
  return bss#Reduce(a:list, 0, {a, b -> a + b})
endfunction

function! bss#Transpose(A) abort
  if len(a:A) == 0
    return []
  elseif type(a:A[0]) != v:t_list
    return range(len(a:A))->map({i -> [a:A[i]]})
  endif
  return range(len(a:A[0]))->map(
        \   {i -> range(len(a:A))->map(
        \       {j -> a:A[j][i]})})
endfunction

function! bss#T(A) abort
  return bss#Transpose(a:A)
endfunction

function! bss#VecPlus(...) abort
  return call('bss#math#vec#Plus', a:000)
endfunction

function! bss#VecTimes(...) abort
  return call('bss#math#vec#Times', a:000)
endfunction

function! bss#VecDot(...) abort
  return call('bss#math#vec#Dot', a:000)
endfunction

" Exception Handling
" ======================================================================
function! bss#DumpCurrentException() abort
  echom v:exception
  for elem in v:throwpoint->split('\.\.')->reverse()
    echom '  at' elem
  endfor
endfunction

function! bss#Try(Fn, args=[]) abort
  try
    return call(a:Fn, a:args)
  catch /.*/
    echom v:exception
    PP! {get(a:Fn, 'name'): a:Fn}
    for elem in v:throwpoint->split('\.\.')->reverse()
      echom '  at' elem
    endfor
  endtry
endfunction

function! bss#DumpAndThrow(exception) abort
  try
    throw a:exception
  catch /.*/
    call bss#DumpCurrentException()
    throw v:exception
  endtry
  throw 'ERROR(Failure): Failed to throw error?'
endfunction
