function! bss#elf#symtab#ParseAll(bytes, size, entsize) abort
  let b    = a:bytes
  let n    = a:size / a:entsize

  let table = range(n)
        \->map('bss#elf#symtab#Parse(b)')

  return table
endfunction

function! bss#elf#symtab#Parse(bytes) abort
  " Setup
  let b  = a:bytes

  " Read
  let entry       = {}
  let entry.name  = b.Word()  " Symbol name
  let entry.info  = b.Read()  " Type and Binding attributes
  let entry.other = b.Read()  " Reserved
  let entry.shndx = b.Half()  " Section Table Index
  let entry.value = b.Addr()  " Symbol value
  let entry.size  = b.Xword() " Size of object

  " Interpret
  call bss#Continuation("Implement interpretation")

  return entry
endfunction

function! bss#elf#symtab#PrintAll(symtab) abort
  call bss#ThreadedPrintDicts(a:symtab)
endfunction
