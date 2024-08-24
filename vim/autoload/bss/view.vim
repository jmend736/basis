"
" bss#view#View([args]...)
"   Creates a new unopened view
"
" bss#view#TermView([args]...)
"   Creates a new unopened view, oriented towards being :term output
"
" bss#view#ScratchView([args]...)
"   Creates a new unopened view, for scratch work
"
" bss#view#DataView({data}, with_methods = v:true)
"   Creates a new opened view, for scratch work
"
" {args}:
"   Pattern:
"     {
"       'bufnr'   : ( <bufnr> | 'current' ),
"       'winid'   : ( <winid> | 'current' ),
"       'options' : list<string>,
"       'vars'    : dict<string, any>,
"     }
"
" Buffer/Window Operations:
"
"   s:View.Open()
"     Ensures buf/win are open and valid, and, preserves cursor.
"
"   s:View.Setup()
"     Configures the current buffer's options and variables.
"
" Buffer/Window Execution:
"
"   s:View.Run({cmd})
"     Runs :term {cmd} using View for output.
"
"   s:View.Exec({src})
"     Runs :execute {src} while cursor is in View.
"
"   s:View.Call({Fn}, [args]...)
"     Calls {Fn} with {args} while cursor is in View.
"
"
" Buffer Operations:
"
"   s:View.SetLines({lines})
"     Replaces all lines View's buffer with {lines}.
"
"   s:View.Append({line})
"     Appends lines {line} to buffer
"
"   s:View.Append([{line}...])
"     Appends all lines [{line}...] to buffer
"
"   s:View.AppendPretty({expr})
"     Appends pretty printed likes of {expr} to buffer
"
"   s:View.Clear()
"     Clear all lines in View's buffer
"
"
" Buffer Variable:
"
"   s:View.Get({name}, [default])
"     Get b:{name} (or [default]) from View's buffer.
"
"   s:View.Set({name}, {value})
"     Sets b:{name} to {value} for View.
"
"   s:View.SetAll({vars})
"     Extends View's b: dict with {vars}.
"
"   s:View.Compute({name}, {Fn(name, value | v:none)})
"     Computes the value of b:{name}
"
"   s:View.ComputeIfPresent({name}, {Fn(name, value | v:none)})
"     Computes the value of b:{name} only if it's present
"
"   s:View.ComputeIfAbsent({name}, {Fn(name)})
"     Computes the value of b:{name} only if it's missing
"
" internal:
"
"   s:View.Extend({args})
"     Extend the View{} instance.
"
"   s:View.IsValid()
"     Configures the buffer's options and variables.
"
"   s:View.GoToWindow()
"     Moves cursor to View's window, creating & configuring the window if none
"     exists.
"

let s:View = {
      \   'bufnr'   : v:none,
      \   'winid'   : v:none,
      \   'options' : [],
      \   'vars'    : {},
      \ }

function! bss#view#View(...) abort
  let instance = deepcopy(s:View)
  for args in a:000
    call instance.Extend(args)
  endfor
  return instance
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
    if a:args.bufnr ==# 'current'
      let self.bufnr = bufnr('%')
    else
      let self.bufnr = a:args.bufnr
    endif
  endif
  if has_key(a:args, 'winid')
    if a:args.winid ==# 'current'
      let self.winid = win_getid()
    else
      let self.winid = a:args.winid
    endif
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
    throw "ERROR(InvalidView): " .. a:name .. " must be called while view is valid! (Call s:View.Open())"
  end
  return l:valid
endfunction

function! s:View.UseCurrent() abort dict
  call self.Setup()
  let self.bufnr = bufnr('')
  let self.winid = win_getid()
  return self
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
  if type(l:cmd) is v:t_string
    let l:cmd = substitute(l:cmd, "%", expand("%"), "a")
  endif
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
    let l:lines = execute(a:cmd)->split("\n")
    call self.Append(l:lines)
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

function! s:View.Append(line_or_lines) abort
  if self.CheckValid("View.Append()")
    call appendbufline(
          \ self.bufnr,
          \ line('$', self.winid),
          \ a:line_or_lines)
  endif
  return self
endfunction

function! s:View.AppendPretty(expr) abort
  if self.CheckValid("View.AppendPretty()")
    call appendbufline(
          \ self.bufnr,
          \ line('$', self.winid),
          \ bss#pretty#PPLines(a:expr))
  endif
  return self
endfunction

function! s:View.Get(name, default=v:none) abort
  if self.CheckValid("View.Get()")
    return getbufvar(self.bufnr, a:name, a:default)
  endif
  return v:none
endfunction

function! s:View.Set(name, value) abort dict
  if self.CheckValid("View.Set()")
    call setbufvar(self.bufnr, a:name, a:value)
  endif
  return self
endfunction

function! s:View.Compute(name, Fn_name_value) abort dict
  if self.CheckValid("View.Compute()")
    let l:value = getbufvar(self.bufnr, a:name, v:none)
    call setbufvar(self.bufnr, a:name, a:Fn_name_value(a:name, l:value))
  endif
  return self
endfunction

function! s:View.ComputeIfAbsent(name, Fn_name) abort dict
  if self.CheckValid("View.ComputeIfAbsent()")
    let l:value = getbufvar(self.bufnr, a:name, v:none)
    if l:value is v:none
      call setbufvar(self.bufnr, a:name, a:Fn_name(a:name))
    endif
  endif
  return self
endfunction

function! s:View.ComputeIfPresent(name, Fn_name_value) abort dict
  if self.CheckValid("View.ComputeIfAbsent()")
    let l:value = getbufvar(self.bufnr, a:name, v:none)
    if l:value isnot v:none
      call setbufvar(self.bufnr, a:name, a:Fn_name_value(a:name, l:value))
    endif
  endif
  return self
endfunction

function! s:View.SetAll(vars) abort dict
  if self.CheckValid("View.SetAll()")
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
