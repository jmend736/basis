function! bss#draw#block#RegisterCommands() abort
  command! -range -nargs=? Center call bss#draw#block#Center(<line1>, <line2>, <q-args>)
  "command! -range -nargs=? Left call bss#draw#block#Left(<line1>, <line2>, <q-args>)
  "command! -range -nargs=? Right call bss#draw#block#Right(<line1>, <line2>, <q-args>)
endfunction

function! bss#draw#block#Center(line1, line2, width) abort
  call bss#draw#block#Align(a:line1, a:line2, a:width, {tw, extent -> (tw - extent) / 2})
endfunction

"function! bss#draw#block#Left(line1, line2, width) abort
"  call bss#draw#block#Align(a:line1, a:line2, a:width, {tw, extent -> a:width})
"endfunction
"
"function! bss#draw#block#Right(line1, line2, width) abort
"  call bss#draw#block#Align(a:line1, a:line2, a:width, {tw, extent -> tw - extent})
"endfunction

function! bss#draw#block#Align(line1, line2, width, Padding) abort
  " Text width to fit everything into
  let l:text_width =
        \ (len(a:width) != 0)
        \ ? str2nr(a:width)
        \ : ((&textwidth == 0) ? 72 : &textwidth)

  " Line content
  let l:lines         = getline(a:line1, a:line2)
  let l:trimmed_lines = l:lines->mapnew({_, line -> {
        \   "content": trim(line),
        \   "trim": strdisplaywidth(line) - strdisplaywidth(trim(line))
        \ }})

  " Extent/padding calculation
  let l:min_trim = l:trimmed_lines->mapnew('v:val.trim')->filter('v:val > 0')->min()
  let l:max_line = l:trimmed_lines->mapnew('v:val.trim + strdisplaywidth(v:val.content)')->max()
  let l:extent   = l:max_line - l:min_trim
  "let l:padding  = (l:text_width - l:extent) / 2
  let l:padding  = a:Padding(l:text_width, l:extent)

  if l:padding <= 0
    return
  endif

  let l:new_lines = l:trimmed_lines
        \->mapnew({_, line -> empty(line.content) ? '' : repeat(' ', l:padding + (line.trim - l:min_trim)) .. line.content})

  call setline(a:line1, l:new_lines)
endfunction
