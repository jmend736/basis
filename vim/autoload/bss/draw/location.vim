"
"
" bss#draw#location#Location(bufnr, line, col) returns a Location{}
"
" bss#draw#location#CursorLocation()

let s:Location = {
      \   'winid': v:t_number,
      \   'bufnr': v:t_number,
      \   'lnum':  v:t_number,
      \   'col':   v:t_number,
      \ }

let s:LocationTrie = {
      \   'data': v:none,
      \ }

let s:LocationProp = {
      \   'type': 'ug#location'
      \ }

" Location{} Constructors
" ---------------------------------------------------------------------------
function! bss#draw#location#Location(winid, bufnr, lnum, col) abort
  return extend(deepcopy(s:Location), {
        \   'winid': (a:winid isnot v:none && a:winid > 0) ? a:winid : win_getid(),
        \   'bufnr': (a:bufnr isnot v:none && a:bufnr > -1) ? a:bufnr : bufnr(),
        \   'lnum':  (a:lnum isnot v:none && a:lnum > 0) ? a:lnum : line('.'),
        \   'col':   (a:col isnot v:none && a:col > 0) ? a:col : col('.'),
        \ })
endfunction

function! bss#draw#location#CursorLocation() abort
  return bss#draw#location#Location(v:none, v:none, v:none, v:none)
endfunction

function! bss#draw#location#ClearAllHighlights() abort
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

" LocationTrie{} Constructors
" ---------------------------------------------------------------------------

function! bss#draw#location#LocationTrie() abort
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

function! s:LocationTrie.ForEach(Fn) abort dict
  for [l:bufnr, l:data_buf] in items(self.data)
    for [l:lnum, l:data_line] in items(l:data_buf)
      for [l:col, l:loc] in items(l:data_line)
        call a:Fn(l:loc)
      endfor
    endfor
  endfor
endfunction

" LocationTrie{} Update Methods
" ---------------------------------------------------------------------------

function! s:LocationTrie.Add(col = col('.'), lnum = line('.'), bufnr = bufnr('%')) abort dict
  return self.AddLocation(bss#draw#location#Location(a:bufnr, a:lnum, a:col))
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
  return self
endfunction

" Initialize Prop
silent call prop_type_delete(s:LocationProp.type)
silent call prop_type_add(s:LocationProp.type, #{
      \   highlight: 'DiffChange'
      \ })
