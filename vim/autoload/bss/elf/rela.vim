function! bss#elf#rela#ParseAll(section_header) abort
  let sh = a:section_header
  let b  = a:section_header.Seek()

  let elements = sh.NumElements()
        \->range()
        \->map('bss#elf#rela#Parse(b)')

  return elements
endfunction

function! bss#elf#rela#Parse(bytes) abort
  " Setup
  let b  = a:bytes

  " Read
  let entry        = {}
  let entry.offset = b.Addr()   " The location at which relocation should be applied.
                                "
  let entry.info   = b.Xword()  " LOL rofl coptyer LMAO
  let entry.addend = b.Sxword() " LOL

  " Interpret
  call bss#Continuation($"Implement interpretation [other, shndx, value, size]")

  return entry
endfunction

function! bss#elf#rela#PrintAll(rela) abort
  call bss#ThreadedPrintDicts(a:rela, [
        \   'offset', 'info', 'addend'
        \ ])
endfunction
