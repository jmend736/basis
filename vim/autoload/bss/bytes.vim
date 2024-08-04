let s:Bytes = {}

function! bss#bytes#Bytes(blob, little_endian=v:true) abort
  let this = s:Bytes->copy()

  " The blob to read from
  let this.ptr = copy(a:blob)

  " Index of the next byte to read
  let this.loc = 0

  " Length of self.ptr
  let this.len = len(a:blob)

  " Whether to reverse order of the intervals of bytes read by
  " Bytes.ReadBytes()
  let this.little_endian = a:little_endian

  " Whether to log reads
  let this.verbose = v:false

  return this
endfunction

function! s:Bytes.ReadBytes(
      \ n,
      \ little_endian = self.little_endian) abort dict
  if self.verbose
    call printf('Reading 0x%X from 0x%X', a:n, self.loc)->bss#DumpStack()
  endif
  if a:n == 0
    return 0z
  elseif a:n < 0
    throw $'ERROR(InvalidArguments): n must be positive, got {a:n}'
  else " a:n > 0
    let new_loc = self.loc + a:n
    let l:bytes = self.ptr[self.loc:(new_loc - 1)]
    let self.loc = new_loc
    return a:little_endian ? reverse(l:bytes) : l:bytes
  endif
endfunction

function! s:Bytes.ReadByte() abort dict
  return self.ReadBytes(1)
endfunction

function! s:Bytes.Read() abort dict
  let byte = self.ReadBytes(1)
  return len(byte) ? byte[0] : 0
endfunction

function! s:Bytes.Seek(n) abort dict
  if a:n < 0 || a:n >= self.len
    throw 'ERROR(InvalidArguments): Invalid index'
  endif
  let self.loc = a:n
  return self
endfunction

function! s:Bytes.SeekNew(n) abort dict
  if a:n < 0 || a:n >= self.len
    throw 'ERROR(InvalidArguments): Invalid index'
  endif
  return self->extendnew({'loc': a:n})
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

function! s:Bytes.AsciiNull() abort dict
  let l:index = self.FindNext(0x00)
  let l:bytes = self.ReadBytes(l:index - self.loc + 1, v:false)
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

function! s:Bytes.FindNext(search) abort dict
  let l:index = self.ptr->index(a:search, self.loc)
  if l:index == -1
    throw $'ERROR(IllegalState): FindNext failed to find '
          \ .. $'{printf("0x%02X", a:search)} at/after index '
          \ .. $'{self.loc}.'
  endif
  return l:index
endfunction

if exists('g:bss_bytes_test')
  let v:errors = []

  let b = bss#bytes#Bytes(0z00FF, v:false)
  call assert_equal(0z,   b.ReadBytes(0))
  call assert_equal(0z00, b.ReadBytes(1))
  call assert_equal(0zFF, b.ReadBytes(1))

  let b = bss#bytes#Bytes(0zABCD, v:true)
  call assert_equal(0z,   b.ReadBytes(0))
  call assert_equal(0zAB, b.ReadBytes(1))
  call assert_equal(0zCD, b.ReadBytes(1))

  let b = bss#bytes#Bytes(0zABCDEF01, v:false)
  call assert_equal(0z,     b.ReadBytes(0))
  call assert_equal(0zABCD, b.ReadBytes(2))
  call assert_equal(0zEF01, b.ReadBytes(2))

  let b = bss#bytes#Bytes(0zABCDEF01, v:true)
  call assert_equal(0z,     b.ReadBytes(0))
  call assert_equal(0zCDAB, b.ReadBytes(2))
  call assert_equal(0z01EF, b.ReadBytes(2))
  call assert_equal(0z,     b.ReadBytes(2))

  let b = bss#bytes#Bytes(0zABCDEF01)
  silent! call assert_fails('call b.FindNext(0x00)')
  call assert_equal(0, b.FindNext(0xAB))
  call assert_equal(0, b.FindNext(0xAB)) " Does not advance

  let b = bss#bytes#Bytes(0z4C4F4C00)
  call assert_equal("LOL", b.AsciiNull())

  let b = bss#bytes#Bytes(0z00)
  call assert_equal("", b.AsciiNull())

  if empty(v:errors)
    echo ">>> PASSED"
  else
    echo ">>> FAILED"
    echo ">>> " v:errors->join("\n>>> ")
  endif
endif
