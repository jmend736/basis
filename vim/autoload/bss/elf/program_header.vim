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

  " Read
  let program_header        = {}
  let program_header.type   = b.Word()  " Type of segment
  let program_header.flags  = b.Word()  " Segment attributes
  let program_header.offset = b.Off()   " Offset in file
  let program_header.vaddr  = b.Addr()  " Virtual address in memory
  let program_header.padder = b.Addr()  " Reserved
  let program_header.filesz = b.Xword() " Size of segment in file
  let program_header.memsz  = b.Xword() " Size of segment in memory
  let program_header.align  = b.Xword() " Alignment of segment

  " Interpret
  let todoFields =<< trim END
  flags
  offset
  vaddr
  padder
  filesz
  memsz
  align
  END
  call bss#Continuation($"Implement interpretation of program header {todoFields}.")
  let program_header.type = s:ProgramHeader.ParseType(program_header.type)
  let program_header.flags = s:ProgramHeader.ParseFlags(program_header.flags)

  return program_header
endfunction

function! bss#elf#program_header#PrintAll(program_headers) abort
  echo "\n"
  echo '>>> ELF Program Headers'
  echo "\n"
  call bss#ThreadedPrintDicts(a:program_headers, [
        \   'type', 'flags', 'offset', 'vaddr', 'padder', 'filesz', 'memsz', 'align'
        \ ])
endfunction

let s:ProgramHeader = {}

let s:ProgramHeader.Type = {}

function! s:ProgramHeader.ParseType(value) abort
  if has_key(self.Type, a:value)
    return self.Type[a:value]
  elseif 0x60000000 <= a:value && a:value <= 0x6FFFFFFF
    return printf('<OS specific(0x%X)>', a:value)
  elseif 0x70000000 <= a:value && a:value <= 0x7FFFFFFF
    return printf('<PROC specific(0x%X)>', a:value)
  else
    return printf('<Unknown(%d)>', a:value)
  endif
endfunction

let s:ProgramHeader.Type[0x00000000] = 'PT_NULL'         " Unused Entry
let s:ProgramHeader.Type[0x00000001] = 'PT_LOAD'         " Loadable Segment
let s:ProgramHeader.Type[0x00000002] = 'PT_DYNAMIC'      " Dynamic Linking Tables
let s:ProgramHeader.Type[0x00000003] = 'PT_INTERP'       " Program interpreter path name
let s:ProgramHeader.Type[0x00000004] = 'PT_NOTE'         " Note sections
let s:ProgramHeader.Type[0x00000005] = 'PT_SHLIB'        " Reserved
let s:ProgramHeader.Type[0x00000006] = 'PT_PHDR'         " Program Header Table
let s:ProgramHeader.Type[0x60000000] = 'PT_LOOS'         " Environment-specific use
let s:ProgramHeader.Type[0x6474E550] = 'PT_GNU_EH_FRAME' " GCC .eh_frame_hdr segment
let s:ProgramHeader.Type[0x6474E551] = 'PT_GNU_STACK'    " Indicates stack executability
let s:ProgramHeader.Type[0x6474E552] = 'PT_GNU_RELRO'    " Read-only after relocation
let s:ProgramHeader.Type[0x6474E553] = 'PT_GNU_PROPERTY' " (TODO)
let s:ProgramHeader.Type[0x6FFFFFFA] = 'PT_LOSUNW'       " Sun specific use
let s:ProgramHeader.Type[0x6FFFFFFA] = 'PT_SUNWBSS'      " Sun specific Segment
let s:ProgramHeader.Type[0x6FFFFFFB] = 'PT_SUNWSTACK'    " Stack segment
let s:ProgramHeader.Type[0x6FFFFFFF] = 'PT_HIOS'         " Environment-specific use
let s:ProgramHeader.Type[0x70000000] = 'PT_HIPROC'       " Processor-specific use
let s:ProgramHeader.Type[0x7FFFFFFF] = 'PT_HIPROC'       " Processor-specific use

let s:ProgramHeader.Flags = {}

let s:ProgramHeader.Flags[0x00000001] = 'PF_X' " Execute permission
let s:ProgramHeader.Flags[0x00000002] = 'PF_W' " Write permission
let s:ProgramHeader.Flags[0x00000004] = 'PF_R' " Read permission

let s:ProgramHeader.ParseFlags =
      \ {value ->
      \   bss#elf#util#MaskDictNumber(
      \     s:ProgramHeader.Flags, value, [4, 2, 1])}
