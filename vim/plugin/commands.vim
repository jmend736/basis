if exists('g:loaded_basis')
  finish
endif
let g:loaded_basis = v:true

command! -nargs=* -complete=file CF call bss#ClassFiles([<f-args>])

command! -nargs=* -complete=expression -bang PP call bss#PP(<args>, "<bang>" ==# '!')
command! -nargs=* -complete=expression -bang PB call bss#PB(<args>, "<bang>" ==# '!')
command! -nargs=* -complete=expression -bang PN call bss#PN(<args>)
