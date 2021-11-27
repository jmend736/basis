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
endfunction

function! s:ClassFiles_QueryComplete(arg, args, pos) abort
  let l:args = split(a:args)[1:]
  if empty(l:args)
    return keys(b:classfiles.loaded)->filter({_, v -> v =~# a:arg})
  elseif has_key(b:classfiles.loaded, l:args[0])
    let l:ptr = b:classfiles.loaded[l:args[0]]
    for l:key in l:args[1:]
      if empty(l:key)
        continue
      elseif has_key(l:ptr, l:key)
        let l:ptr = l:ptr[l:key]
      else
        return keys(l:ptr)->filter({_, v -> v =~# l:key})
      endif

      if type(l:ptr) != v:t_dict
        return []
      endif
    endfor
    return keys(l:ptr)
  endif
  return []
endfunction

function! s:Setup() abort
  command! -buffer -nargs=1 -complete=file CfLoad
        \ eval b:classfiles.Load(<q-args>)

  command! -buffer -nargs=* -complete=customlist,<SID>ClassFiles_QueryComplete CfQuery
        \ eval b:classfiles.Query(<q-args>)
endfunction
