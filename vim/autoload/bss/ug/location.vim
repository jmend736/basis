"
" bss#ug#location#Location(bufnr, line, col) returns a Location{}
"
" bss#ug#location#CursorLocation()

let s:Location = {
      \   'bufnr': v:t_number,
      \   'lnum': v:t_number,
      \   'col': v:t_number,
      \   'length': v:t_number,
      \ }

let s:LocationTrie = {
      \   'data': v:none,
      \ }

let s:LocationProp = {
      \   'type': 'ug#location'
      \ }

" LocationTrie{} Constructors
" ---------------------------------------------------------------------------

function! bss#ug#location#LocationTrie() abort
  return extend(deepcopy(s:LocationTrie), {
        \   'data': {},
        \ })
endfunction

" LocationTrie{} Query Methods
" ---------------------------------------------------------------------------

function! s:LocationTrie.Has(col = col('.'), line = line('.'), bufnr = bufnr('%')) abort dict
  return self.GetCol(a:bufnr, a:line, a:col) is v:none
endfunction

function! s:LocationTrie.Get(col = col('.'), line = line('.'), bufnr = bufnr('%')) abort dict
  return self.GetCol(a:bufnr, a:line, a:col)
endfunction

function! s:LocationTrie.GetBuf(bufnr) abort dict
  return self.data->bss#Get(a:bufnr)
endfunction

function! s:LocationTrie.GetLine(bufnr, line) abort dict
  return self.GetBuf(a:bufnr)->bss#Get(a:line)
endfunction

function! s:LocationTrie.GetCol(bufnr, line, col) abort dict
  return self.GetLine(a:bufnr, a:line)->bss#Get(a:col - 1)
endfunction

function! s:LocationTrie.Query(...) abort dict
  return bss#data#LQuery(self.data, a:000)
endfunction

" LocationTrie{} Update Methods
" ---------------------------------------------------------------------------

function! s:LocationTrie.Add(col = col('.'), lnum = line('.'), bufnr = bufnr('%')) abort dict
  return self.AddLocation(bss#ug#location#Location(a:bufnr, a:lnum, a:col))
endfunction

function! s:LocationTrie.AddLocation(loc) abort dict
  let l:data = self.data
  for l:idx in [a:loc.bufnr, a:loc.lnum, a:loc.col]
    let l:data = bss#SetDefault(
          \   l:data,
          \   l:idx,
          \   { -> {}}
          \ )
  endfor
  eval l:data->extend(a:loc)
  eval l:data->extend({'locations': self})
  return self
endfunction

command! -nargs=* F call s:Foo()
function! s:Foo() abort
  let t = bss#ug#location#LocationTrie()
  call t.Add()
  PP t
endfunction
F

" Location{} Constructors
" ---------------------------------------------------------------------------
function! bss#ug#location#Location(bufnr, lnum, col, length=1) abort
  return extend(deepcopy(s:Location), {
        \   'bufnr': a:bufnr,
        \   'lnum': a:lnum,
        \   'col': a:col,
        \   'length': a:length,
        \ })
endfunction

function! bss#ug#location#CursorLocation() abort
  return bss#ug#location#Location(bufnr(''), line('.'), col('.'))
endfunction

function! bss#ug#location#ClearAllHighlights() abort
  return prop_clear(1, line('$'), s:LocationProp)
endfunction

function! s:Location.Highlight() abort
  call prop_add(self.lnum, self.col, s:LocationProp)
  return self
endfunction

function! s:Location.ClearHighlight() abort
  call prop_clear(self.lnum, self.lnum, s:LocationProp)
  return self
endfunction

function! s:Location.IsCharPresent() abort
  return self.Char() isnot v:none
endfunction

function! s:Location.Char() abort dict
  let l:lines = getbufline(self.bufnr, self.lnum)
  " Ensure line exists
  if empty(l:lines)
    return v:none
  endif
  " Ensure col exists
  if !(0 < self.col && self.col <= len(l:lines[0]))
    return v:none
  endif
  return l:lines[0][self.col - 1]
endfunction

function! s:Location.Neighbors(Filter = v:none) abort dict
  let l:neighbors = {
        \   'u': copy(self),
        \   'd': copy(self),
        \   'l': copy(self),
        \   'r': copy(self),
        \ }
  let l:neighbors.u.lnum -= 1
  let l:neighbors.d.lnum += 1
  let l:neighbors.l.col -= 1
  let l:neighbors.r.col += 1

  for [l:key, l:neighbor] in items(l:neighbors)
    if !l:neighbor.IsCharPresent()
      let l:neighbors[l:key] = v:none
    end
    if (a:Filter isnot v:none) && !a:Filter(l:neighbor)
      unlet l:neighbors[l:key]
    endif
  endfor

  return l:neighbors
endfunction


" Initialize Prop
silent call prop_type_delete(s:LocationProp.type)
silent call prop_type_add(s:LocationProp.type, #{
      \   highlight: 'DiffChange'
      \ })
