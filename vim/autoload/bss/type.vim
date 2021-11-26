"
" bss#type#Type(desc) returns a funcref which asserts that
"   any values passed in match the {desc}
"
" bss#type#Typed(desc, value) ensures that {value} matches {desc}, then
"   returns {value} extended (but not overriden) by {desc} (effectively
"   forwarding methods, but not values).
"
" Descriptors:
"
"   descriptor:
"     vim type (eg. v:t_list, v:t_number, ...)
"       the {value}'s type with be checked aginst the {vim type}
"     a list of descriptor(s)
"       assert {value} is a list, and its entries match any of {descriptor(s)}
"     a map with descriptor values
"       asser all keys in {map} exist in {value}, and the {descriptor} matches
"       the key's corresponding value.
"     a function returned by bss#type#Type()
"       defer to the type checker
"     a string
"       the string will be matched literally
"     any function
"       ensure {value} has type v:t_func
"
" Function handling:
"
"   Funcrefs are handled depending on whether they originate from the
"   script-local functions here. If they are from here, then it's run as a
"   checker, otherwise it's treated as a type-check for funcref. This means
"   that there are two ways of using types:
"
"     let s:Type = bss#Type({'value': v:t_number})
"     ...
"     let l:instance =  s:Type({'value': 10})
"
"   Alternatively
"
"     let s:Type = {'value': v:t_number}
"
"     function! s:Type.Foo() abort
"     endfunction
"     ...
"     let l:instance = bss#Typed(s:Type, {'value': 10})

function! bss#type#Enable() abort
  let g:bss_typecheck = v:true
endfunction

function! bss#type#Disable() abort
  if exists('g:bss_typecheck')
    unlet g:bss_typecheck
  endif
endfunction

" return a type checker that accepts an argument and return the argument if it
" matches the type {desc}riptor
function! bss#type#Type(Desc) abort
  if exists('g:bss_typecheck')
    return funcref(s:Checker(a:Desc), [s:Path()])
  endif
  return { v -> v }
endfunction

function! bss#type#Typed(Desc, value) abort
  if type(a:value) is v:t_dict
    return bss#type#Type(a:Desc)(extend(copy(a:Desc), a:value))
  endif
  return bss#type#Type(a:Desc)(a:value)
endfunction

" Returns function that accepts { path, value -> v:none }
function! s:Checker(Desc) abort
  if type(a:Desc) == v:t_number
    return function('s:CheckType', [a:Desc])
  elseif type(a:Desc) == v:t_string
    return function('s:CheckString', [a:Desc])
  elseif type(a:Desc) == v:t_dict
    let l:checkers = map(copy(a:Desc), 's:Checker(v:val)')
    return function('s:CheckDict', [l:checkers])
  elseif type(a:Desc) == v:t_list && len(a:Desc) == 1
    let l:Checker = s:Checker(a:Desc[0])
    return function('s:CheckList', [l:Checker])
  elseif type(a:Desc) == v:t_list && len(a:Desc) > 1
    let l:checkers = map(copy(a:Desc), 's:Checker(v:val)')
    return function('s:CheckUnion', [l:checkers])
  elseif type(a:Desc) == v:t_func && s:IsCheckMethod(a:Desc)
    return function(get(a:Desc, 'name'), get(a:Desc, 'args')[:-2])
  elseif type(a:Desc) == v:t_func
    return function('s:CheckType', [v:t_func])
  endif
  throw 'Invalid descriptor: ' .. string(a:Desc)
endfunction

function! s:CheckType(type, path, value) abort
  if type(a:value) != a:type
    throw printf(
          \ 'ERROR(Type): At %s expected type %s but got value %s',
          \ s:PathString(a:path), s:TypeNames->get(a:type), string(a:value))
  endif
  return a:value
endfunction

function! s:CheckDict(checkers, path, value) abort
  call s:CheckType(v:t_dict, a:path, a:value)
  for l:key in keys(a:checkers)
    if !has_key(a:value, l:key)
      throw printf(
            \ 'ERROR(Type): At %s expected item with key "%s", but none found!',
            \ s:PathString(a:path), l:key)
    endif
    call a:checkers[l:key](s:Path(a:path, l:key), a:value[l:key])
  endfor
  return a:value
endfunction

function! s:CheckList(Checker, path, value) abort
  call s:CheckType(v:t_list, a:path, a:value)
  call map(copy(a:value),
        \ {i, v -> a:Checker(s:Path(a:path, printf('[%d]', i)), v)})
  return a:value
endfunction

function! s:CheckString(desc, path, value) abort
  call s:CheckType(v:t_string, a:path, a:value)
  if a:desc !=# a:value
    throw printf(
          \ 'ERROR(Type): At %s expected string value of "%s", but got "%s".',
          \ s:PathString(a:path), a:desc, a:value)
  endif
  return a:value
endfunction

function! s:CheckUnion(checkers, path, value) abort
  call s:CheckType(v:t_list, a:path, a:value)
  let l:enumeration = map(copy(a:value), '[v:key, v:val]')
  for [l:key, l:val] in l:enumeration
    let l:ok = v:false
    for l:Checker in a:checkers
      try
        call l:Checker(s:Path(a:path, printf('[%d]', l:key)), l:val)
        let l:ok = v:true
        break
      catch /^ERROR(Type)/
        continue
      endtry
    endfor
    if !l:ok
      throw printf(
            \ 'ERROR(Type): At %s the value %s does not match any alternatives!',
            \ s:PathString(a:path), string(l:val))
    endif
  endfor
  return a:value
endfunction


function! s:Path(...) abort
  let l:parts = map(copy(a:000), 'trim(v:val, ". ")')->filter('!empty(v:val)')
  return '.' .. join(l:parts, '.')
endfunction

function! s:PathString(path) abort
  if a:path ==# '.'
    return '{arg}'
  endif
  return '{arg}' .. a:path
endfunction

let s:TypeNames = {
      \   v:t_number: 'Number',
      \   v:t_string: 'String',
      \   v:t_func: 'Funcref',
      \   v:t_list: 'List',
      \   v:t_dict: 'Dictionary',
      \   v:t_float: 'Float',
      \   v:t_bool: 'Boolean',
      \   v:t_none: 'None',
      \   v:t_job: 'Job',
      \   v:t_channel: 'Channel',
      \   v:t_blob: 'Blob',
      \ }

function! s:IsCheckMethod(Fn) abort
  let l:prefix = matchstr(get(funcref('s:IsCheckMethod'), "name"), ".*_")
  return stridx(get(a:Fn, 'name'), l:prefix) == 0
endfunction
