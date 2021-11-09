function! bss#cursor#Save() abort
  let l:winid = win_getid()
  let l:view = winsaveview()
  return {'Restore': { -> win_gotoid(l:winid) && winrestview(l:view) }}
endfunction
