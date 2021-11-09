function! bss#view#View(...) abort
  return copy(s:View)
endfunction

let s:View = {
      \   'bufnr': v:none,
      \   'winid': v:none,
      \   'options': [],
      \ }

function! s:View.AddOption(opt) abort dict
  call add(self.options, opt)
endfunction

function! s:View.GoToWindow() abort
  if self.bufnr is v:none
        \ || self.winid is v:none
        \ || winbufnr(self.winid) != self.bufnr
    botright 10 new
    call self->s:ApplyOptions()
  else
    call win_gotoid(self.winid)
  endif
  return self
endfunction

function! s:ApplyOptions(view) abort
  for l:opt in a:view.options
    execute printf('setlocal %s', l:opt)
  endfor
endfunction
