function! bss#view#View(...) abort
  return extend(copy(s:View), get(a:, 0, {}))
endfunction

function! bss#view#TermView() abort
  return bss#view#View({
        \   'options': [
        \     'nobuflisted',
        \     'winfixwidth',
        \     'nonumber',
        \     'norelativenumber',
        \   ],
        \ })
endfunction

let s:View = {
      \   'bufnr': v:none,
      \   'winid': v:none,
      \   'options': [],
      \ }

function! s:View.AddOption(opt) abort dict
  call add(self.options, opt)
endfunction

function! s:View.ApplyOptions() abort dict
  for l:opt in self.options
    execute printf('setlocal %s', l:opt)
  endfor
endfunction

function! s:View.GoToWindow() abort
  if self.bufnr is v:none
        \ || self.winid is v:none
        \ || winbufnr(self.winid) != self.bufnr
    botright 10 new
    call self.ApplyOptions()
  else
    call win_gotoid(self.winid)
  endif
  return self
endfunction

function! s:View.Run(cmd) abort dict
  let l:cmd = empty(a:cmd)
        \ ? [&shell]
        \ : (type(a:cmd) is v:t_list) ? a:cmd : split(a:cmd)
  let l:cursor = bss#cursor#Save()
  try
    call self.GoToWindow()
    call term_start(l:args, {'curwin': v:true})
    call self.ApplyOptions()
  finally
    call l:cursor.Restore()
  end
  return self
endfunction

function! s:View.Exec(cmd) abort
  let l:cursor = bss#cursor#Save() 
  try
    call self.GoToWindow()
    call execute(a:cmd)
  finally
    call l:cursor.Restore()
  endtry
  return self
endfunction
