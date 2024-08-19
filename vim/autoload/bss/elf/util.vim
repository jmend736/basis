function! bss#elf#util#MaskDictNumber(dict, value, keys=v:none, sep=',') abort
  let keys = (a:keys is v:none ? a:dict->keys() : a:keys)->map('str2nr(v:val)')
  let results = []
  for key in keys
    if key == 0
      if a:value == 0
        eval results->add(a:dict[key])
      endif
    elseif and(key, a:value) == key
      eval results->add(a:dict[key])
    endif
  endfor
  return join(results, a:sep)
endfunction

let s:LookupDict_DefaultRange = {
      \   'OS'   : [0x60000000, 0x6FFFFFFF],
      \   'PROC' : [0x70000000, 0x7FFFFFFF],
      \ }

""
" Lookup value in dict
"
" Args:
"   {dict}   dictionary to look up
"   {value}  key to look up
"   {ranges} dict from name to list containing [min, max] (inclusive)
"
function! bss#elf#util#LookupDict(dict, key, ranges=s:LookupDict_DefaultRange) abort
  if has_key(a:dict, a:key)
    return a:dict[a:key]
  else
    let key     = str2nr(a:key)
    let key_str = printf("0x%X", key)
    for [l:range_name, l:range] in items(a:ranges)
      let [min, max] = l:range
      if min <= key && key <= max
        return $'<{l:range_name} ({key_str})>'
      endif
    endfor
  endif
  return $'<Unknown ({key_str})>'
endfunction

function! bss#elf#util#ParseLookupDictRange(value) abort
  let l:result = substitute(a:value, '\v\<.* \(0x(\x+)\)\>', '\1', '')
  return str2nr(l:result, 16)
endfunction

if exists('g:bss_elf_util_test')
  let v:errors = []

  call assert_equal('',
        \ bss#elf#util#MaskDictNumber({}, 10))

  call assert_equal('HELLO', 
        \ bss#elf#util#MaskDictNumber(
        \   {
        \     1: "HELLO",
        \     2: "WORLD",
        \   },
        \   0b1
        \ ))

  call assert_equal('HELLO,WORLD', 
        \ bss#elf#util#MaskDictNumber(
        \   {
        \     1: "HELLO",
        \     2: "WORLD",
        \   },
        \   0b11
        \ ))

  call assert_equal('HELLO|WORLD', 
        \ bss#elf#util#MaskDictNumber(
        \   {
        \     1: "HELLO",
        \     2: "WORLD",
        \   },
        \   0b11,
        \   v:none,
        \   '|'
        \ ))


  call assert_equal('HELLO|WORLD', 
        \ bss#elf#util#MaskDictNumber(
        \   {
        \     1: "HELLO",
        \     2: "WORLD",
        \   },
        \   0b11,
        \   v:none,
        \   '|'
        \ ))

  call assert_equal(2,
        \ bss#elf#util#LookupDict({1: 2}, 1))

  call assert_equal('<FOO (0x1)>',
        \ bss#elf#util#LookupDict({}, 1, {'FOO': [0, 10]}))

  call assert_equal(2,
        \ bss#elf#util#LookupDict({1: 2}, 1, {'FOO': [0, 10]}))

  call assert_equal('<FOO (0xA)>',
        \ bss#elf#util#LookupDict({1: 2}, 10, {'FOO': [0, 10]}))

  call assert_equal(10,
        \ bss#elf#util#ParseLookupDictRange('<FOO (0xA)>'))

  call assert_equal(10,
        \ bss#elf#util#LookupDict({1: 2}, 10, {'FOO': [0, 10]})
        \->bss#elf#util#ParseLookupDictRange())

  call assert_equal('<Unknown (0x64)>',
        \ bss#elf#util#LookupDict({1: 2}, 100, {'FOO': [0, 10]}))

  if empty(v:errors)
    echom "PASSED"
  else
    echom "FAILED"
    for error in v:errors
      echom error
    endfor
  endif
endif
