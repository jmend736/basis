function! bss#elf#program_header#ParseAll(
      \ bytes, phoff, phnum) abort
  " Setup
  let b = a:bytes.Seek(a:phoff)

  " Read
  let headers = range(a:phnum)
        \->map('bss#elf#program_header#Parse(b)')

  return headers
endfunction

function! bss#elf#program_header#Parse(bytes) abort
  " Setup
  let b = a:bytes
  let program_header = {}

  " 
  let program_header.type   = b.Word()  " Type of segment
  let program_header.flags  = b.Word()  " Segment attributes
  let program_header.offset = b.Off()   " Offset in file
  let program_header.vaddr  = b.Addr()  " Virtual address in memory
  let program_header.padder = b.Addr()  " Reserved
  let program_header.filesz = b.Xword() " Size of segment in file
  let program_header.memsz  = b.Xword() " Size of segment in memory
  let program_header.align  = b.Xword() " Alignment of segment

  " Interpret
  call bss#Continuation("Implement this.")

  return program_header
endfunction
