if !exists('g:bss_commands')
  finish
endif

mess clear

command! -range Center call bss#commands#InterpretRange(<line1>, <line2>, <range>, <count>)

function! bss#commands#InterpretRange(line1, line2, range, count) abort
  let mode  = mode()
  let state = state()
  call bss#PP(l:)
endfunction
