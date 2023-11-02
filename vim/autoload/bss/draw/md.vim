""
" bss#draw#md#ParseMarkdownList()
"
" bss#draw#md#Tree()

function! bss#draw#md#ParseMarkdownListSelection() abort
  return bss#draw#md#ParseMarkdownList(getline("'<", "'>"))
endfunction

function! bss#draw#md#ParseMarkdownList(lines) abort
  let l:ptr = s:Pointer.create(a:lines)
  return s:ParseMarkdownListImpl(l:ptr, l:ptr.peek_indent())
endfunction

function! s:ParseMarkdownListImpl(ptr, indent) abort
  let l:data = []
  while (!a:ptr.empty()) && (a:indent == a:ptr.peek_indent())
    let [l:indent, l:marker, l:text] = a:ptr.pop()
    let l:kids = (!a:ptr.empty() && a:ptr.peek_indent() > a:indent)
          \ ? s:ParseMarkdownListImpl(a:ptr, a:ptr.peek_indent())
          \ : []
    eval l:data->add({'data': l:text, 'marker': l:marker, 'kids': l:kids})
  endwhile

  return l:data
endfunction

" Returns [l:indent, l:marker, l:text]
function! s:ParseListItem(line) abort
  let [_, l:indent, l:marker, l:text; _] =
        \ matchlist(a:line, '\v(\s*)([-*])\s*(.*)')
  return [len(l:indent), l:marker, l:text]
endfunction

let s:Pointer = {}

function! s:Pointer.create(lines) abort dict
  return deepcopy(s:Pointer)->extend({
        \   'lines': map(a:lines, 's:ParseListItem(v:val)'),
        \   'index': 0,
        \   'len': len(a:lines),
        \ })
endfunction

function! s:Pointer.empty() abort dict
  return self.index >= self.len
endfunction

function! s:Pointer.peek_indent() abort dict
  return self.peek()[0]
endfunction

function! s:Pointer.peek() abort dict
  if self.empty()
    throw 'ERROR(NotFound) Trying to peek but no data!'
  endif
  return self.lines[self.index]
endfunction

function! s:Pointer.pop() abort dict
  let l:line = self.peek()
  let self.index += 1
  return l:line
endfunction
