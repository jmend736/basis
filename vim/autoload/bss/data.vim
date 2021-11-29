" TODO:
"   [X] Allow method calls

let s:QueryResult = bss#Type({
      \   'ok': v:t_bool,
      \   'data': v:none,
      \   'path': v:t_list,
      \   'T': v:t_number,
      \ })

function! bss#data#Query(data, ...) abort
  return bss#data#LQuery(a:data, a:000)
endfunction

function! bss#data#LQuery(data, path) abort
  let l:Ptr = a:data
  for l:part in a:path
    let l:is_func = (l:part =~# '\w\+(.*)$')
    let l:args = '()'
    if l:is_func
      let l:args = matchstr(l:part, '\w\+\zs(.*)$')
      let l:part = matchstr(l:part, '\w\+\ze(')
    endif

    if (type(l:Ptr) is v:t_dict) && (has_key(l:Ptr, l:part))
      let l:Ptr = l:Ptr[l:part]
    elseif (type(l:Ptr) is v:t_list)
          \  && (str2nr(l:part) >= 0 && str2nr(l:part) < len(l:Ptr))
      let l:Ptr = l:Ptr[str2nr(l:part)]
    else
      return s:QueryResult({
            \   'ok': v:false,
            \   'path': a:path,
            \   'data': v:none,
            \   'T': v:t_none
            \ })
    endif

    if l:is_func
      if type(l:Ptr) isnot v:t_func
        throw 'ERROR(Type): Expected func ptr!'
      endif
      execute 'let l:Ptr = l:Ptr' .. l:args
    endif

  endfor
  return s:QueryResult({
        \   'ok': v:true,
        \   'path': a:path,
        \   'data': l:Ptr,
        \   'T': type(l:Ptr),
        \ })
endfunction

function! bss#data#DataComplete(data, args) abort
  let [l:path, l:last] = s:SeparateArgs(a:args)
  let l:result = bss#data#LQuery(a:data, l:path)
  if l:result.ok
    return (l:result.T is v:t_dict)
          \ ? keys(l:result.data)->filter('v:val =~# "^" .. l:last')
          \ : ((l:result.T is v:t_list)
          \   ? range(len(l:result.data))->map({_, v -> string(v)})
          \   : [])
  endif
  return []
endfunction

function! s:SeparateArgs(args) abort
  " arg   Leading position of the argument being completed on
  " line  Entire command-line, including whitespace
  " pos   Cursor position in relative to index of line
  "
  " Note that pos can be equal to len(line) when the cursor is one-after the
  " end of the command-line (AKA at the end).
  let [l:arg, l:line, l:pos] = a:args
  if len(l:line) != l:pos
    return v:none
  endif
  let l:line_parts = split(l:line, ' ', v:true)
  let l:last_part = l:line_parts[-1]
  if l:arg !=# l:last_part
    return v:none
  endif
  return [l:line_parts[1:-2], l:last_part]
endfunction
