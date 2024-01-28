function! bss#doc#AlignTags() abort
  let l:line = getline('.')
  "                                |-before||-tags---------|
  let l:match = matchlist(l:line, '\(.\{-}\)\(\*.*\*\s\?\)\+')
  if empty(l:match)
    return
  endif
  let [l:value, l:before, l:tags; l:rest] = l:match
  "                                  |-cont--||-sep----|
  let l:match = matchlist(l:before, '\(.\{-}\)\(\s\s*\)$')
  if empty(l:match)
    return
  endif
  let [l:value, l:cont, l:sep; l:rest] = l:match

  let l:width = &textwidth
  let l:width -= len(l:cont) - count(str2list(l:cont), char2nr('|'))
  let l:width -= len(l:tags) - count(str2list(l:tags), char2nr('*'))

  call setline('.', join([l:cont, repeat(' ', l:width), l:tags], ''))
endfunction
