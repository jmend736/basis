""
" Render 
"
function! bss#draw#elems#Box(width, height) abort
  let l:chars = #{v: '|', h: '-', c: '+', e: ' '}
  let l:top_bot = l:chars.c .. repeat(l:chars.h, a:width) .. l:chars.c
  let l:mid = l:chars.v .. repeat(l:chars.e, a:width) .. l:chars.v
  return [l:top_bot] + repeat([l:mid], a:height) + [l:top_bot]
endfunction


call append('.', bss#draw#elems#Box(10, 1))
