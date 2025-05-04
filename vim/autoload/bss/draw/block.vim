function! bss#draw#block#RegisterCommands() abort
  command! -range -nargs=? Center call bss#draw#block#Center(<line1>, <line2>, <q-args>)
endfunction

function! bss#draw#block#Center(line1, line2, width) abort
  " Text width to fit everything into
  let l:text_width =
        \ (len(a:width) != 0)
        \ ? str2nr(a:width)
        \ : ((&textwidth == 0) ? 72 : &textwidth)

  " Line content
  let l:lines         = getline(a:line1, a:line2)
  let l:trimmed_lines = l:lines->mapnew('trim(v:val)')

  " Width calculations
  let l:widths = l:trimmed_lines->mapnew('strdisplaywidth(v:val)')
  let l:max_width  = max(l:widths)
  let l:line_padding = l:widths->mapnew('l:max_width - v:val')

  let l:padding = (l:text_width - l:max_width) / 2

  if l:padding <= 0
    return
  endif

  let l:new_lines = l:trimmed_lines
        \->mapnew({i, line -> repeat(' ', l:padding + l:line_padding[i]) .. line})

  call setline(a:line1, l:new_lines)
endfunction
