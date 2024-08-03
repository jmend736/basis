function! bss#elf#header#Parse(bytes) abort
  let b = a:bytes
  let b.little_endian = v:false

  let header = {}
  let header.ident = bss#elf#header#ParseIdent(b)

  " Setup bytes size and endianness
  let b.little_endian = {
        \   'ELFDATA2LSB': v:true,
        \   'ELFDATA2MSB': v:false,
        \ }[header.ident.data]
  let b.size = {
        \   'ELFCLASS32': 4,
        \   'ELFCLASS64': 8,
        \ }[header.ident.class]

  " [PHT]: Program Header Table : phoff, phentsize, phnum
  " [SHT]: Section Header Table : shoff, shentsize, shnum
  let header.type      = b.Half() " Object file type
  let header.machine   = b.Half() " Target architecture
  let header.version   = b.Word() " Object file format version
  let header.entry     = b.Addr() " Virtual address of program entry point
  let header.phoff     = b.Off()  " [PHT] File offset (bytes)
  let header.shoff     = b.Off()  " [SHT] File offset (bytes)
  let header.flags     = b.Word() " Processor-specific flags
  let header.ehsize    = b.Half() " Size (bytes) of the ELF header
  let header.phentsize = b.Half() " [PHT] Size (bytes) of an PHT entry
  let header.phnum     = b.Half() " [PHT] Number of PHT entries
  let header.shentsize = b.Half() " [SHT] Size (bytes) of a SHT entry
  let header.shnum     = b.Half() " [SHT] Number of SHT entries
  let header.shstrndx  = b.Half() " Section header table index of string table

  let header.type = {
        \   0x0000: 'ET_NONE',
        \   0x0001: 'ET_REL',
        \   0x0002: 'ET_EXEC',
        \   0x0003: 'ET_DYN',
        \   0x0004: 'ET_CORE',
        \   0xFE00: 'ET_LOOS',
        \   0xFEFF: 'ET_HIOS',
        \   0xFF00: 'ET_LOPROC',
        \   0xFFFF: 'ET_HIPROC',
        \ }[header.type]
  let header.machine = {
        \   0x3E: 'AMD X86-64'
        \ }[header.machine]
  let header.version = {
        \   0x00000000: 'EV_NONE',
        \   0x00000001: 'EV_CURRENT',
        \ }[header.version]

  let header.flags = printf("0x%X", header.flags)

  return header
endfunction

function! bss#elf#header#ParseIdent(bytes) abort
  let b = a:bytes
  let b.little_endian = v:false

  let ident = {}
  let ident.magic       = b.ReadBytes(4) " Magic bytes [0x7F, 'E', 'L', 'F']
  let ident.class       = b.Read()       " Specifies bit width (32/64)
  let ident.data        = b.Read()       " Specifies endianness
  let ident.elf_version = b.Read()       " Should always be 1 (EV_CURRENT)
  let ident.os_abi      = b.Read()       " OS ABI type
  let ident.pad         = b.ReadBytes(8) " Padding bytes

  if ident.magic != 0z7F454C46
    throw $'ERROR(IllegalState): Invalid magic: {string(ident.magic)}'
  endif
  let ident.class = {
        \   0: 'ELFCLASSNONE',
        \   1: 'ELFCLASS32',
        \   2: 'ELFCLASS64',
        \ }[ident.class]
  let ident.data = {
        \   0: 'ELFDATANONE',
        \   1: 'ELFDATA2LSB',
        \   2: 'ELFDATA2MSB',
        \ }[ident.data]
  let ident.elf_version = {
        \   0: 'EV_NONE',
        \   1: 'EV_CURRENT',
        \ }[ident.elf_version]
  let ident.os_abi = {
        \   0x00: 'Unix - System V',
        \   0x03: 'Linux',
        \ }[ident.os_abi]

  return ident
endfunction
