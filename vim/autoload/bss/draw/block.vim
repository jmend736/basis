function! bss#draw#block#RegisterCommands() abort
  command! -range -nargs=? Center call bss#draw#block#Center(<line1>, <line2>, <q-args>)
endfunction

function! bss#draw#block#Center(line1, line2, width) abort
  let lines     = getline(a:line1, a:line2)
  let widths    = lines->mapnew('strdisplaywidth(v:val)')
  let max_width = max(widths)
  let textwidth =
        \ (len(a:width) != 0)
        \ ? str2nr(a:width)
        \ : ((&textwidth == 0) ? 72 : &textwidth)

  let padding = (textwidth - max_width) / 2

  if padding <= 0
    return
  endif

  eval lines->map('repeat(" ", padding) .. v:val')
  call setline(a:line1, lines)
endfunction
