function! bss#ParseClassFile(fname) abort
  return bss#java#classfile#Parse(a:fname)
endfunction

function! bss#Type(Desc) abort
  return bss#type#Type(a:Desc)
endfunction

function! bss#Typed(Desc, value) abort
  return bss#type#Typed(a:Desc, a:value)
endfunction

function! bss#ClassFiles(files) abort
  return bss#java#classfiles#Open(a:files)
endfunction

