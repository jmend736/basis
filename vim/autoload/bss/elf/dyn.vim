function! bss#elf#dyn#ParseAll(section_header) abort
  let b = a:section_header.Seek()
  let table = []

  for _ in a:section_header.NumElements()->range()
    let entry = {}
    let entry.tag = bss#elf#util#LookupDict(s:Tags, b.Sxword())

    if s:UseVal(entry.tag)
      let entry.val = b.Xword()
    else
      let entry.ptr = b.Addr()
    endif

    call add(table, entry)
  endfor

  return table
endfunction

function! s:UseVal(tag) abort
  return index(s:ValTags, a:tag) != -1
endfunction

let s:Tags                     = {}
let s:Tags[0x0000000000000000] = 'DT_NULL'         " Marks the end of the dynamic array
let s:Tags[0x0000000000000001] = 'DT_NEEDED'       " String table offset of the name of the needed library
let s:Tags[0x0000000000000002] = 'DT_PLTRELSZ'     " Total size, in bytes, of the relocation entries associated with the procedure lookup table
let s:Tags[0x0000000000000003] = 'DT_PLTGOT'       " An address associated with the linkage table
let s:Tags[0x0000000000000004] = 'DT_HASH'         " Address of the symbol hash table
let s:Tags[0x0000000000000005] = 'DT_STRTAB'       " Address of the dynamic string table
let s:Tags[0x0000000000000006] = 'DT_SYMTAB'       " Address of the dynamic symbol table
let s:Tags[0x0000000000000007] = 'DT_RELA'         " Address of the relocation table with Rela entries
let s:Tags[0x0000000000000008] = 'DT_RELASZ'       " Total size, in bytes, of the DT_RELA relocation table
let s:Tags[0x0000000000000009] = 'DT_RELAENT'      " Total size, in bytes, of each DT_RELA relocation table entry
let s:Tags[0x000000000000000a] = 'DT_STRSZ'        " Total size, in bytes, of the string table
let s:Tags[0x000000000000000b] = 'DT_SYMENT'       " Size, in bytes, of each symbol table entry
let s:Tags[0x000000000000000c] = 'DT_INIT'         " Address of the initialization function
let s:Tags[0x000000000000000d] = 'DT_FINI'         " Address of the termination function
let s:Tags[0x000000000000000e] = 'DT_SONAME'       " String table offset of the name of this shared object
let s:Tags[0x000000000000000f] = 'DT_RPATH'        " String table offset of a shared library search path string
let s:Tags[0x0000000000000010] = 'DT_SYMBOl'       " (TODO)
let s:Tags[0x0000000000000011] = 'DT_REL'          " Address of a relocation table with Rel entries
let s:Tags[0x0000000000000012] = 'DT_RELSZ'        " Total size, in bytes, of the DT_REL relocation table
let s:Tags[0x0000000000000013] = 'DT_RELENT'       " Size, in bytes, of each DT_REL relocation entry
let s:Tags[0x0000000000000014] = 'DT_PLTREL'       " Type of relocation entry used for the procedure linkage table.
let s:Tags[0x0000000000000015] = 'DT_DEBUG'        " Reserved for debugger use
let s:Tags[0x0000000000000016] = 'DT_TEXTREL'      " (TODO)
let s:Tags[0x0000000000000017] = 'DT_JMPREL'       " (TODO)
let s:Tags[0x0000000000000018] = 'DT_BIND_NOW'     " (TODO)
let s:Tags[0x0000000000000019] = 'DT_INIT_ARRAY'   " (TODO)
let s:Tags[0x000000000000001a] = 'DT_FINI_ARRAY'   " (TODO)
let s:Tags[0x000000000000001b] = 'DT_INIT_ARRAYSZ' " (TODO)
let s:Tags[0x000000000000001c] = 'DT_FINI_ARRAYSZ' " (TODO)
let s:Tags[0x0000000060000000] = 'DT_LOOS'         " Lower bound of OS specific range
let s:Tags[0x000000006fffffff] = 'DT_HIOS'         " Upper bound of OS specific range
let s:Tags[0x0000000070000000] = 'DT_LOPROC'       " Lower bound of processor specific range
let s:Tags[0x000000007fffffff] = 'DT_HIPROC'       " Upper bound of processor specific range

" Tags that use .val rather than .ptr
let s:ValTags = [
      \   'DT_NEEDED',
      \   'DT_PLTRELSZ',
      \   'DT_RELASZ',
      \   'DT_RELAENT',
      \   'DT_STRSZ',
      \   'DT_SYMENT',
      \   'DT_SONAME',
      \   'DT_RPATH',
      \   'DT_RELSZ',
      \   'DT_RELENT',
      \   'DT_PLTREL',
      \   'DT_INIT_ARRAYSZ',
      \   'DT_FINI_ARRAYSZ',
      \ ]
