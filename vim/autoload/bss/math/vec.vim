" Functions for operating on lists of numbers as Vectors

function! bss#math#vec#Ops() abort
  return {
        \   'Plus': function('bss#math#vec#Plus'),
        \   'Times': function('bss#math#vec#Times'),
        \   'Dot': function('bss#math#vec#Dot'),
        \ }
endfunction

function! bss#math#vec#Plus(...) abort
  return bss#Transpose(a:000)
        \->map({i, x -> reduce(x, {a, b -> a + b}, 0)})
endfunction

function! bss#math#vec#Times(a, b) abort
  let [l:c, l:v] = (type(a:a) is v:t_number || type(a:a is v:t_float))
        \ ? [a:a, a:b] : [a:b, a:a]
  return copy(l:v)
        \->map({_, x -> l:c * x})
endfunction

function! bss#math#vec#Dot(a, b) abort
  return bss#Transpose([a:a, a:b])
        \->map({_, x -> x[0] * x[1]})
        \->reduce({a, x -> a + x}, 0)
endfunction
