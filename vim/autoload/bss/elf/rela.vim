function! bss#elf#rela#ParseAll(section_header) abort
  let sh = a:section_header
  let b  = a:section_header.Seek()

  let elements = sh.NumElements()
        \->range()
        \->map('bss#elf#rela#Parse(b)')

  return elements
endfunction

function! bss#elf#rela#Parse(bytes) abort
  " Setup
  let b  = a:bytes

  " Read
  let entry        = {}

  let entry.offset = b.Addr()   " The location at which relocation should be
                                " applied.
                                "
  let entry.info   = b.Xword()  " Provides both
                                " 1.  symbol table index, and
                                " 2.  type of relocation.
                                "
  let entry.addend = b.Sxword() " Constant to add

  " Interpret
  call bss#Continuation($"Implement interpretation [offset, info, addend]")
  let entry.info_sym  = entry.info >> 32
  let entry.info_type = s:Rela.Relocation[and(0xFFFFFFFF, entry.info)]
  let entry.info      = printf("0x%X", entry.info)

  return entry
endfunction

function! bss#elf#rela#PrintAll(rela) abort
  call bss#ThreadedPrintDicts(a:rela, [
        \   'offset', 'info', 'info_sym', 'info_type', 'addend'
        \ ])
endfunction

let s:Rela                = {}
let s:Rela.Relocation     = {}                   " FIELD  : CALCULATION
let s:Rela.Relocation[0]  = 'R_X86_64_NONE'      " none   : none
let s:Rela.Relocation[1]  = 'R_X86_64_64'        " word64 : S + A
let s:Rela.Relocation[2]  = 'R_X86_64_PC32'      " word32 : S + A - P
let s:Rela.Relocation[3]  = 'R_X86_64_GOT32'     " word32 : G + A
let s:Rela.Relocation[4]  = 'R_X86_64_PLT32'     " word32 : L + A - P
let s:Rela.Relocation[5]  = 'R_X86_64_COPY'      " none   : none
let s:Rela.Relocation[6]  = 'R_X86_64_GLOB_DAT'  " word64 : S
let s:Rela.Relocation[7]  = 'R_X86_64_JUMP_SLOT' " word64 : S
let s:Rela.Relocation[8]  = 'R_X86_64_RELATIVE'  " word64 : B + A
let s:Rela.Relocation[9]  = 'R_X86_64_GOTPCREL'  " word32 : G + GOT + A - P
let s:Rela.Relocation[10] = 'R_X86_64_32'        " word32 : S + A
let s:Rela.Relocation[11] = 'R_X86_64_32S'       " word32 : S + A
let s:Rela.Relocation[12] = 'R_X86_64_16'        " word16 : S + A
let s:Rela.Relocation[13] = 'R_X86_64_PC16'      " word16 : S + A - P
let s:Rela.Relocation[14] = 'R_X86_64_8'         " word8  : S + A
let s:Rela.Relocation[15] = 'R_X86_64_PC8'       " word8  : S + A - P
let s:Rela.Relocation[16] = 'R_X86_64_DPTMOD64'  " word64 :
let s:Rela.Relocation[17] = 'R_X86_64_DTPOFF64'  " word64 :
let s:Rela.Relocation[18] = 'R_X86_64_TPOFF64'   " word64 :
let s:Rela.Relocation[19] = 'R_X86_64_TLSGD'     " word32 :
let s:Rela.Relocation[20] = 'R_X86_64_TLSLD'     " word32 :
let s:Rela.Relocation[21] = 'R_X86_64_DTPOFF32'  " word32 :
let s:Rela.Relocation[22] = 'R_X86_64_GOTTPOFF'  " word32 :
let s:Rela.Relocation[23] = 'R_X86_64_TPOFF32'   " word32 :
                                                 "
                                                 " * A   ~ Addend used to compute the value of the relocatable field.
                                                 " * B   ~ Represents the base address at which a shared object has been
                                                 "         loaded into memory during execution
                                                 " * GOT ~ Represents the address of the __Global Offset Table__.
                                                 " * G   ~ Represents the offset into the global offset table at which
                                                 "         the relocation entry's symbol will reside during execution.
                                                 " * L   ~ Represents the place (section offset or address) of the
                                                 "         Procedure Linkage Table entry for a symbol.
                                                 " * P   ~ Represents the place (section offset or address) of the
                                                 "         storage unit being relocated.
                                                 " * S   ~ Represents the value of the symbol whose index resides in the
                                                 "         relocation entry.
