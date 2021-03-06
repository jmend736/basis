function! bss#java#classfiles#Open(files) abort
  let l:view = bss#view#View({
        \   'options': [
        \     'nobuflisted',
        \     'bufhidden=wipe',
        \     'buftype=nofile',
        \   ],
        \   'vars': {
        \     'classfiles': {
        \       'view': v:none,
        \       'Load': function('s:ClassFiles_Load'),
        \       'Query': function('s:ClassFiles_Query'),
        \       'Update': function('s:ClassFiles_Update'),
        \       'loaded': {},
        \     }
        \   }
        \ })
        \.Open()
        \.Call({-> s:Setup()})
  let l:view.vars.classfiles.view = l:view
  call l:view.vars.classfiles.Update()
  for l:file in a:files
    call l:view.vars.classfiles.Load(l:file)
  endfor
endfunction

function! s:Setup() abort
  command! -buffer -nargs=1 -complete=file Load
        \ eval b:classfiles.Load(<q-args>)

  command! -buffer -nargs=* -complete=customlist,<SID>ClassFiles_QueryComplete Query
        \ eval b:classfiles.Query(<f-args>)
endfunction

function! s:ClassFiles_Load(fname) abort dict
  if a:fname =~# '\.jar$'
    let l:archive = bss#java#bytes#Jar(a:fname)
    for [l:path, l:bytes] in items(l:archive)
      try
        let l:cf = bss#java#classfile#ParseBytes(l:bytes)
        let self.loaded[l:cf.this_class] = l:cf
      catch /.*/
        echo 'ERROR(CFLoadError):' l:path '=>' v:exception
      endtry
    endfor
  else
    let l:cf = bss#ParseClassFile(a:fname)
    let self.loaded[l:cf.this_class] = l:cf
  endif
  call self.Update()
endfunction

function! s:ClassFiles_Query(cls, ...) abort dict
  let l:result = bss#data#LQuery(self.loaded[a:cls], a:000)
  if l:result.T is v:t_list
    echom join(l:result.path, '.') '= ['
    let l:n = 0
    for l:v in l:result.data
      echom printf('  %2d: %s', l:n, l:v)
      let l:n += 1
    endfor
    echom ']'
  elseif l:result.T is v:t_dict
    echom join(l:result.path, '.') '= {'
    for [l:k, l:V] in items(l:result.data)
      if type(l:V) is v:t_func
        continue
      endif
      echom printf('  %s: %s', string(l:k), l:V)
    endfor
    echom '}'
  else
    echom join(l:result.path, '.') '= ' string(l:result.data)
  endif
endfunction

function! s:ClassFiles_QueryComplete(...) abort
  return bss#data#DataComplete(b:classfiles.loaded, a:000)
endfunction

function! s:ClassFiles_Update() abort dict
  let l:lines = []
  eval l:lines->add('# Use :Load [classfile]` and `:Query [classname] [...]`')
  eval l:lines->add('loaded:')
  eval l:lines->extend(keys(self.loaded)->map('"  " .. v:val'))
  eval self.view.SetLines(l:lines)
endfunction
