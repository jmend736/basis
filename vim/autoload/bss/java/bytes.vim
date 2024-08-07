let s:Bytes = {'ptr': v:t_blob}

function! bss#java#bytes#Bytes(fname) abort
  let l:bytes = readfile(a:fname, 'B')
  return bss#Typed(s:Bytes,
        \  {'ptr': l:bytes})
endfunction

function! bss#java#bytes#BytesRaw(bytes) abort
  return bss#Typed(s:Bytes,
        \  {'ptr': a:bytes})
endfunction

function! bss#java#bytes#Jar(fname) abort
  let l:temp = tempname()
  call system('mkdir -p ' .. l:temp)
  call system(printf(
        \   'unzip %s -d %s',
        \   a:fname,
        \   l:temp
        \ ))
  let l:files = globpath(l:temp, '**/*.class', v:false, v:true)
  let l:archive = {}
  for l:file in l:files
    let l:archive[l:file] = bss#java#bytes#Bytes(l:file)
  endfor
  call delete(l:temp, 'rf')
  return l:archive
endfunction

" Read n bytes off the front of the blob
function! s:Bytes.Read(n) abort dict
  if a:n == 0
    return 0z
  endif
  if a:n >= self.Length()
    return remove(self.ptr, 0, self.Length() - 1)
  endif
  return remove(self.ptr, 0, a:n - 1)
endfunction

" Read n bytes off the front of the blob
function! s:Bytes.TryRead(n) abort dict
  if a:n == 0
    return {'ok': v:true, 'result': 0z}
  endif
  if a:n >= self.Length()
    return {'ok': v:false, 'result': v:none}
  endif
  return {'ok': v:true, 'result': remove(self.ptr, 0, a:n - 1)}
endfunction

" Whether there are more bytes to read
function! s:Bytes.HasMore() abort dict
  return len(self.ptr) > 0
endfunction

" Number of bytes left
function! s:Bytes.Length() abort dict
  return len(self.ptr)
endfunction

" Read n bytes off the front of the blob, and ensure that it has the value
" {expected}.
function! s:Bytes.ReadExpected(n, expected) abort dict
  let l:result = self.Read(a:n)
  if l:result != a:expected
    throw 'ERROR(Unexpected): Expected '
          \ .. string(a:expected)
          \ .. ' but got ' .. string(l:result)
  endif
  return l:result
endfunction

" Read 4 bytes and convert them to the equivalent signed 4-byte integer
function! s:Bytes.I4() abort dict
  let l:parts = self.Read(4)
  let l:negative = (and(l:parts[0], 0x80) > 0) ? -(256*256*256*128) : 0
  let l:result = l:negative + l:parts[3]
        \ + (l:parts[2] * 256)
        \ + (l:parts[1] * 256 * 256)
        \ + (and(l:parts[0], 0x7F) * 256 * 256 * 256)
  return l:result
endfunction

" Read 4 bytes and convert them to the equivalent U4 integer
function! s:Bytes.U4() abort dict
  let l:parts = self.Read(4)
  let l:result = l:parts[3]
        \ + (l:parts[2] * 256)
        \ + (l:parts[1] * 256 * 256)
        \ + (l:parts[0] * 256 * 256 * 256)
  return l:result
endfunction

" Read 2 bytes and convert them to the equivalent U4 integer
function! s:Bytes.U2() abort dict
  let l:parts = self.Read(2)
  let l:result = l:parts[1]
        \ + (l:parts[0] * 256)
  return l:result
endfunction

" Read 1 bytes and convert them to the equivalent U4 integer
function! s:Bytes.U1() abort dict
  let l:parts = self.Read(1)
  return l:parts[0]
endfunction

function! s:Bytes.Idx() abort dict
  return {'&': self.U2()}
endfunction

function! s:Bytes.Utf8() abort dict
  let l:length = self.U2()
  let l:bytes = self.Read(l:length)

  let l:value = ''

  for b in l:bytes
    if xor(0x80, b)
      let l:value ..= nr2char(b)
      continue
    endif
    " Don't worry about the other possibilities for now
    " TODO: Add them...
    throw 'ERROR(IllegalState): Invalid UTF 8 Byte: ' .. b
  endfor

  return l:value
endfunction
