let s:Bytes = {}

function! bss#bytes#Bytes(blob, little_endian=v:true) abort
  return s:Bytes->extendnew({
        \   'loc'           : 0,
        \   'ptr'           : copy(a:blob),
        \   'all'           : a:blob,
        \   'little_endian' : a:little_endian,
        \   'verbose'       : v:false,
        \ })
endfunction

function! bss#bytes#File(fname) abort
  return bss#bytes#Bytes(readblob(a:fname))
endfunction

function! bss#bytes#Blob(blob) abort
  return bss#bytes#Bytes(copy(a:blob))
endfunction

function! s:Bytes.ReadBytes(n, little_endian = self.little_endian) abort dict
  if self.verbose | echom printf('Reading 0x%X from 0x%X', a:n, self.loc) | endif
  let self.loc += a:n
  let l:bytes = a:n > 0 && len(self.ptr) >= a:n ? remove(self.ptr, 0, a:n-1) : 0z
  return a:little_endian ? reverse(l:bytes) : l:bytes
endfunction

function! s:Bytes.ReadByte() abort dict
  return self.ReadBytes(1)
endfunction

function! s:Bytes.Read() abort dict
  return len(self.ptr) ? self.ReadBytes(1)[0] : 0
endfunction

function! s:Bytes.From(n) abort dict
  return bss#bytes#Bytes(self.all[a:n:], self.little_endian)
endfunction

function! s:Bytes.U(n) abort dict
  if a:n == 1
    return self.Read()
  else
    return self.ReadBytes(a:n)
          \->blob2list()
          \->map({i, v -> v*float2nr(pow(256, a:n - 1 - i))})
          \->reduce({a, b -> a + b}, 0)
  endif
endfunction

function! s:Bytes.Ascii(n) abort dict
  let l:length = a:n
  let l:bytes = self.ReadBytes(l:length, v:false)
  let l:value = ''
  for b in l:bytes
    if xor(0x80, b)
      let l:value ..= nr2char(b)
      continue
    endif
    throw 'ERROR(IllegalState): Invalid ASCII Byte: ' .. b
  endfor
  return l:value
endfunction

function! s:Bytes.AsciiNull() abort dict
  let l:length = self.ptr->index(0x00)
  if l:length == -1
    throw 'ERROR(IllegalState): Null byte not found'
  endif
  let l:bytes = self.ReadBytes(l:length + 1, v:false)
  let l:value = ''
  for b in l:bytes[:-2]
    if xor(0x80, b)
      let l:value ..= nr2char(b)
      continue
    endif
    throw 'ERROR(IllegalState): Invalid ASCII Byte: ' .. b
  endfor
  return l:value
endfunction
