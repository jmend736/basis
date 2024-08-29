let s:Ops = {
      \   'bss#draw#align#Center': {e -> [float2nr(e / 2), e - float2nr(e / 2)]},
      \   'bss#draw#align#Left':   {e -> [1, e - 1]},
      \   'bss#draw#align#Right':  {e -> [e - 1, 1]},
      \ }


function! bss#draw#align#RegisterMappings() abort
  vnoremap <expr> <Plug>(bss#draw#align#Center) bss#draw#align#AlignOp('bss#draw#align#Center')
  vnoremap <expr> <Plug>(bss#draw#align#Left) bss#draw#align#AlignOp('bss#draw#align#Left')
  vnoremap <expr> <Plug>(bss#draw#align#Right) bss#draw#align#AlignOp('bss#draw#align#Right')
endfunction

function! bss#draw#align#AlignOp(Op, type = '__setup__') abort
  if a:type == '__setup__'
    let &operatorfunc = function('bss#draw#align#AlignOp', [a:Op])
    return 'g@'
  endif

  for [l:line, l:part, l:PartUpdater] in bss#ops#LinePartModifiers(a:type)
    if empty(l:line)
      continue
    endif
    call l:PartUpdater(bss#draw#align#Align(l:part, ' ', s:Ops[a:Op]))
  endfor
endfunction

function! bss#draw#align#Align(part, empty_char, Lengths) abort
  let l:trimmed = trim(a:part, a:empty_char)
  let [l:left, l:right] = a:Lengths(len(a:part) - len(l:trimmed))
  return repeat(a:empty_char, l:left) .. l:trimmed .. repeat(a:empty_char, l:right)
endfunction
