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

function! bss#md#GetSections(lines = v:none) abort
  let l:lines = (a:lines is v:none) ? getline(0, '$') : a:lines
  let l:sections = []
  let l:kind = v:none
  let l:lnum = len(l:lines)
  " Processing lines in reverse since headers can be specified by the
  " line following the header line.
  for l:line in reverse(l:lines)
    " Handle header lines
    if l:kind isnot v:none
      call add(l:sections, {
            \   'kind': l:kind,
            \   'name': l:line,
            \   'lnum': l:lnum,
            \ })
      let l:kind = v:none
    elseif l:line =~# '\v^(#+) (.*)'
      let [l:match, l:kind_str, l:name; _] = matchlist(l:line, '\v^(#+) (.*)')
      call add(l:sections, {
            \   'kind': len(l:kind_str),
            \   'name': l:name,
            \   'lnum': l:lnum,
            \ })
      let l:kind = v:none
    endif

    " Set expecation that next line is a header
    if l:line =~# '\v^\=+$'
      let l:kind = 1
    elseif l:line =~# '\v^\-+$'
      let l:kind = 2
    else
      let l:kind = v:none
    endif

    let l:lnum -= 1
  endfor

  " Handle any dangling header (e.g. `===` is the first line in a file)
  if l:kind isnot v:none
    call add(l:sections, {'kind': l:kind, 'name': ''})
  endif
  return reverse(l:sections)
endfunction

function! s:FindCurrentSection(sections = v:none) abort
  let l:sections = a:sections is v:none ? bss#md#GetSections() : a:sections
  let l:curline = line('.')
  let l:cursec = v:none
  for l:section in l:sections
    if l:curline >= l:section.lnum
      let l:cursec = l:section
    endif
  endfor
  return l:cursec
endfunction

function! bss#md#GoToSection() abort
  let l:sections = bss#md#GetSections()
  let l:cursec = s:FindCurrentSection(l:sections)
  let l:start_line = index(l:sections, l:cursec) + 1 + 1

  call maktaba#ui#selector#Create(map(l:sections, {i, v -> [repeat('#', v.kind) .. ' ' .. v.name, v]}))
        \.WithMappings({'<CR>': [function('s:GoToSection'), 'Close', 'Navigate to the section']})
        \.Show()

  call cursor(l:start_line, 1)
endfunction

function! s:GoToSection(line, section) abort
  call cursor(a:section.lnum, 1)
endfunction

function! bss#md#GoToRandomSection() abort
  let l:sections = bss#md#GetSections()
  if empty(l:sections)
    throw 'ERROR(Failure): No sections defined in file'
  endif
  let l:section = l:sections[rand() % len(l:sections)]
  call cursor(l:section['lnum'], 1)
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
