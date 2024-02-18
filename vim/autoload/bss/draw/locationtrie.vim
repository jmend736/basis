let s:LocationTrie = {
      \   'data': v:none,
      \ }

" LocationTrie{} Constructors
" ---------------------------------------------------------------------------

function! bss#draw#locationtrie#LocationTrie() abort
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
