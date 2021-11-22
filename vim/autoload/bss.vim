function! bss#ParseClassFile(fname) abort dict
  return bss#java#classfile#Parse(a:fname)
endfunction
