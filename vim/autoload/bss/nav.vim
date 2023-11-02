let g:bss_nav_echo_data = v:false

function! bss#nav#Navigate(data, Callback = {... -> 0}) abort
  let l:ptr = deepcopy(s:Ptr)->extend({'data': a:data})
  eval l:ptr.Echo()
  while l:ptr.AddChar(nr2char(getchar()))
    eval l:ptr.Echo()
  endwhile
  eval l:ptr.Echo()
  call a:Callback(l:ptr.data)
endfunction

function! bss#nav#NavigateCall(data) abort
  eval bss#nav#Navigate(a:data, {V -> call(V, [])})
endfunction


let s:Ptr = {'data': {}, 'path': [], 'prefix': ''}

" Append the character to prefix, extending selection if possible
function! s:Ptr.AddChar(c) abort dict
  let self.prefix ..= a:c
  let l:keys = s:FilterKeys(self.data, self.prefix)

  if len(l:keys) == 0
    return v:false
  elseif len(l:keys) == 1
    let self.data = self.data[l:keys[0]]
    let self.path += [l:keys[0]]
    let self.prefix = ''
    return (type(self.data) is v:t_dict) || (type(self.data) is v:t_list)
  endif

  return v:true
endfunction

function! s:Ptr.Echo() abort dict
  redraw
  echohl Identifier | echon 'Navigate '
  echohl Constant   | echon 'path=[' join(self.path, ' ') '] '
  echohl Special    | echon 'keys=['
  let l:first = v:true
  for l:key in s:FilterKeys(self.data, self.prefix)
    echohl Type     | echon (!l:first ? ' ' : '') self.prefix
    echohl Special  | echon  l:key[len(self.prefix):]
    let l:first = v:false
  endfor
  echohl Special    | echon '] '
  echohl None       | echon 'data=' bss#pretty#PPLimited(1, self.data)
endfunction


function! s:FilterKeys(data, prefix = '') abort
  if type(a:data) is v:t_dict
    return filter(keys(a:data), 'stridx(v:val, a:prefix) == 0')
  elseif type(a:data) is v:t_list
    return filter(range(len(a:data)), 'stridx(v:val, a:prefix) == 0')
  endif
  return []
endfunction
