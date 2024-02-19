if exists('g:loaded_basis_mappings')
  finish
endif
let g:loaded_basis_mappings = v:true

vnoremap <expr> <Plug>(bss#draw#align#Center) bss#draw#align#AlignOp('bss#draw#align#Center')
vnoremap <expr> <Plug>(bss#draw#align#Left) bss#draw#align#AlignOp('bss#draw#align#Left')
vnoremap <expr> <Plug>(bss#draw#align#Right) bss#draw#align#AlignOp('bss#draw#align#Right')
