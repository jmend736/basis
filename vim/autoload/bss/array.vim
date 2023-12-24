" N-Dimensional Array API
" ======================================================================
"
" Makes the tradeoff where it has a lot of convenience functions on the array
" objects themselves, but this means that with every operation, all of these
" are copied.
"
" I might consider taking this in a different direction, for example:
"
" 1.  Making the array objects mutable and all operations mutations
" 2.  Making the mathematical operations options, with an `WithOps()` method
"     which imbues the array object with the mathematical operations.
"
" Classes:
" ----------------------------------------------------------------------
"
"   bss#array#Array({data})
"   :   Defines an array with an n-dimensional list as input {data}
"
" Fields:
"
"   data  : An n-dimensional list-of-lists.
"   shape : Shape of the list of lists.

let s:Array = {
      \   'shape':   v:t_list,
      \   'data':    v:t_list,
      \ }

function! bss#array#Array(data) abort
  return copy(s:Array)->extend({
        \   'shape': s:CalculateShape(a:data),
        \   'data': a:data
        \ })
endfunction

function! bss#array#Eye(n) abort
  return bss#array#MapIndexed([a:n, a:n], {i, j -> (i == j) ? 1 : 0})
endfunction

function! bss#array#Zeroes(n) abort
  return bss#array#MapIndexed([a:n, a:n], { -> 0 })
endfunction

function! bss#array#Ones(n) abort
  return bss#array#MapIndexed([a:n, a:n], { -> 1 })
endfunction

function! bss#array#MapIndexed(dims, Fn = { -> 0}) abort
  return bss#array#Array(s:NDimMapIndexed(a:dims, a:Fn))
endfunction

function! s:Array.At(...) abort dict
  if type(a:1) isnot v:t_list
    return self.At(a:000)
  endif
  let l:ptr = self.data
  for l:idx in a:1
    let l:ptr = l:ptr[l:idx]
  endfor
  return l:ptr
endfunction

function! s:Array.MapIndexed(Fn) abort dict
  return bss#array#MapIndexed(self.shape, a:Fn)
endfunction

function! s:Array.Map(Fn) abort dict
  let l:Fn = function(a:Fn)
  return bss#array#MapIndexed(self.shape, { -> l:Fn(self.At(a:000)) })
endfunction

function! s:Array.Plus(obj) abort dict
  return s:Broadcast({a, b -> a + b}, self, a:obj)
endfunction

function! s:Array.Times(obj) abort dict
  return s:Broadcast({a, b -> a * b}, self, a:obj)
endfunction

function! s:Array.Abs() abort dict
  return self.Map(function('abs'))
endfunction

function! s:Array.Round() abort dict
  return self.Map(function('round'))
endfunction

function! s:Array.Ceil() abort dict
  return self.Map(function('ceil'))
endfunction

function! s:Array.Floor() abort dict
  return self.Map(function('floor'))
endfunction

function! s:Array.Trunc() abort dict
  return self.Map(function('trunc'))
endfunction

function! s:Array.Exp() abort dict
  return self.Map(function('exp'))
endfunction

function! s:Array.Log() abort dict
  return self.Map(function('log'))
endfunction

function! s:Array.Log10() abort dict
  return self.Map(function('log10'))
endfunction

function! s:Array.Pow(e) abort dict
  return self.Map({b -> pow(b, a:e)})
endfunction

function! s:Array.Sqrt() abort dict
  return self.Map(function('sqrt'))
endfunction

function! s:Array.Sin() abort dict
  return self.Map(function('sin'))
endfunction

function! s:Array.Cos() abort dict
  return self.Map(function('cos'))
endfunction

function! s:Array.Tan() abort dict
  return self.Map(function('tan'))
endfunction

function! s:Array.Asin() abort dict
  return self.Map(function('asin'))
endfunction

function! s:Array.Acos() abort dict
  return self.Map(function('acos'))
endfunction

function! s:Array.Atan() abort dict
  return self.Map(function('atan'))
endfunction

function! s:Array.Sinh() abort dict
  return self.Map(function('sinh'))
endfunction

function! s:Array.Cosh() abort dict
  return self.Map(function('cosh'))
endfunction

function! s:Array.Tanh() abort dict
  return self.Map(function('tanh'))
endfunction

function! s:Array.Isinf() abort dict
  return self.Map(function('isinf'))
endfunction

function! s:Array.Isnan() abort dict
  return self.Map(function('isnan'))
endfunction

" Helper Functions
" ======================================================================

function! s:IsArray(obj) abort
  return (type(a:obj) == v:t_dict) && (keys(a:obj)->s:ContainsAll(['data', 'shape']))
endfunction

function! s:ContainsAll(list, elems) abort
  let l:contained = v:true
  for l:elem in a:elems
    let l:contained = l:contained && (index(a:list, l:elem) != -1)
  endfor
  return l:contained
endfunction

""
" Decorate binary function {Fn} to make it broadcastable:
" - If two Array{}s of the same shape are passed, then operate element-wise
" - If an array and a scalar ar passed, then apply across the array
"
function! s:Broadcast(Fn, A, B) abort
  if s:IsArray(a:B)
    if (a:B.shape != a:A.shape)
      throw 'ERROR(BadValue): Attempted to operate on shape ' .. a:A.shape .. ' with shape ' .. a:B.shape
    endif
    return bss#array#Map(a:A.shape, { ... -> a:Fn(a:A.At(a:000), a:B.At(a:000)) })
  elseif type(a:B) is v:t_number
    return bss#array#Map(a:A.shape, { ... -> a:Fn(a:A.At(a:000), a:B) })
  endif
  throw 'ERROR(BadValue): Invalid type of argument: ' .. a:B
endfunction


""
" Calculates the shape of an n-dim list of lists.
"
" @param {data} a list of lists
" @returns a list of integers specifying the sizes of each dimension
" @throws 'ERROR(BadValue)' if {data} is of the wrong type or sizes do
"   not align across dimensions.
function! s:CalculateShape(data) abort
  " Calculate dims by traversing first children
  let l:shape = a:data->s:CalculateShape_FirstElemShape()
  eval a:data->s:CalculateShape_Verify(l:shape)
  return l:shape
endfunction

""
" Verify Shape
function! s:CalculateShape_Verify(data, shape) abort
  if type(a:data) isnot v:t_list
    if len(a:shape) != 0
      throw 'ERROR(BadValue): Expected shape ' .. string(a:shape) .. ' but got value: ' .. string(a:data)
    endif
    return
  endif

  if len(a:data) == a:shape[0]
    for l:subdata in a:data
      eval s:CalculateShape_Verify(l:subdata, a:shape[1:])
    endfor
  endif
endfunction

""
" Calculate shape by traversing only the first elements
function! s:CalculateShape_FirstElemShape(data) abort
  if type(a:data) isnot v:t_list
    return []
  elseif len(a:data) == 0
    return [0]
  endif
  return [len(a:data)] + s:CalculateShape_FirstElemShape(a:data[0])
endfunction

function! s:NDimMapIndexed(dims, Fn, idx=[]) abort
  if len(a:dims) == 0
    return call(a:Fn, a:idx)
  else
    return map(range(a:dims[0]), 's:NDimMapIndexed(a:dims[1:], a:Fn, a:idx + [v:key])')
  endif
endfunction
