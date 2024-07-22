"
" bss#view#View({args})
"   Create a new unopened view
"
" bss#view#TermView([args])
"   Create a new unopened view, oriented towards being :term output
"
" bss#view#ScratchView([args])
"   Create a new unopened view, for scratch work
"
" bss#view#DataView({data}, with_methods = v:true)
"   Create a new opened view, for scratch work
"
" {args}:
"   Used to extend s:View
"

let s:View = {
      \   'bufnr'   : v:none,
      \   'winid'   : v:none,
      \   'options' : [],
      \   'vars'    : {},
      \ }

function! bss#view#View(...) abort
  let instance = deepcopy(s:View)
  return mapnew(a:000, {i, args -> instance.Extend(args)})[-1]
endfunction

function! bss#view#TermView(args = {}) abort
  return bss#view#View({
        \   'options': [
        \     'nobuflisted',
        \     'winfixwidth',
        \     'nonumber',
        \     'norelativenumber',
        \   ],
        \ },
        \ a:args)
endfunction

function! bss#view#ScratchView(args = {}) abort
  return bss#view#View({
        \   'options': [
        \     'bufhidden=wipe',
        \     'buftype=nofile',
        \     'noswapfile',
        \     'nobuflisted',
        \     'winfixwidth',
        \     'nonumber',
        \     'norelativenumber',
        \   ],
        \ },
        \ a:args)
endfunction

function! bss#view#DataView(data, with_methods = v:false) abort
  let l:view = bss#view#ScratchView({
        \   'options': [
        \     'ft=vim',
        \     'foldmethod=expr',
        \     "foldexpr=bss#fold#FromString('{}[]')",
        \     'foldcolumn=4'
        \   ]
        \ })
  eval l:view
        \.Open()
        \.SetLines(bss#pretty#PPLines(a:data, a:with_methods))
  return l:view
endfunction

function! bss#view#JsonView(json, with_methods = v:false) abort
  return bss#view#DataView(json_decode(a:json))
endfunction

function! s:View.Extend(args) abort dict
  if has_key(a:args, 'bufnr')
    let self.bufnr = a:args.bufnr
  endif
  if has_key(a:args, 'winid')
    let self.winid = a:args.winid
  endif
  if has_key(a:args, 'options')
    eval self.options->extend(a:args.options)
  endif
  if has_key(a:args, 'vars')
    eval self.vars->extend(a:args.vars)
  endif
  return self
endfunction

function! s:View.Open() abort dict
  let l:cursor = bss#cursor#Save()
  try
    call self.GoToWindow()
  finally
    call l:cursor.Restore()
  endtry
  return self
endfunction

function! s:View.Setup() abort dict
  for l:opt in self.options
    execute printf('setlocal %s', l:opt)
  endfor
  for [l:key, l:value] in items(self.vars)
    let b:[l:key] = l:value
  endfor
endfunction

function! s:View.IsValid() abort dict
  return self.bufnr isnot v:none
        \ && self.winid isnot v:none
        \ && winbufnr(self.winid) == self.bufnr
endfunction

function! s:View.CheckValid(name) abort dict
  let l:valid = self.IsValid()
  if !l:valid
    throw "ERROR(InvalidView): " .. a:name .. " must be called while view is valid!"
  end
  return l:valid
endfunction

function! s:View.GoToWindow() abort
  if !self.IsValid()
    botright 10 new
    call self.Setup()
    let self.bufnr = bufnr('')
    let self.winid = win_getid()
  else
    call win_gotoid(self.winid)
  endif
  return self
endfunction

function! s:View.Run(cmd) abort dict
  let l:cmd = empty(a:cmd) ? [&shell] : a:cmd
  let l:cursor = bss#cursor#Save()
  try
    call self.GoToWindow()
    call term_start(l:cmd, {'curwin': v:true})
    call self.Setup()
    let self.bufnr = bufnr('')
    let self.winid = win_getid()
  finally
    call l:cursor.Restore()
  endtry
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

function! s:View.Call(Fn, ...) abort
  let l:cursor = bss#cursor#Save()
  try
    call self.GoToWindow()
    call call(a:Fn, a:000)
  finally
    call l:cursor.Restore()
  endtry
  return self
endfunction

function! s:View.Append(msg) abort
  if self.CheckValid("View.Append()")
    call appendbufline(self.bufnr, line('$', self.winid), a:msg)
  endif
  return self
endfunction

function! s:View.SetBufVar(varname, value) abort dict
  if self.CheckValid("View.SetBufVar()")
    call setbufvar(self.bufnr, a:varname, a:value)
  endif
  return self
endfunction

function! s:View.SetBufVars(vars) abort dict
  if self.CheckValid("View.SetBufVars()")
    for [name, value] in items(a:vars)
      call setbufvar(self.bufnr, name, value)
    endfor
  endif
  return self
endfunction

function! s:View.Clear() abort
  if self.CheckValid("View.Clear()")
    call deletebufline(self.bufnr, 1, line('$', self.winid))
  endif
  return self
endfunction

function! s:View.SetLines(lines) abort
  if self.CheckValid("View.SetLines()")
    call deletebufline(self.bufnr, 1, line('$', self.winid))
    call appendbufline(self.bufnr, 1, a:lines)
    call deletebufline(self.bufnr, 1)
  endif
  return self
endfunction

function! s:View.Get(name) abort
  if self.CheckValid("View.Get()")
    return getbufvar(self.bufnr, a:name, v:none)
  endif
  return v:none
endfunction
