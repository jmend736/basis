let s:Bytes = {'ptr': v:t_blob, 'root': v:t_blob}

function! bss#java#bytes#Bytes(fname) abort
  let l:bytes = readfile(a:fname, 'B')
  return bss#Typed(s:Bytes,
        \  {'ptr': l:bytes, 'root': copy(l:bytes)})
endfunction

function! bss#java#bytes#Jar(fname) abort
  let l:files = systemlist('unzip -Z1 ' .. a:fname)
  let l:archive = {}
  for l:file in l:files->filter('v:val =~# "\.class$"')
    let l:job = job_start(
          \ 'unzip -p ' .. a:fname .. ' ' .. l:file,
          \ {'out_mode': 'raw'})
    let l:bytes = ch_readblob(l:job)
    let l:archive[l:file] = bss#Typed(s:Bytes,
        \  {'ptr': l:bytes, 'root': copy(l:bytes)})
  endfor
  return l:archive
endfunction

" Read n bytes off the front of the blob
function! s:Bytes.Read(n) abort dict
  if a:n == 0
    return 0z
  endif
  return remove(self.ptr, 0, a:n - 1)
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
