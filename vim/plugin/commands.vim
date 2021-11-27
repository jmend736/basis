if exists('g:loaded_basis')
  finish
endif
let g:loaded_basis = v:true

command! -nargs=0 Classfiles call bss#ClassFiles()
command! -nargs=0 ClassFiles call bss#ClassFiles()
