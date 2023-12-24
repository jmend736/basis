" Top-level API
" ======================================================================
"
" Classes:
" ----------------------------------------------------------------------
"
"   bss#array#Array({data})
"   : Defines an array with an n-dimensional list as input {data}
"
" Fields:
"
"   data  : An n-dimensional list-of-lists.
"   shape : Defines stuff

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
  return bss#array#Map([a:n, a:n], {i, j -> (i == j) ? 1 : 0})
endfunction

function! bss#array#Zeroes(n) abort
  return bss#array#Map([a:n, a:n], { -> 0 })
endfunction

function! bss#array#Ones(n) abort
  return bss#array#Map([a:n, a:n], { -> 1 })
endfunction

function! bss#array#Map(dims, Fn = { -> 0}) abort
  return bss#array#Array(s:NDimMap(a:dims, a:Fn))
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

function! s:Array.Plus(obj) abort dict
  if s:IsArray(a:obj)
    if (a:obj.shape != self.shape)
      throw 'ERROR(BadValue): Attempted to add shape ' .. self.shape .. ' with shape ' .. obj.shape
    endif
    return bss#array#Map(self.shape, { ... -> self.At(a:000) + a:obj.At(a:000) })
  elseif type(a:obj) is v:t_number
    return bss#array#Map(self.shape, { ... -> self.At(a:000) + a:obj })
  endif
  throw 'ERROR(BadValue): Invalid type of argument: ' .. a:obj
endfunction

function! s:Array.Times(obj) abort dict
  if s:IsArray(a:obj)
    if (a:obj.shape != self.shape)
      throw 'ERROR(BadValue): Attempted to add shape ' .. self.shape .. ' with shape ' .. obj.shape
    endif
    return bss#array#Map(self.shape, { ... -> self.At(a:000) * a:obj.At(a:000) })
  elseif type(a:obj) is v:t_number
    return bss#array#Map(self.shape, { ... -> self.At(a:000) * a:obj })
  endif
  throw 'ERROR(BadValue): Invalid type of argument: ' .. a:obj
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

function! s:NDimMap(dims, Fn, idx=[]) abort
  if len(a:dims) == 0
    return call(a:Fn, a:idx)
  else
    return map(range(a:dims[0]), 's:NDimMap(a:dims[1:], a:Fn, a:idx + [v:key])')
  endif
endfunction

" EXPERIMENTAL
" ======================================================================

let I = bss#array#Eye(3)
echom I
echom I.Plus(I)
echom I.Times(2)
echom I.Times(32)
