let s:UnicodeGraph = {
      \   'a': 1
      \ }

function! bss#ug#UnicodeGraph() abort
  return extend(deepcopy(s:UnicodeGraph), {})
endfunction

let s:Location = {
      \   'buf': v:none,
      \   'lnum': v:none,
      \   'col': v:none,
      \ }

function! s:MakeLocation() abort
  return extend(deepcopy(s:Location), {
        \   'buf': bufnr(''),
        \   'lnum': line('.'),
        \   'col': col('.'),
        \ })
endfunction

function! s:Location.IsValid() abort
  return self.Char() isnot v:none
endfunction

function! s:Location.Char() abort dict
  let l:lines = getbufline(self.buf, self.lnum)
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
  let l:neighbors.u.lnum += 1
  let l:neighbors.d.lnum -= 1
  let l:neighbors.l.col -= 1
  let l:neighbors.r.col += 1

  for [l:key, l:neighbor] in items(l:neighbors)
    if !l:neighbor.IsValid()
      let l:neighbors[l:key] = v:none
    end
    if (a:Filter isnot v:none) && !a:Filter(l:neighbor)
      let l:neighbors[l:key] = v:none
    endif
  endfor

  return l:neighbors
endfunction

" Defines a location in a buffer that corresponds to a graph element.
let s:Node = {
      \   'location': s:Location,
      \   'is_unicode': v:false,
      \   'neighbors': {
      \     'u': v:none,
      \     'd': v:none,
      \     'l': v:none,
      \     'r': v:none,
      \   },
      \ }

" TODO: locs doesn't work because it's checking not doing an instance check,
" not a value check! Make this into a trie >:D
function! s:MakeNode(loc = v:none, locs = v:none) abort
  let l:loc = (a:loc is v:none) ? s:MakeLocation() : a:loc
  let l:locs = (a:locs is v:none) ? [l:loc] : a:locs
  call bss#PP(l:loc)
  call bss#PP(l:locs)
  let l:node = extend(deepcopy(s:Node), {'location': l:loc})
  for [l:key, l:nloc] in items(l:loc.Neighbors({n -> n.Char() == '+'}))
    if l:nloc is v:none || count(l:nloc, l:locs) != 0
      continue
    endif
    call add(l:locs, l:nloc)
    let l:node.neighbors[l:key] = s:MakeNode(l:nloc, l:locs)
  endfor
  return l:node
endfunction

echom s:MakeNode()

" ++

" 0xUDLR
let s:Edges = {
      \   0x1000: '│',
      \   0x0100: '│',
      \   0x1100: '│',
      \   0x0010: '─',
      \   0x0001: '─',
      \   0x0011: '─',
      \ }
