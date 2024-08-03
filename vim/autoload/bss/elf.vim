
let s:Elf = {}

function! bss#elf#Read(bytes) abort
  let elf = s:Elf->extendnew({
        \   'b': a:bytes
        \ })

  let b               = a:bytes
  let b.little_endian = v:false
  let v:errors = []

  let elf.header = {}
  let elf.header.magic = b.ReadBytes(4)
  call assert_equal(0z7F454C46, elf.header.magic)
  let elf.header.class = {
        \   0: 'ELFCLASSNONE',
        \   1: 'ELFCLASS32',
        \   2: 'ELFCLASS64',
        \ }[b.Read()]
  let elf.header.data = {
        \   0: 'ELFDATANONE',
        \   1: 'ELFDATA2LSB',
        \   2: 'ELFDATA2MSB',
        \ }[b.Read()]
  let elf.header.elf_version = {
        \   0: 'EV_NONE',
        \   1: 'EV_CURRENT',
        \ }[b.Read()]
  let elf.header.os_abi = {
        \   0x00: 'Unix - System V',
        \   0x03: 'Linux',
        \ }[b.Read()]
  let elf.header.pad = b.ReadBytes(8)

  let b.little_endian = {
        \   'ELFDATA2LSB': v:true,
        \   'ELFDATA2MSB': v:false,
        \ }[elf.header.data]
  let b.size = {
        \   'ELFCLASS32': 4,
        \   'ELFCLASS64': 8,
        \ }[elf.header.class]

  let elf.header.type = {
        \   0x0000: 'ET_NONE',
        \   0x0001: 'ET_REL',
        \   0x0002: 'ET_EXEC',
        \   0x0003: 'ET_DYN',
        \   0x0004: 'ET_CORE',
        \   0xFE00: 'ET_LOOS',
        \   0xFEFF: 'ET_HIOS',
        \   0xFF00: 'ET_LOPROC',
        \   0xFFFF: 'ET_HIPROC',
        \ }[b.Half()]
  let elf.header.machine = {
        \   0x3E: 'AMD X86-64'
        \ }[b.Half()]
  let elf.header.version = {
        \   0x00000000: 'EV_NONE',
        \   0x00000001: 'EV_CURRENT',
        \ }[b.Word()]
  let elf.header.entry     = b.Addr()
  let elf.header.phoff     = b.Off()
  let elf.header.shoff     = b.Off()
  let elf.header.flags     = printf("0x%X", b.Word())
  let elf.header.ehsize    = b.Half()
  let elf.header.phentsize = b.Half()
  let elf.header.phnum     = b.Half()
  let elf.header.shentsize = b.Half()
  let elf.header.shnum     = b.Half()
  let elf.header.shstrndx  = b.Half()

  call b.Seek(elf.header.shoff)
  let elf.headers = range(elf.header.shnum)
        \->map('b->s:ParseSectionHeader()')

  let string_base = elf.headers[elf.header.shstrndx].offset
  for header in elf.headers
    let header.name_str =
          \ b.Seek(string_base + header.name)
          \ .AsciiNull()
  endfor

  "call bss#Continuation("Implement String Handling")

  if !empty(v:errors)
    for error in v:errors
      echom error
    endfor
    throw 'ERROR(Failed)'
  endif
  return elf
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

function! s:ParseSectionHeader(b) abort
  let b = a:b
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

function! s:Elf.GetSectionStringAddress() abort dict
  return self.headers[self.header.shstrndx].offset
endfunction

function! s:Elf.Print() abort dict
  echo '>>> Elf Header'
  echo "\n"
  call bss#ThreadedPrintKeys("   {} --> {-}", self.header, [
        \   'magic', 'class', 'data', 'elf_version', 'os_abi', 'pad',
        \   'type', 'machine', 'version', 'entry', 'phoff', 'shoff',
        \   'flags', 'ehsize', 'phentsize', 'phnum', 'shentsize', 'shnum', 'shstrndx',
        \ ])
  echo "\n"
  echo '>>> Elf Section Headers'
  echo "\n"
  call bss#ThreadedPrintDicts(self.headers)
endfunction

if v:true
  call bss#elf#Read(bss#elf#bytes#File("/tmp/pg-OP3S/a.out")).Print()
endif
