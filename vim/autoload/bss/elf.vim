
let s:Elf = {}

function! bss#elf#ParseFile(filepath) abort
  return bss#elf#Parse(bss#elf#bytes#File(a:filepath))
endfunction

function! bss#elf#Parse(bytes) abort
  let elf = s:Elf->extendnew({
        \   'b': a:bytes
        \ })
  let b = a:bytes

  " Parse File Header
  let elf.file_header = bss#elf#file_header#Parse(b)
  let elf.PrintFileHeader =
        \ {-> bss#elf#file_header#Print(elf.file_header)}

  " Parse Section Headers
  let elf.section_headers = bss#elf#section_header#ParseAll(
        \ b,
        \ elf.file_header.shoff,
        \ elf.file_header.shnum,
        \ elf.file_header.shstrndx)
  let elf.PrintSectionHeaders =
        \ {-> bss#elf#section_header#PrintAll(elf.section_headers)}

  " Parse Program Headers
  let elf.program_headers = bss#elf#program_header#ParseAll(
        \ b,
        \ elf.file_header.phoff,
        \ elf.file_header.phnum)
  let elf.PrintProgramHeaders =
        \ {-> bss#elf#program_header#PrintAll(elf.program_headers)}

  " Process section_headers individually
  for section_header in elf.section_headers
    if section_header.name ==# '.interp'
      let elf.interp = section_header.Seek().AsciiNull()
    elseif section_header.name ==# '.symtab'
      let sh = section_header
      let elf.symtab = bss#elf#symtab#ParseAll(
            \ section_header.Seek(),
            \ sh.size,
            \ sh.entsize)
    elseif section_header.name ==# '.strtab'
      let sh = section_header
      let elf.strtab = b.SeekNew(sh.offset)
    endif
  endfor

  " Process section_header intradependencies
   for sym in elf.symtab
     if sym.name == 0
       continue
     endif
     let sb = elf.strtab->copy()
     call sb.ReadBytes(sym.name)
     let sym.name = sb.AsciiNull()
   endfor

  return elf
endfunction

function! s:Elf.Print() abort dict
  call self.PrintFileHeader()
  call self.PrintSectionHeaders()
  call self.PrintProgramHeaders()
endfunction

if exists('g:bss_elf_test')
  let elf = bss#elf#ParseFile("/tmp/pg-OP3S/a.out")
  call bss#ThreadedPrintDicts(elf.symtab)
endif
