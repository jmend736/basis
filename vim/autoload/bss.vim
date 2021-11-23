function! bss#ParseClassFile(fname) abort
  return bss#java#classfile#Parse(a:fname)
endfunction
