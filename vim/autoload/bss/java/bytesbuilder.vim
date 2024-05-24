let s:BytesBuilder = #{
      \   ptr: v:t_blob,
      \ }

function! bss#java#bytesbuilder#Create() abort
  return copy(s:BytesBuilder)->extend(#{
        \   ptr: 0z,
        \ })
endfunction

function! s:BytesBuilder.Bytes() abort dict
  return copy(self.ptr)
endfunction

function! s:BytesBuilder.U1(n) abort dict
  let self.ptr += bss#java#bytesbuilder#U1(a:n)
  return self
endfunction

function! s:BytesBuilder.U2(n) abort dict
  let self.ptr += bss#java#bytesbuilder#U2(a:n)
  return self
endfunction

function! s:BytesBuilder.U4(n) abort dict
  let self.ptr += bss#java#bytesbuilder#U4(a:n)
  return self
endfunction

function! s:BytesBuilder.U8(n) abort dict
  let self.ptr += bss#java#bytesbuilder#U8(a:n)
  return self
endfunction

function! bss#java#bytesbuilder#U8(n) abort
  call s:check_bounds(a:n, 0, 0x7FFFFFFFFFFFFFFF)
  return 0z
        \->add(and(0x7F00000000000000, a:n) >> 56)
        \->add(and(0x00FF000000000000, a:n) >> 48)
        \->add(and(0x0000FF0000000000, a:n) >> 40)
        \->add(and(0x000000FF00000000, a:n) >> 32)
        \->add(and(0x00000000FF000000, a:n) >> 24)
        \->add(and(0x0000000000FF0000, a:n) >> 16)
        \->add(and(0x000000000000FF00, a:n) >> 8)
        \->add(and(0x00000000000000FF, a:n) >> 0)
endfunction

function! bss#java#bytesbuilder#U4(n) abort
  call s:check_bounds(a:n, 0, 0xFFFFFFFF)
  return 0z
        \->add(and(0xFF000000, a:n) >> 24)
        \->add(and(0x00FF0000, a:n) >> 16)
        \->add(and(0x0000FF00, a:n) >> 8)
        \->add(and(0x000000FF, a:n) >> 0)
endfunction

function! bss#java#bytesbuilder#U2(n) abort
  call s:check_bounds(a:n, 0, 0xFFFF)
  return 0z
        \->add(and(0xFF00, a:n) >> 8)
        \->add(and(0x00FF, a:n) >> 0)
endfunction

function! bss#java#bytesbuilder#U1(n) abort
  call s:check_bounds(a:n, 0, 0xFF)
  return 0z
        \->add(and(0xFF, a:n) >> 0)
endfunction

function! s:check_bounds(value, min, max) abort
  if a:value < a:min || a:value > a:max
    throw printf(
          \   'ERROR(InvalidArguments): %s is not in bounds [%s, %s]',
          \    a:value,
          \    a:min,
          \    a:max)
  endif
endfunction
