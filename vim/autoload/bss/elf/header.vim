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
        \ }[b.Half()]
  let header.machine = {
        \   0x3E: 'AMD X86-64'
        \ }[b.Half()]
  let header.version = {
        \   0x00000000: 'EV_NONE',
        \   0x00000001: 'EV_CURRENT',
        \ }[b.Word()]
  let header.entry     = b.Addr()
  let header.phoff     = b.Off()
  let header.shoff     = b.Off()
  let header.flags     = printf("0x%X", b.Word())
  let header.ehsize    = b.Half()
  let header.phentsize = b.Half()
  let header.phnum     = b.Half()
  let header.shentsize = b.Half()
  let header.shnum     = b.Half()
  let header.shstrndx  = b.Half()

  return header
endfunction

function! bss#elf#header#ParseIdent(bytes) abort
  let b = a:bytes
  let b.little_endian = v:false
  let ident = {}
  let ident.magic = b.ReadBytes(4)
  if ident.magic != 0z7F454C46
    throw $'ERROR(IllegalState): Invalid magic: {string(ident.magic)}'
  endif
  let ident.class = {
        \   0: 'ELFCLASSNONE',
        \   1: 'ELFCLASS32',
        \   2: 'ELFCLASS64',
        \ }[b.Read()]
  let ident.data = {
        \   0: 'ELFDATANONE',
        \   1: 'ELFDATA2LSB',
        \   2: 'ELFDATA2MSB',
        \ }[b.Read()]
  let ident.elf_version = {
        \   0: 'EV_NONE',
        \   1: 'EV_CURRENT',
        \ }[b.Read()]
  let ident.os_abi = {
        \   0x00: 'Unix - System V',
        \   0x03: 'Linux',
        \ }[b.Read()]
  let ident.pad = b.ReadBytes(8)
  return ident
endfunction
