let s:Bytes = {}

function! bss#elf#bytes#Bytes(blob, little_endian=v:true, size=8) abort
  return bss#bytes#Bytes(a:blob, a:little_endian)
        \->extendnew(s:Bytes)
        \->extend({
        \   'size': a:size,
        \ })
endfunction

function! bss#elf#bytes#File(fname) abort
  return bss#elf#bytes#Bytes(readblob(a:fname))
endfunction

function! bss#elf#bytes#Blob(blob) abort
  return bss#elf#bytes#Bytes(copy(a:blob))
endfunction

function! s:Bytes.Addr() abort
  return self.U(self.size)
endfunction

function! s:Bytes.Off() abort
  return self.U(self.size)
endfunction

function! s:Bytes.Half() abort
  return self.U(self.size / 4)
endfunction

function! s:Bytes.Word() abort
  return self.U(self.size / 2)
endfunction

function! s:Bytes.Sword() abort
  return self.S(self.size / 2)
endfunction

function! s:Bytes.Xword() abort
  return self.U(self.size)
endfunction

function! s:Bytes.Sxword() abort
  return self.S(self.size)
endfunction

if v:false
  let v:errors = []

  let B = function('bss#elf#bytes#Blob')
  let E = { -> bss#elf#bytes#Blob(0z) }

  call assert_equal(0, E().U(1))

  let b = B(0z1265)
  call assert_equal(0x12, b.U(1))
  call assert_equal(0x65, b.U(1))
  call assert_equal(0x00, b.U(1))
  call assert_equal(0x00, b.U(1))

  let b = bss#elf#bytes#Bytes(0z1265, v:false)
  call assert_equal(0x1265, b.U(2))

  let b = bss#elf#bytes#Bytes(0z1265, v:true)
  call assert_equal(0x6512, b.U(2))

  let b = bss#elf#bytes#Bytes(0z1265FF00, v:true)
  call assert_equal(0x00FF6512, b.U(4))


  if empty(v:errors)
    echom "TESTS PASSED"
  else
    for error in v:errors
      echo error
    endfor
  endif
endif
