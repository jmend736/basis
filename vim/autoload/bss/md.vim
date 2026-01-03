"                             Markdown utilities

let s:FENCE = '```'

""
" Convert a list of lines to a list of codeblock lines.
"
function! bss#md#CreateBlock(lines) abort
  return [s:FENCE] + a:lines + [s:FENCE]
endfunction

""
" Convert a list of lines (or the lines in the current file).
"
" bss#md#GetBlocks()
" :   Get code blocks in the current file.
"
" bss#md#GetBlocks(lines: list<string>)
" :   Get code blocks in the provided lines.
"
function! bss#md#GetBlocks(lines = v:none) abort
  let l:lines = (a:lines is v:none) ? getline(0, '$') : a:lines
  let l:blocks = []
  let l:block = v:none
  let l:line_idx = 0
  for l:line in l:lines
    let l:line_idx += 1
    if match(l:line, '\v^\s*```') != -1
      let l:indent = matchstr(l:line, '\v^\s*')
      if l:block is v:none
        let l:lang = matchstr(l:line, '\v```\zs(\S+)')
        let l:block = []
        eval l:blocks->add({
              \   'lang': l:lang,
              \   'indent': l:indent,
              \   'span': [l:line_idx + 1],
              \   'lines': l:block
              \ })
        continue
      else
        let l:last = l:blocks->get(l:blocks->len() - 1)
        eval l:last['span']->add(l:line_idx - 1)
        let l:block = v:none
      endif
    elseif l:block isnot v:none
      if stridx(l:line, l:indent) != 0
        throw 'ERROR(BadIndent): Indentation on line ' .. l:line_idx .. ' is unexpected!'
      endif
      let l:uline = substitute(l:line, l:indent, '', '')
      eval l:block->add(l:uline)
    endif
  endfor
  return l:blocks
endfunction

if v:false
  call assert_equal(
        \ [s:FENCE, s:FENCE],
        \ bss#md#CreateBlock([]))
  call assert_equal(
        \ [s:FENCE, 'a', 'b', 'c', s:FENCE],
        \ bss#md#CreateBlock(['a', 'b', 'c']))

  call assert_equal(
        \ [['a', 'b', 'c']],
        \ bss#md#GetBlocks(bss#md#CreateBlock(['a', 'b', 'c'])))
endif
