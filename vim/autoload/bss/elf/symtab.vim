function! bss#elf#symtab#ParseAll(bytes, size, entsize) abort
  let b    = a:bytes
  let n    = a:size / a:entsize

  let table = range(n)
        \->map('bss#elf#symtab#Parse(b)')

  return table
endfunction

function! bss#elf#symtab#Parse(bytes) abort
  " Setup
  let b  = a:bytes

  " Read
  let entry       = {}
  let entry.name  = b.Word()  " Symbol name
  let entry.info  = b.Read()  " Type and Binding attributes
  let entry.other = b.Read()  " Reserved
  let entry.shndx = b.Half()  " Section Table Index
  let entry.value = b.Addr()  " Symbol value
  let entry.size  = b.Xword() " Size of object

  " Interpret
  call bss#Continuation($"Implement interpretation [other, shndx, value, size]")
  let entry.info_binding = s:SymbolTable.Info.Bindings[and(0xF0, entry.info)]
  let entry.info_type    = s:SymbolTable.Info.Types[and(0x0F, entry.info)]
  let entry.info         = printf('0x%02X', entry.info)
  let entry.other        = s:SymbolTable.Others[entry.other]
  let entry.shndx        = bss#elf#section_header#ParseIndex(entry.shndx)

  return entry
endfunction

function! bss#elf#symtab#PrintAll(symtab) abort
  call bss#ThreadedPrintDicts(a:symtab, [
        \   'name', 'info', 'info_binding', 'info_type',
        \   'other', 'shndx', 'value', 'size'
        \ ])
endfunction

let s:SymbolTable                     = {}
let s:SymbolTable.Info                = {}
let s:SymbolTable.Info.Bindings       = {}
let s:SymbolTable.Info.Bindings[0x00] = 'STB_LOCAL'  " Local
let s:SymbolTable.Info.Bindings[0x10] = 'STB_GLOBAL' " Global
let s:SymbolTable.Info.Bindings[0x20] = 'STB_WEAK'   " Global with weaker precedence
"let s:SymbolTable.Info.Bindings[0x30] = 'STB_NUM'    " Number of defined types
"let s:SymbolTable.Info.Bindings[0xA0] = 'STB_LOOS'   " Start of OS-specific
"let s:SymbolTable.Info.Bindings[0xC0] = 'STB_HIOS'   " End of OS-specific
"let s:SymbolTable.Info.Bindings[0xD0] = 'STB_LOPROC' " Start of processor-specific
"let s:SymbolTable.Info.Bindings[0xF0] = 'STB_HIPROC' " End of processor-specific
let s:SymbolTable.Info.Types          = {}
let s:SymbolTable.Info.Types[0x00]    = 'STT_NOTYPE'  " Symbol type is unspecified
let s:SymbolTable.Info.Types[0x01]    = 'STT_OBJECT'  " Symbol is a data object
let s:SymbolTable.Info.Types[0x02]    = 'STT_FUNC'    " Symbol is a code object
let s:SymbolTable.Info.Types[0x03]    = 'STT_SECTION' " Symbol associated with a section
let s:SymbolTable.Info.Types[0x04]    = 'STT_FILE'    " Symbol's name is file name
let s:SymbolTable.Info.Types[0x05]    = 'STT_COMMON'  " Symbol is a common data object
let s:SymbolTable.Info.Types[0x06]    = 'STT_TLS'     " Symbol is thread-local data objec
"let s:SymbolTable.Info.Types[0x07]    = 'STT_NUM'    " Number of defined types.
"let s:SymbolTable.Info.Types[0x0A]    = 'STT_LOOS'   " Start of OS-specific
"let s:SymbolTable.Info.Types[0x0C]    = 'STT_HIOS'   " End of OS-specific
"let s:SymbolTable.Info.Types[0x0D]    = 'STT_LOPROC' " Start of processor-specific
"let s:SymbolTable.Info.Types[0x0F]    = 'STT_HIPROC' " End of processor-specific
let s:SymbolTable.Others              = {}
let s:SymbolTable.Others[0]           = 'STV_DEFAULT'   " TODO
let s:SymbolTable.Others[1]           = 'STV_INTERNAL'  " TODO
let s:SymbolTable.Others[2]           = 'STV_HIDDEN'    " TODO
let s:SymbolTable.Others[3]           = 'STV_PROTECTED' " TODO
