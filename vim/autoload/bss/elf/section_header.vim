function! bss#elf#section_header#ParseAll(
      \ bytes, shoff, shnum, shstrndx) abort
  let b = a:bytes

  " Parse Section Headers
  call b.Seek(a:shoff)
  let headers = range(a:shnum)
        \->map('bss#elf#section_header#Parse(b)')

  let string_base = headers[a:shstrndx].offset
  for header in headers
    let header.name_str =
          \ b.Seek(string_base + header.name)
          \ .AsciiNull()
  endfor

  return headers
endfunction


function! bss#elf#section_header#Parse(bytes) abort
  let b = a:bytes

  let section_header = {}
  let section_header.name      = b.Word()  " (TODO)
  let section_header.type      = b.Word()  " (TODO)
  let section_header.flags     = b.Xword() " (TODO)
  let section_header.addr      = b.Addr()  " (TODO)
  let section_header.offset    = b.Off()   " (TODO)
  let section_header.size      = b.Xword() " (TODO)
  let section_header.link      = b.Word()  " (TODO)
  let section_header.info      = b.Word()  " (TODO)
  let section_header.addralign = b.Xword() " (TODO)
  let section_header.entsize   = b.Xword() " (TODO)

  let section_header.type =
        \ s:SectionHeader.Type.parse(section_header.type)
  return section_header
endfunction

let s:SectionHeader = {}
let s:SectionHeader.Type = {}
function! s:SectionHeader.Type.parse(value) abort
  if has_key(s:SectionHeader.Type, a:value)
    return s:SectionHeader.Type[a:value]
  elseif 0x60000000 <= a:value && a:value <= 0x6FFFFFFF
    return '<OS Specific>'
  elseif 0x70000000 <= a:value && a:value <= 0x7FFFFFFF
    return '<OS Specific>'
  else
    return printf('<Unknown(%d)>', a:value)
  endif
endfunction
let s:SectionHeader.Type[0x00000000] = 'SHT_NULL'          " Marks an unused section header
let s:SectionHeader.Type[0x00000001] = 'SHT_PROGBITS'      " Contains information defined by the program
let s:SectionHeader.Type[0x00000002] = 'SHT_SYMTAB'        " Contains a linker symbol table
let s:SectionHeader.Type[0x00000003] = 'SHT_STRTAB'        " Contains a string table
let s:SectionHeader.Type[0x00000004] = 'SHT_RELA'          " Contains 'Rela' type relocation entries
let s:SectionHeader.Type[0x00000005] = 'SHT_HASH'          " Contains a symbol hash table
let s:SectionHeader.Type[0x00000006] = 'SHT_DYNAMIC'       " Contains dynamic linking tables
let s:SectionHeader.Type[0x00000007] = 'SHT_NOTE'          " Contains note information
let s:SectionHeader.Type[0x00000008] = 'SHT_NOBITS'        " Contains uninitialized space (does not occupy space in file)
let s:SectionHeader.Type[0x00000009] = 'SHT_REL'           " Contains 'Rel' type relocation entries
let s:SectionHeader.Type[0x0000000A] = 'SHT_SHLIB'         " (reserved)
let s:SectionHeader.Type[0x0000000B] = 'SHT_DYNSYM'        " Contains a dynamic loader symbol table
let s:SectionHeader.Type[0x0000000E] = 'SHT_INIT_ARRAY'    " Array of constructors
let s:SectionHeader.Type[0x0000000F] = 'SHT_FINI_ARRAY'    " Array of destructors
let s:SectionHeader.Type[0x00000010] = 'SHT_PREINIT_ARRAY' " Array of pre-constructors
let s:SectionHeader.Type[0x00000011] = 'SHT_GROUP'         " Section Group
let s:SectionHeader.Type[0x00000012] = 'SHT_SYMTAB_SHNDX'  " Extended section indices
let s:SectionHeader.Type[0x00000013] = 'SHT_NUM'           " Number of defined types.
let s:SectionHeader.Type[0x60000000] = 'SHT_LOOS'          " Environment-specific use
let s:SectionHeader.Type[0x6FFFFFFF] = 'SHT_HIOS'          " Environment-specific use
let s:SectionHeader.Type[0x70000000] = 'SHT_LOPROC'        " Processor-specific use
let s:SectionHeader.Type[0x7FFFFFFF] = 'SHT_HIPROC'        " Processor-specific use
