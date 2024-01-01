" N-Dimensional Array API
" ======================================================================
"
" This is not practical to use for anything, I've chosen to use less code
" rather than more performant code.
"
" Mostly, I wanted to implement the tabular printing of a matrix.
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

function! bss#array#Array(data, base=v:none) abort
  return copy((a:base is v:none) ? s:Array : a:base)->extend({
        \   'shape': s:CalculateShape(a:data),
        \   'data': a:data
        \ })
endfunction

function! bss#array#Eye(n) abort
  return bss#array#MapIndexed([a:n, a:n], {i, j -> (i == j)})
endfunction

function! bss#array#Zeroes(n) abort
  return bss#array#MapIndexed([a:n, a:n], { -> 0 })
endfunction

function! bss#array#Ones(n) abort
  return bss#array#MapIndexed([a:n, a:n], { -> 1 })
endfunction

function! bss#array#Range(n) abort
  return bss#array#Array(range(a:n))
endfunction

function! bss#array#Range2D(n) abort
  return bss#array#MapIndexed([a:n, a:n], {i, j -> a:n*i + j })
endfunction

function! bss#array#MapIndexed(dims, Fn = { -> 0}, base=s:Array) abort
  return bss#array#Array(s:NDimMapIndexed(a:dims, a:Fn), a:base)
endfunction

function! s:Array.Get(...) abort dict
  if a:0 == 0
    return self
  elseif type(a:1) isnot v:t_list
    return s:ArrayGetImpl(self.data, a:000)
  else
    return s:ArrayGetImpl(self.data, a:1)
  endif
endfunction

function! s:Array.At(...) abort dict
  return bss#array#Array(self.Get(a:000), self)
endfunction

function! s:Array.MapAt(Fn, ...) abort dict
  return bss#array#Array(map(self.Get(a:000), {k, v -> call(a:Fn, [v])}), self)
endfunction

function! s:Array.MapIndexed(Fn) abort dict
  return bss#array#Array(s:NDimMapIndexed(self.shape, a:Fn), self)
endfunction

function! s:Array.Map(Fn) abort dict
  return self.MapIndexed({ ... -> call(a:Fn, [self.Get(a:000)]) })
endfunction

function! s:Array.T() abort dict
  let l:SwapDims = {l -> l[-1:] + l[1:-2] + l[:0]}
  return bss#array#MapIndexed(
        \ l:SwapDims(self.shape),
        \ {... -> self.Get(l:SwapDims(a:000))},
        \ self)
endfunction

function! s:Array.WithOps() abort dict
  return extend(self, s:ArrayOps)
endfunction

function! s:Array.ToString(dump = v:false) abort dict
  let l:str =  s:ArrayToStringImpl(self)
  if !a:dump
    return l:str
  else
    eval bss#PL(l:str)
  endif
endfunction

let s:ArrayOps = {}

function! s:ArrayOps.Plus(obj) abort dict
  return s:Broadcast({a, b -> a + b}, self, a:obj)
endfunction

function! s:ArrayOps.Times(obj) abort dict
  return s:Broadcast({a, b -> a * b}, self, a:obj)
endfunction

function! s:ArrayOps.Abs() abort dict
  return self.Map('abs')
endfunction

function! s:ArrayOps.Round() abort dict
  return self.Map('round')
endfunction

function! s:ArrayOps.Ceil() abort dict
  return self.Map('ceil')
endfunction

function! s:ArrayOps.Floor() abort dict
  return self.Map('floor')
endfunction

function! s:ArrayOps.Trunc() abort dict
  return self.Map('trunc')
endfunction

function! s:ArrayOps.Exp() abort dict
  return self.Map('exp')
endfunction

function! s:ArrayOps.Log() abort dict
  return self.Map('log')
endfunction

function! s:ArrayOps.Log10() abort dict
  return self.Map('log10')
endfunction

function! s:ArrayOps.Pow(e) abort dict
  return self.Map({b -> pow(b, a:e)})
endfunction

function! s:ArrayOps.Sqrt() abort dict
  return self.Map('sqrt')
endfunction

function! s:ArrayOps.Sin() abort dict
  return self.Map('sin')
endfunction

function! s:ArrayOps.Cos() abort dict
  return self.Map('cos')
endfunction

function! s:ArrayOps.Tan() abort dict
  return self.Map('tan')
endfunction

function! s:ArrayOps.Asin() abort dict
  return self.Map('asin')
endfunction

function! s:ArrayOps.Acos() abort dict
  return self.Map('acos')
endfunction

function! s:ArrayOps.Atan() abort dict
  return self.Map('atan')
endfunction

function! s:ArrayOps.Sinh() abort dict
  return self.Map('sinh')
endfunction

function! s:ArrayOps.Cosh() abort dict
  return self.Map('cosh')
endfunction

function! s:ArrayOps.Tanh() abort dict
  return self.Map('tanh')
endfunction

function! s:ArrayOps.Isinf() abort dict
  return self.Map('isinf')
endfunction

function! s:ArrayOps.Isnan() abort dict
  return self.Map('isnan')
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
    return bss#array#MapIndexed(a:A.shape, { ... -> a:Fn(a:A.Get(a:000), a:B.Get(a:000)) }, a:A)
  elseif type(a:B) is v:t_number
    return bss#array#MapIndexed(a:A.shape, { ... -> a:Fn(a:A.Get(a:000), a:B) }, a:A)
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

function! s:ArrayGetImpl(data, index) abort
  let l:ptr = a:data
  for l:i in range(len(a:index))
    let l:idx = a:index[l:i]
    if type(l:idx) is v:t_number
      let l:ptr = l:ptr[l:idx]
    elseif l:idx =~# '\v(all|All)'
      return map(l:ptr, {k, v -> s:ArrayGetImpl(v, a:index[l:i+1:])})
    else
      throw 'ERROR(BadValue): Invalid index: ' .. string(l:idx)
    endif
  endfor
  return l:ptr
endfunction

function! s:ArrayToStringImpl(A) abort
  if len(a:A.shape) < 2
    return string(a:A.data)
  elseif len(a:A.shape) == 2
    let l:widths = a:A.T()
          \.Map({v -> len(string(v))})
          \.MapAt({v -> max(v)}, 'All')
          \.WithOps().Plus(1)
    let l:widths.data[0] -= 1
    return a:A.MapIndexed({i, j -> printf('%'..l:widths.Get(j)..'s', string(a:A.Get([i, j])))})
          \.MapAt({v -> '['..join(v, ',')..']'}, 'All')
          \.data
          \->bss#Then({v -> '['..join(v, ",\n ")..']'})
  else
    throw 'ERROR(BadValue): Invalid Dimensions (too many?) ' .. string(a:A.shape)
  endif
endfunction
