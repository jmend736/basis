function! bss#extra#EasyAlignDelimiters() abort
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
