function! bss#extra#SetupEasyAlignDelimiters() abort
  return {
        \   '(': {
        \     'pattern': '(',
        \     'right_margin': 0,
        \   },
        \   ':': {
        \     'pattern': ':',
        \   },
        \ }
endfunction
