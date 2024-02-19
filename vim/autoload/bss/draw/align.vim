function! bss#draw#align#AlignOp(Op, type = '__setup__') abort
  if a:type == '__setup__'
    let &operatorfunc = function('bss#draw#align#AlignOp', [a:Op])
    return 'g@'
  endif

  let l:first_lnum = line("'[")
  let l:last_lnum  = line("']")
  let l:ranges = copy(range(l:first_lnum, l:last_lnum))->map('[v:val, 0, -1]')
  if a:type == 'char'
    let l:pos = getpos("'[")
    let l:ranges[l:pos[1] - l:first_lnum][1] = l:pos[2]
    let l:pos = getpos("']")
    let l:ranges[l:pos[1] - l:first_lnum][2] = l:pos[2]
  elseif a:type == 'block'
    let l:range = [col("'["), col("']")]
    call map(l:ranges, { v -> extend([v[0]], copy(l:range)) })
  endif

  for [l:lnum, l:start_col, l:end_col] in l:ranges
    let l:line      = getline(l:lnum)
    let l:start_idx = max([l:start_col - 1, 0])
    let l:end_idx   = max([l:end_col - 1, -1])
    let l:part      = l:line[l:start_idx:l:end_idx]
    let l:newpart   = call(a:Op, [l:part])
    let l:left      = (l:start_idx != 0) ? l:line[:l:start_idx - 1] : ''
    let l:right     = (l:end_idx != -1)  ? l:line[l:end_idx + 1:] : ''
    let l:newline   = l:left .. l:newpart .. l:right
    call setline(l:lnum, l:newline)
  endfor
endfunction

function! bss#draw#align#Center(part, empty_char=' ') abort
  return bss#draw#align#Align(
        \ a:part,
        \ a:empty_char,
        \ {e -> [float2nr(e / 2), e - float2nr(e / 2)]})
endfunction

function! bss#draw#align#Left(part, empty_char=' ', gap=1) abort
  return bss#draw#align#Align(
        \ a:part,
        \ a:empty_char,
        \ {e -> [1, e - 1]})
endfunction

function! bss#draw#align#Right(part, empty_char=' ', gap=1) abort
  return bss#draw#align#Align(
        \ a:part,
        \ a:empty_char,
        \ {e -> [e - 1, 1]})
endfunction

function! bss#draw#align#Align(part, empty_char, Lengths) abort
  let l:trimmed = trim(a:part, a:empty_char)
  let [l:left, l:right] = a:Lengths(len(a:part) - len(l:trimmed))
  return repeat(a:empty_char, l:left) .. l:trimmed .. repeat(a:empty_char, l:right)
endfunction
