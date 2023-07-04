let s:Cursor = bss#Type({
      \   'Restore': v:t_func,
      \ })

function! bss#cursor#Save() abort
  let l:winid = win_getid()
  let l:view = winsaveview()
  return s:Cursor({'Restore': { -> win_gotoid(l:winid) && winrestview(l:view) }})
endfunction

function! bss#cursor#SaveWithBuf() abort
  let l:winid = win_getid()
  let l:bufnr = bufnr('')
  let l:view = winsaveview()
  return s:Cursor({'Restore': { -> win_gotoid(l:winid) && execute('buffer ' .. l:bufnr) && winrestview(l:view) }})
endfunction
