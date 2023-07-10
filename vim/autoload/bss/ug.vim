" TODO: Actually finish this! xD

let s:UnicodeGraph = {
      \   'a': 1
      \ }

function! bss#ug#UnicodeGraph() abort
  return extend(deepcopy(s:UnicodeGraph), {})
endfunction

" Defines a location in a buffer that corresponds to a graph element.
let s:Node = {
      \   'location': v:none,
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
  let l:loc = (a:loc is v:none) ? bss#ug#location#CursorLocation() : a:loc
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
