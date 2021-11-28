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
        \       'loaded': {},
        \     }
        \   }
        \ })
        \.Open()
        \.Call({-> s:Setup()})
  let l:view.vars.classfiles.view = l:view
endfunction

function! s:ClassFiles_Load(fname) abort dict
  let l:cf = bss#ParseClassFile(a:fname)
  let self.loaded[l:cf.this_class] = l:cf
endfunction

function! s:ClassFiles_Query(cls, ...) abort dict
  echom bss#data#LQuery(self.loaded[a:cls], a:000).data
endfunction

function! s:ClassFiles_QueryComplete(...) abort
  return bss#data#DataComplete(b:classfiles.loaded, a:000)
endfunction

function! s:Setup() abort
  command! -buffer -nargs=1 -complete=file Load
        \ eval b:classfiles.Load(<q-args>)

  command! -buffer -nargs=* -complete=customlist,<SID>ClassFiles_QueryComplete Query
        \ eval b:classfiles.Query(<f-args>)
endfunction
