function! bss#elf#section_header#ParseAll(bytes, shoff, shnum, shstrndx) abort
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
  let section_header = {
        \   'name'      : b.Word(),
        \   'type'      : b.Word(),
        \   'flags'     : b.Xword(),
        \   'addr'      : b.Addr(),
        \   'offset'    : b.Off(),
        \   'size'      : b.Xword(),
        \   'link'      : b.Word(),
        \   'info'      : b.Word(),
        \   'addralign' : b.Xword(),
        \   'entsize'   : b.Xword(),
        \ }
  if has_key(s:SectionHeader_Type, section_header.type)
    let section_header.type = s:SectionHeader_Type[section_header.type]
  elseif 0x60000000 <= section_header.type && section_header.type <= 0x6FFFFFFF
    let section_header.type = '<OS Specific>'
  elseif 0x70000000 <= section_header.type && section_header.type <= 0x7FFFFFFF
    let section_header.type = '<OS Specific>'
  else
    let section_header.type = printf('<Unknown(%d)>', section_header.type)
  endif
  return section_header
endfunction

let s:SectionHeader_Type = {}
let s:SectionHeader_Type[0x00000000] = 'SHT_NULL'          " Marks an unused section header
let s:SectionHeader_Type[0x00000001] = 'SHT_PROGBITS'      " Contains information defined by the program
let s:SectionHeader_Type[0x00000002] = 'SHT_SYMTAB'        " Contains a linker symbol table
let s:SectionHeader_Type[0x00000003] = 'SHT_STRTAB'        " Contains a string table
let s:SectionHeader_Type[0x00000004] = 'SHT_RELA'          " Contains 'Rela' type relocation entries
let s:SectionHeader_Type[0x00000005] = 'SHT_HASH'          " Contains a symbol hash table
let s:SectionHeader_Type[0x00000006] = 'SHT_DYNAMIC'       " Contains dynamic linking tables
let s:SectionHeader_Type[0x00000007] = 'SHT_NOTE'          " Contains note information
let s:SectionHeader_Type[0x00000008] = 'SHT_NOBITS'        " Contains uninitialized space (does not occupy space in file)
let s:SectionHeader_Type[0x00000009] = 'SHT_REL'           " Contains 'Rel' type relocation entries
let s:SectionHeader_Type[0x0000000A] = 'SHT_SHLIB'         " (reserved)
let s:SectionHeader_Type[0x0000000B] = 'SHT_DYNSYM'        " Contains a dynamic loader symbol table
let s:SectionHeader_Type[0x0000000E] = 'SHT_INIT_ARRAY'    " Array of constructors
let s:SectionHeader_Type[0x0000000F] = 'SHT_FINI_ARRAY'    " Array of destructors
let s:SectionHeader_Type[0x00000010] = 'SHT_PREINIT_ARRAY' " Array of pre-constructors
let s:SectionHeader_Type[0x00000011] = 'SHT_GROUP'         " Section Group
let s:SectionHeader_Type[0x00000012] = 'SHT_SYMTAB_SHNDX'  " Extended section indices
let s:SectionHeader_Type[0x00000013] = 'SHT_NUM'           " Number of defined types.
let s:SectionHeader_Type[0x60000000] = 'SHT_LOOS'          " Environment-specific use
let s:SectionHeader_Type[0x6FFFFFFF] = 'SHT_HIOS'          " Environment-specific use
let s:SectionHeader_Type[0x70000000] = 'SHT_LOPROC'        " Processor-specific use
let s:SectionHeader_Type[0x7FFFFFFF] = 'SHT_HIPROC'        " Processor-specific use
