function! bss#draw#align#Center(begin="'<", end="'>", empty_char=' ') abort
  return bss#draw#align#Align(
        \ getline('.')[col(a:begin)-1:col(a:end)-1],
        \ a:empty_char,
        \ {e -> [float2nr(e / 2), e - float2nr(e / 2)]})
endfunction

function! bss#draw#align#Left(begin="'<", end="'>", empty_char=' ', gap=1) abort
  return bss#draw#align#Align(
        \ getline('.')[col(a:begin)-1:col(a:end)-1],
        \ a:empty_char,
        \ {e -> [1, e - 1]})
endfunction

function! bss#draw#align#Right(begin="'<", end="'>", empty_char=' ', gap=1) abort
  return bss#draw#align#Align(
        \ getline('.')[col(a:begin)-1:col(a:end)-1],
        \ a:empty_char,
        \ {e -> [e - 1, 1]})
endfunction

function! bss#draw#align#Align(part, empty_char, Lengths) abort
  let l:trimmed = trim(a:part, a:empty_char)
  let [l:left, l:right] = a:Lengths(len(a:part) - len(l:trimmed))
  return repeat(a:empty_char, l:left) .. l:trimmed .. repeat(a:empty_char, l:right)
endfunction
