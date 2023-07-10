" Example: set foldexpr=bss#fond#FromString('{}[]')
"          set foldmethod=expr
"
" Even indices correspond to increases of fold, odd indices correspond to
" decreases of fold.
function! bss#fold#FromString(types) abort
  let l:line = getline(v:lnum)
  let l:idx = stridx(a:types, l:line[len(l:line) - 1])
  if l:idx == -1
    return '='
  elseif l:idx % 2 == 0
    return 'a1'
  else
    return 's1'
  endif
endfunction
