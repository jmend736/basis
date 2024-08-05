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

if exists('g:bss_elf_util_test')
  let v:errors = []

  let result = bss#elf#util#MaskDictNumber({}, 10)
  call assert_equal('', result)

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

  if empty(v:errors)
    echom "PASSED"
  else
    echom "FAILED"
    for error in v:errors
      echom error
    endfor
  endif
endif
