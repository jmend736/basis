
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

function! s:ParseSectionHeader(b) abort
  let b = a:b
  return {
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
endfunction

function! s:Elf.GetSectionStringAddress() abort dict
  return self.headers[self.header.shstrndx].offset
endfunction

function! s:Elf.Print() abort dict
  echo "Elf Header"
  call bss#ThreadedPrintKeys(" {} --> {-}", self.header, [
        \   'magic',
        \   'class',
        \   'data',
        \   'elf_version',
        \   'os_abi',
        \   'pad',
        \   'type',
        \   'machine',
        \   'version',
        \   'entry',
        \   'phoff',
        \   'shoff',
        \   'flags',
        \   'ehsize',
        \   'phentsize',
        \   'phnum',
        \   'shentsize',
        \   'shnum',
        \   'shstrndx',
        \ ])
  echo "Elf Section Headers"
  call bss#ThreadedPrintDicts(repeat("| {} ", self.headers[0]->len()), self.headers)
endfunction

if v:true
  call bss#elf#Read(bss#elf#bytes#File("/tmp/pg-OP3S/a.out")).Print()
endif
