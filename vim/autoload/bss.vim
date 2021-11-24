function! bss#ClassFile(fname) abort
  return bss#java#classfile#Parse(a:fname)
endfunction

function! bss#Type(Desc) abort
  return bss#type#Type(a:Desc)
endfunction

function! bss#EnsureType(Desc, value) abort
  return bss#type#Ensure(a:val, a:Desc)
endfunction
