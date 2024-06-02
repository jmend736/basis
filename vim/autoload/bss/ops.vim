""
" Helpers for writing operators
"
" OPERATOR USAGE
"
"   Using |g@| and 'operatorfunc' the general syntax
"
"   1.  Define the mapping
"
"       1.  `nnoremap <expr> <F4> Operator()` 
"           :   Defines normal mode mapping
"
"       2.  `xnoremap <expr> <F4> Operator()` 
"           :   Defines visual mode mapping
"
"       -   NOTE: With `<expr>`, the `Operator()` function returns a string with
"                 keystrokes to use for the mapping.
"
"   2.  Mapping is invoked (eg. user pressing `<F4>` in normal mode).
"
"   3.  `Operator()` should:
"
"       -   Set the 'operatorfunc' option
"       -   Return the string `g@`
"
"   4.  User will provide a motion after the operator
"
"   5.  Vim will call 'operatorfunc' with one of 3 arguments:
"
"       -   line  : Line-wise operations
"       -   char  : Character-wise operations
"       -   block : Block-wise operations
"
" HELPERS
"
"   bss#ops#Op(OpFn)
"     Helper for steps (3) and (5). Given an update function which accepts the
"     arguments:
"
"         OpFn(line, part, PartUpdater)
"
"     The `OpFn` should call `PartUpdater` if it wants to change the line.
"
"   bss#ops#Ranges()
"     Helper for dealing with step (5). It yields the selected lines and indices
"     of the start/end of the selection.
"
"   bss#ops#LinePartModifiers()
"     A higher-level abstraction over bss#ops#Ranges() which returns the full
"     line, the selected portion and a function that accepts text to replace the
"     selected portion of the line.

""
" Helper for steps (3) and (5). Given an update function which accepts the
" arguments:
"
"     OpFn(line, part, PartUpdater)
"
" The `OpFn` should call `PartUpdater` if it wants to change the line.
"
function! bss#ops#Op(OpFn, type = '__setup__') abort
  if a:type == '__setup__'
    let &operatorfunc = function('bss#ops#Ops', [a:OpFn])
    return 'g@'
  endif

  for [l:line, l:part, l:PartUpdater] in bss#ops#LinePartModifiers(a:type)
    call call(a:OpFn, [l:line, l:part, l:PartUpdater])
  endfor
endfunction


""
" Given a beginning and ending locations, produces a lists that specify the
" parts of the buffer that have been selected. There is one entry per line
" being operated on and each entry has the form:
"     [lnum, begin_col, end_col]
" NOTE: if the line is empty and you're using line/char, then begin and end
" cols will be [1, 0].
"
" {type} correspond to one of ( line | char | block ) like for |g@|
"
function! bss#ops#Ranges(type='char', begin_mark="'[", end_mark="']") abort
  let l:first_lnum = line(a:begin_mark)
  let l:last_lnum  = line(a:end_mark)
  let l:lines = getline(l:first_lnum, l:last_lnum)
  let l:ranges = copy(range(l:first_lnum, l:last_lnum))
        \->map({i, lnum -> [
        \   lnum,
        \   min([len(l:lines[i]), 1]),
        \   len(l:lines[i]),
        \ ]})

  if a:type == 'char'
    let l:pos = getpos(a:begin_mark)
    let l:ranges[l:pos[1] - l:first_lnum][1] = l:pos[2]
    let l:pos = getpos(a:end_mark)
    if l:pos[2] != 2147483647
      let l:ranges[l:pos[1] - l:first_lnum][2] = l:pos[2]
    endif
  elseif a:type == 'block'
    let l:range = [col(a:begin_mark), col(a:end_mark)]
    call map(l:ranges, { i, v -> extend([v[0]], copy(l:range)) })
  endif
  return l:ranges
endfunction

""
" Similar to bss#ops#Ranges(), but returns a list of lists where each element
" in the inner lists is: [line, part, PartUpdater]
"
" Where SelectedUpdater(updated_part) is a method which updates the selected
" part of the line that corresponds with that range.
"
function! bss#ops#LinePartModifiers(type='char', begin_mark="'[", end_mark="']") abort
  let l:ranges = bss#ops#Ranges(a:type, a:begin_mark, a:end_mark)

  let l:pieces = []

  for [l:lnum, l:start_col, l:end_col] in l:ranges
    let l:line = getline(l:lnum)
    let l:part = l:line[l:start_col - 1:l:end_col - 1]
    call add(l:pieces, [
          \ l:line,
          \ l:part,
          \ function('s:bss_ops_LinePartModifier_Updater', [
          \     l:lnum,
          \     l:start_col,
          \     l:end_col
          \   ])
          \ ])
  endfor

  return l:pieces
endfunction

function! s:bss_ops_LinePartModifier_Updater(lnum, begin_col, end_col, updated_text) abort
    let l:line    = getline(a:lnum)
    let l:left    = l:line[:a:begin_col - 2]
    let l:right   = l:line[a:end_col:]
    let l:newline = l:left .. a:updated_text .. l:right
    call setline(a:lnum, l:newline)
endfunction
