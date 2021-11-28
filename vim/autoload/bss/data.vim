" TODO:
"   [X] Figure out how to handle list data (indexes?)
"       Can completions include extra text somehow?

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
  let l:ptr = a:data
  for l:part in a:path
    if (type(l:ptr) is v:t_dict) && (has_key(l:ptr, l:part))
      let l:ptr = l:ptr[l:part]
    elseif (type(l:ptr) is v:t_list)
          \  && (str2nr(l:part) >= 0 && str2nr(l:part) < len(l:ptr))
      let l:ptr = l:ptr[str2nr(l:part)]
    else
      return s:QueryResult({
            \   'ok': v:false,
            \   'path': a:path,
            \   'data': v:none,
            \   'T': v:t_none
            \ })
    endif
  endfor
  return s:QueryResult({
        \   'ok': v:true,
        \   'path': a:path,
        \   'data': l:ptr,
        \   'T': type(l:ptr),
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
