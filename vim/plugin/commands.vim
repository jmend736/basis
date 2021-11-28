if exists('g:loaded_basis')
  finish
endif
let g:loaded_basis = v:true

command! -nargs=* -complete=file CF call bss#ClassFiles([<f-args>])
