" See :h bss-pat

let s:Pat  = {'pattern': v:t_string, 'Handler': v:t_func}
let s:Pats = {'pats': v:t_list}

function! bss#pat#Pat(pattern, Handler) abort
  return copy(s:Pat)->extend({
        \   'pattern': a:pattern,
        \   'Handler': a:Handler,
        \ })
endfunction

function! bss#pat#Pats(pats) abort
  return copy(s:Pats)->extend({'pats': copy(a:pats)})
endfunction

function! s:Pat.Match(expr) abort
  let l:match = matchlist(a:expr, self.pattern)
  if len(l:match)
    return call(self.Handler, l:match)
  endif
  return v:none
endfunction

function! s:Pats.Match(expr) abort
  for l:pat in self.pats
    let l:res = l:pat.Match(a:expr)
    if l:res isnot v:none
      return l:res
    endif
  endfor
  return v:none
endfunction
