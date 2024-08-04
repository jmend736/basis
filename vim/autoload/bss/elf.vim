
let s:Elf = {}

function! bss#elf#Read(bytes) abort
  let elf = s:Elf->extendnew({
        \   'b': a:bytes
        \ })
  let b = a:bytes

  " Parse Header
  call bss#Continuation("Rename header to file_header")
  let elf.header = bss#elf#file_header#Parse(b)
  let elf.PrintFileHeader =
        \ {-> bss#elf#file_header#Print(elf.header)}

  let elf.section_headers = bss#elf#section_header#ParseAll(
        \ b,
        \ elf.header.shoff,
        \ elf.header.shnum,
        \ elf.header.shstrndx)
  let elf.PrintSectionHeaders =
        \ {-> bss#elf#section_header#PrintAll(elf.section_headers)}

  let elf.program_headers = bss#elf#program_header#ParseAll(
        \ b,
        \ elf.header.phoff,
        \ elf.header.phnum)
  let elf.PrintProgramHeaders =
        \ {-> bss#elf#program_header#PrintAll(elf.program_headers)}

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
  call self.PrintFileHeader()
  call self.PrintSectionHeaders()
  call self.PrintProgramHeaders()
endfunction

if exists('g:bss_elf_test')
  let elf = bss#elf#Read(bss#elf#bytes#File("/tmp/pg-OP3S/a.out"))
  call elf.PrintProgramHeaders()
endif
