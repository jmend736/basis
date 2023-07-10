function! bss#pretty#PPLines(data, show_func=v:false, context=[]) abort
  let l:lines = []
  if count(a:context, a:data) != 0
    return ['...']
  elseif type(a:data) is v:t_list
    call add(l:lines, '[')
    let l:n = 0
    call add(a:context, a:data)
    for l:v in a:data
      let l:v_lines = bss#pretty#PPLines(l:v, a:show_func, a:context)
      call add(l:lines, printf('  %2d: %s', l:n, l:v_lines[0]))
      call extend(l:lines, map(l:v_lines[1:], '"  "..v:val'))
      let l:n += 1
    endfor
    call remove(a:context, -1)
    call add(l:lines, ']')
  elseif type(a:data) is v:t_dict
    call add(l:lines, '{')
    call add(a:context, a:data)
    for [l:k, l:V] in items(a:data)
      if (type(l:V) is v:t_func) && !a:show_func
        continue
      endif
      let l:v_lines = bss#pretty#PPLines(l:V, a:show_func, a:context)
      call add(l:lines, printf('  %s: %s', string(l:k), l:v_lines[0]))
      call extend(l:lines, map(l:v_lines[1:], '"  "..v:val'))
    endfor
    call remove(a:context, -1)
    call add(l:lines, '}')
  else
    call add(l:lines, string(a:data))
  endif
  return l:lines
endfunction
