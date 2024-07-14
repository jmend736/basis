if exists('g:loaded_basis_commands')
  finish
endif
let g:loaded_basis_commands = v:true

command! -nargs=* -complete=file CF call bss#ClassFiles([<f-args>])

command! -nargs=* -complete=expression -bang PP call bss#PP(<args>, "<bang>" ==# '!')
command! -nargs=* -complete=expression -bang PB call bss#PB(<args>, "<bang>" ==# '!')
command! -nargs=* -complete=expression -bang PN call bss#PN(<args>)
command! -nargs=* -complete=expression -bang PA call bss#PA(<args>, "<bang>" ==# '!')

command! -nargs=* -complete=expression -bang BssTry call bss#Try({ -> <args>})
