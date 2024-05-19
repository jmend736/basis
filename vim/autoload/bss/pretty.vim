function! bss#pretty#PP(data, show_func=v:false, context=[]) abort
  return join(bss#pretty#PPLines(a:data, a:show_func, a:context), "\n")
endfunction

function! bss#pretty#PPLimited(max_depth, data, show_func=v:false, context=[]) abort
  return join(bss#pretty#PPLines(a:data, a:show_func, a:context, a:max_depth), "\n")
endfunction

function! bss#pretty#PPLines(data, show_func=v:false, context=[], max_depth = -1) abort
  let l:lines = []
  let l:data_type = type(a:data)

  " Stop after max_depth if it's not -1
  if a:max_depth != -1 && len(a:context) > a:max_depth
    return ['...']

  " Avoid infinite recursion from data structures that include themselves
  elseif count(a:context, a:data) != 0
    return ['{...}']

  " Handle Functions
  elseif l:data_type is v:t_func
    let l:name = a:data->get('name')
    if l:name =~# '\m^\d\+$'
      let l:name = printf("{'%d'}", l:name)
    endif
    return [""] + execute(['function', l:name]->join(' '))
          \     ->split("\n")
          \     ->map('"  | " .. v:val')

  " Handle Lists
  elseif l:data_type is v:t_list
    call add(l:lines, '[')
    let l:n = 0
    call add(a:context, a:data)
    for l:V in a:data
      let l:v_lines = bss#pretty#PPLines(l:V, a:show_func, a:context, a:max_depth)
      call add(l:lines, printf('  %2d: %s', l:n, l:v_lines[0]))
      call extend(l:lines, map(l:v_lines[1:], '"  "..v:val'))
      let l:n += 1
    endfor
    call remove(a:context, -1)
    call add(l:lines, ']')

  " Handle Dicts
  elseif l:data_type is v:t_dict
    call add(l:lines, '{')
    call add(a:context, a:data)
    for [l:k, l:V] in items(a:data)
      if (type(l:V) is v:t_func) && !a:show_func
        continue
      endif
      let l:v_lines = bss#pretty#PPLines(l:V, a:show_func, a:context, a:max_depth)
      call add(l:lines, printf('  %s: %s', string(l:k), l:v_lines[0]))
      call extend(l:lines, map(l:v_lines[1:], '"  "..v:val'))
    endfor
    call remove(a:context, -1)
    call add(l:lines, '}')

  " 
  else
    call add(l:lines, string(a:data))

  endif

  return l:lines
endfunction
