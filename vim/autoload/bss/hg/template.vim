function! bss#hg#template#GetJson(template) abort
  if type(a:template) is v:t_string
    let l:template = a:template->escape("\"")
    return systemlist($'hg log --template "{l:template}"')
  elseif type(a:template) is v:t_dict
    let l:template_dict = {}
    let l:template_proc = {}
    for [l:key, l:value] in items(a:template)
      let l:template_dict[l:key] = s:FixRaw(l:value)
      let l:template_proc[l:key] = s:FixProc(l:value)
    endfor
    return bss#hg#template#GetJsonRaw(l:template_dict)
          \->map({_, json -> json->map({k, v -> l:template_proc[k](v)})})
  endif
endfunction

function! s:FixRaw(arg) abort
  if type(a:arg) is v:t_string
    return a:arg
  elseif type(a:arg) is v:t_dict && has_key(a:arg, 'raw')
    return a:arg.raw
  else
    throw 'ERROR(WrongType): Arg must be a string of dict containing key "raw"'
  endif
endfunction

function! s:Id(v) abort
  return a:v
endfunction

function! s:FixProc(arg) abort
  if type(a:arg) is v:t_dict && has_key(a:arg, 'proc')
    return a:arg.proc
  else
    return function('s:Id')
  endif
endfunction

function! bss#hg#template#Author() abort
  return {'raw': '{author}'}
endfunction

function! bss#hg#template#Bookmarks() abort
  return {'raw': '{bookmarks}'}
endfunction

function! bss#hg#template#Branch() abort
  return {'raw': '{branch}'}
endfunction

function! bss#hg#template#ChangesSinceLatestTag() abort
  return {'raw': '{changessincelatesttag}',
        \ 'proc': {v -> str2nr(v)}}
endfunction

function! bss#hg#template#Files() abort
  return {'raw': '{files}',
        \ 'proc': {v -> split(v, ' ')}}
endfunction

""
" Turns a dict<string, string> JSON template for `hg log`, then returns the
" results after processing them with `json_decode`.
"
"   bss#hg#template#GetJsonRaw({"id": "{node}", "author": "{author}"})
"
function! bss#hg#template#GetJsonRaw(template) abort
  let l:template = json_encode(a:template)
        \->substitute('\v(^|[^"])\{', '\\{', 'g')
        \->escape("\"")
        \ .. "\n"
  let l:out = systemlist($'hg log --template "{l:template}"')
  return l:out->map('json_decode(v:val)')
endfunction

PP bss#hg#template#GetJson({
      \   'hello': bss#hg#template#Author(),
      \   'files': bss#hg#template#Files(),
      \   'cslt': bss#hg#template#ChangesSinceLatestTag(),
      \ })
