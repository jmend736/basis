
let s:Elf = {}

function! bss#elf#Read(bytes) abort
  let elf = s:Elf->extendnew({
        \   'b': a:bytes
        \ })
  let b = a:bytes

  " Parse Header
  let elf.header = bss#elf#file_header#Parse(b)

  let elf.section_headers = bss#elf#section_header#ParseAll(
        \ b,
        \ elf.header.shoff,
        \ elf.header.shnum,
        \ elf.header.shstrndx)

  let elf.program_headers = bss#elf#program_header#ParseAll(
        \ b,
        \ elf.header.phoff,
        \ elf.header.phnum)

  call bss#Continuation("Implement String Handling")

  if !empty(v:errors)
    for error in v:errors
      echom error
    endfor
    throw 'ERROR(Failed)'
  endif
  return elf
endfunction

function! s:Elf.Print() abort dict
  echo "\n"
  echo '>>> Elf Header Ident'
  echo "\n"
  call bss#ThreadedPrintKeys("   {} --> {-}", self.header.ident, [
        \   'magic', 'class', 'data', 'elf_version', 'os_abi', 'pad',
        \ ])
  echo "\n"
  echo '>>> Elf Header'
  echo "\n"
  call bss#ThreadedPrintKeys("   {} --> {-}", self.header, [
        \   'type', 'machine', 'version', 'entry', 'phoff', 'shoff',
        \   'flags', 'ehsize', 'phentsize', 'phnum', 'shentsize', 'shnum', 'shstrndx',
        \ ])
  echo "\n"
  echo '>>> Elf Section Headers'
  echo "\n"
  call bss#ThreadedPrintDicts(self.section_headers)
endfunction

if exists('g:bss_elf_test')
  let s:ph = bss#elf#Read(bss#elf#bytes#File("/tmp/pg-OP3S/a.out")).program_headers

  let s:data = s:ph
        \->map({_, v -> [v.filesz, v.memsz]})

  echom s:data

  call bss#ThreadedPrintLists("{} | {}", s:data)
endif
