
let s:Elf = {}

function! bss#elf#ParseFile(filepath) abort
  return bss#elf#Parse(bss#elf#bytes#File(a:filepath))
endfunction

function! bss#elf#Parse(bytes) abort
  let elf = s:Elf->extendnew({'b': a:bytes})
  let b   = a:bytes

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

  let elf.sections = {}

  " Process section_headers individually
  for section_header in elf.section_headers

    " Parse .interp section
    if section_header.name ==# '.interp'
      let elf.sections[section_header.name] =
            \ section_header.Seek().AsciiNull()

    " Parse .symtab section
    elseif section_header.type ==# 'SHT_SYMTAB'
      let elf.sections[section_header.name] =
            \ bss#elf#symtab#ParseAll(
            \   section_header.Seek(),
            \   section_header.size,
            \   section_header.entsize)

    " Parse .rela.* sections
    elseif section_header.type ==# 'SHT_RELA'
      let elf.sections[section_header.name] =
            \ bss#elf#rela#ParseAll(section_header)

    " Parse .strtab, .shstrtab, and .dynstr sections
    elseif section_header.type ==# 'SHT_STRTAB'
      let elf.sections[section_header.name] =
            \ b.SeekNew(section_header.offset)

    " Parse .dynamic section
    elseif section_header.type ==# 'SHT_DYNAMIC'
      let elf.sections[section_header.name] =
            \ bss#elf#dyn#ParseAll(section_header)

    elseif section_header.name ==# '.got'
      let sb = section_header.Seek()
      let elf.sections[section_header.name] =
            \ range(section_header.NumElements())->map({
            \   -> sb.Addr()
            \ })
    endif
  endfor

  " Process section_header intradependencies
   for sym in elf.sections['.symtab']
     if sym.name == 0
       continue
     endif
     let sb = elf.sections['.strtab']->copy()
     call sb.ReadBytes(sym.name)
     let sym.name = sb.AsciiNull()
   endfor

  " Parse Program Headers
  let elf.program_headers = bss#elf#program_header#ParseAll(
        \ b,
        \ elf.file_header.phoff,
        \ elf.file_header.phnum)
  let elf.PrintProgramHeaders =
        \ {-> bss#elf#program_header#PrintAll(elf.program_headers)}

  return elf
endfunction

function! s:Elf.Print() abort dict
  call self.PrintFileHeader()
  call self.PrintSectionHeaders()
  call self.PrintProgramHeaders()
endfunction

" $BSS_ELF_TEST must point to an object file.
if exists('$BSS_ELF_TEST')
  let elf = bss#elf#ParseFile($BSS_ELF_TEST)
  let v = bss#view#DataView(elf.sections['.dynamic'])
        \.Exec('set nowrap')
endif
