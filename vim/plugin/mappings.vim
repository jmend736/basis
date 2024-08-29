if exists('g:loaded_basis_mappings')
  finish
endif
let g:loaded_basis_mappings = v:true

call bss#draw#align#RegisterMappings()
