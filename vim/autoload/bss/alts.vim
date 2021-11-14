let s:Alts = {
      \   'alternatives': [],
      \   'finalizer': v:none
      \ }

function! bss#alts#Alts() abort
  return deepcopy(s:Alts)
endfunction

function! s:Alts.Finally(Finally) abort dict
  let self.finalizer = bss#ensure#Func(a:Finally)
  return self
endfunction

function! s:Alts.Run(...) abort dict
  let l:obj = get(a:000, 0, v:none)
  for l:Alt in self.alternatives
    let l:res = l:Alt(l:obj)
    if l:res isnot v:none
      return (self.finalizer isnot v:none) ? self.finalizer(l:res) : l:res
    endif
  endfor
  return v:none
endfunction

function! s:Alts.Add(Handler) abort dict
  call add(self.alternatives, bss#ensure#Func(a:Handler))
  return self
endfunction

function! s:Alts.AddPred(Predicate, Handler) abort dict
  return self.Add({v -> (a:Predicate(v)) ? a:Handler(v) : v:none})
endfunction

function! s:Alts.AddMatch(pattern, Handler) abort dict
  return self.AddPred(
        \ {v -> v =~ bss#ensure#Str(a:pattern)},
        \ a:Handler)
endfunction

function! s:Alts.AddMagicMatch(pattern, Handler) abort dict
  return self.AddPred(
        \ {v -> v =~ '\v' .. bss#ensure#Str(a:pattern)},
        \ a:Handler)
endfunction

function! s:Alts.AddDict(mapping) abort dict
  return self.Add({v -> get(a:mapping, v, v:none)})
endfunction
