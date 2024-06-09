"
"
" bss#draw#location#Location(bufnr, line, col) returns a Location{}
"
" bss#draw#location#CursorLocation()

let s:Location = {
      \   'bufnr': v:t_number,
      \   'lnum':  v:t_number,
      \   'col':   v:t_number,
      \ }

let s:LocationProp = {
      \   'type': 'ug#location',
      \   'args': {'highlight': 'DiffChange'},
      \ }

" Initialize Property Types
if empty(prop_type_get(s:LocationProp.type))
  silent call prop_type_add(
        \ s:LocationProp.type,
        \ s:LocationProp.args)
endif

" Location{} Constructors
" ---------------------------------------------------------------------------
function! bss#draw#location#Location(bufnr, lnum, col) abort
  if !(a:lnum > 0 && a:col > 0 && a:bufnr > -1)
    throw printf('ERROR(BadValue) Invalid specification {%s, %s, %s}', a:bufnr, a:lnum, a:col)
  endif
  return extend(deepcopy(s:Location), {
        \   'bufnr'  : a:bufnr,
        \   'lnum'   : a:lnum,
        \   'col'    : a:col,
        \   'origin' : [0, 0],
        \   'vector' : [a:lnum, a:col],
        \ })
endfunction

function! bss#draw#location#CursorLocation() abort
  let [_, line, col; _] = getcursorcharpos()
  return bss#draw#location#Location(bufnr(), line, col)
endfunction

function! bss#draw#location#ClearAllHighlights() abort
  return prop_clear(1, line('$'), {'type': s:LocationProp.type})
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

function! s:VecPlus(U, V) abort
  return [a:U[0] + a:V[0], a:U[1] + a:V[1]]
endfunction

function! s:VecTimes(a, U) abort
  return [a:a * a:U, a:a * a:U[1]]
endfunction
