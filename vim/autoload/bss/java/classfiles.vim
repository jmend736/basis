function! bss#java#classfiles#Open() abort
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
endfunction

function! s:Setup() abort
  command! -buffer -nargs=1 -complete=file Load
        \ eval b:classfiles.Load(<q-args>)

  command! -buffer -nargs=* -complete=customlist,<SID>ClassFiles_QueryComplete Query
        \ eval b:classfiles.Query(<f-args>)
endfunction

function! s:ClassFiles_Load(fname) abort dict
  let l:cf = bss#ParseClassFile(a:fname)
  let self.loaded[l:cf.this_class] = l:cf
  call self.Update()
endfunction

function! s:ClassFiles_Query(cls, ...) abort dict
  let l:result = bss#data#LQuery(self.loaded[a:cls], a:000)
  if l:result.T is v:t_list
    for l:v in l:result.data
      echom l:v
    endfor
  elseif l:result.T is v:t_dict
    for [l:k, l:v] in items(l:result.data)
      echom l:k l:v
    endfor
  else
    echom string(l:result.data)
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
