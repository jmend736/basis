
let s:Elf = {}

function! bss#elf#ParseFile(filepath) abort
  return bss#elf#Parse(bss#elf#bytes#File(a:filepath))
endfunction

function! bss#elf#Parse(bytes) abort
  let elf = s:Elf->extendnew({
        \   'b': a:bytes
        \ })
  let b = a:bytes

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

if exists('g:bss_elf_test')
  call bss#elf#ParseFile("/tmp/pg-OP3S/a.out").PrintProgramHeaders()
endif
