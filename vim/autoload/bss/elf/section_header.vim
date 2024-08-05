function! bss#elf#section_header#ParseAll(
      \ bytes, shoff, shnum, shstrndx) abort
  " Setup
  let b = a:bytes.Seek(a:shoff)

  " Read
  let headers = range(a:shnum)
        \->map('bss#elf#section_header#Parse(b)')

  " Interpret
  let string_table = headers[a:shstrndx].offset
  for header in headers
    let header.name =
          \ b.Seek(string_table + header.name)
          \ .AsciiNull()
  endfor

  return headers
endfunction

function! bss#elf#section_header#PrintAll(section_headers) abort
  echo "\n"
  echo '>>> ELF Section Headers'
  echo "\n"
  call bss#ThreadedPrintDicts(a:section_headers, [
        \   'name', 'type', 'flags', 'addr', 'offset', 'size', 'link', 'info', 'addralign', 'entsize'
        \ ])
endfunction

function! bss#elf#section_header#Parse(bytes) abort
  " Setup
  let b = a:bytes

  " Read
  let section_header = {}
  let section_header.name      = b.Word()  " Section name (byte offset into String Table)
  let section_header.type      = b.Word()  " Section type (see s:SectionHeader.Type)
  let section_header.flags     = b.Xword() " Section attributes
  let section_header.addr      = b.Addr()  " Virtual address in memory
  let section_header.offset    = b.Off()   " Offset in file
  let section_header.size      = b.Xword() " Size of section
  let section_header.link      = b.Word()  " Link to other section
  let section_header.info      = b.Word()  " Misc. information
  let section_header.addralign = b.Xword() " Address alignment boundary
  let section_header.entsize   = b.Xword() " Size of entries, if section has table

  " Interpret
  let section_header.type =
        \ s:SectionHeader.Type.parse(section_header.type)
  let section_header.flags =
        \ s:SectionHeader.Flags.parse(section_header.flags)
  let section_header.Seek =
        \ function('s:SectionHeader_Seek', [b], section_header)
  let section_header.SeekNew =
        \ function('s:SectionHeader_SeekNew', [b], section_header)

  return section_header
endfunction

function! s:SectionHeader_Seek(bytes) abort dict
  return a:bytes.Seek(self.offset)
endfunction

function! s:SectionHeader_SeekNew(bytes) abort dict
  return a:bytes.SeekNew(self.offset)
endfunction

""
" Given an {index} of a section header, returns the string representation.
"
"     bss#elf#section_header#ParseIndex(0) --> UND
"
function! bss#elf#section_header#ParseIndex(index) abort
  if a:index == 0
    return 'SHN_UNDEF'
  elseif a:index == 0xFFF1
    return 'SHN_ABS'
  elseif a:index == 0xFFF2
    return 'SHN_COMMON'
  else
    return a:index
  endif
endfunction

let s:SectionHeader = {}
let s:SectionHeader.Index = {}
let s:SectionHeader.Index[0x0000] = 'SHN_UNDEF'  " Undefined index to a section header
let s:SectionHeader.Index[0xFFF1] = 'SHN_ABS'    " Absolute index (does not participate in relocation)
let s:SectionHeader.Index[0xFFF2] = 'SHN_COMMON' " Hello

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

let s:SectionHeader.Flags = {}
function! s:SectionHeader.Flags.parse(value) abort
  let l:flag_strings = []
  for [str_bit, Name] in items(s:SectionHeader.Flags)
    if str_bit ==# 'parse' | continue | endif
    if and(str2nr(str_bit), a:value)
      call add(l:flag_strings, Name)
    endif
  endfor
  return join(l:flag_strings, ',') .. printf(" (0x%X)", a:value)
endfunction
let s:SectionHeader.Flags[0x0000000000000001] = 'SHF_WRITE'            " Section contains writable data
let s:SectionHeader.Flags[0x0000000000000002] = 'SHF_ALLOC'            " Section is allocated in memory image of program
let s:SectionHeader.Flags[0x0000000000000004] = 'SHF_EXECINSTR'        " Section contains executable instructions
let s:SectionHeader.Flags[0x0000000000000010] = 'SHF_MERGE'            " Section might be merged (???)
let s:SectionHeader.Flags[0x0000000000000020] = 'SHF_STRINGS'          " Contains nul-terminated strings
let s:SectionHeader.Flags[0x0000000000000040] = 'SHF_INFO_LINK'        " sh_info contains SHT index
let s:SectionHeader.Flags[0x0000000000000100] = 'SHF_OS_NONCONFORMING' " (TODO)
let s:SectionHeader.Flags[0x0000000000000200] = 'SHF_GROUP'            " (TODO)
let s:SectionHeader.Flags[0x0000000000000400] = 'SHF_TLS'              " (TODO)
let s:SectionHeader.Flags[0x0000000000000800] = 'SHF_COMPRESSED'       " (TODO)
let s:SectionHeader.Flags[0x000000000F000000] = 'SHF_MASKOS'           " Environment-specific use
let s:SectionHeader.Flags[0x00000000F0000000] = 'SHF_MASKPROC'         " Processor-specific use
