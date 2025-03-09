""
" Defines bss#java#javap#Browse() which is similar to zip#Browse() but for
" java classfiles.
"
" TODO: Add setup method to do the autocmd for users.
"
" DONE: Nested classes work (escape $ in fname)
" DONE: Write into the current buffer rather than creating a new one.
"

" Command to run javap
call bss#SetDefault(g:, 'bss_java_javap_command', { -> 'javap' })
" Execute unit tests
call bss#SetDefault(g:, 'bss_java_javap_test', { -> v:false })
" View instance
call bss#SetDefault(g:, 'bss_java_javap_view', {
      \ -> bss#view#ScratchView({
      \     'options': ['ft=java']
      \   })
      \ })
let s:view = g:bss_java_javap_view

""
" Enable unit test.
"
" Source this file to run the unit tests.
"
function! bss#java#javap#SetupTest() abort
  let g:bss_java_javap_test = v:true
endfunction

""
" Disable unit test.
"
function! bss#java#javap#DisableTest() abort
  unlet g:bss_java_javap_test
endfunction

""
" name: A file path of a .class file
"
function! bss#java#javap#Browse(name, args=[]) abort
  let l:lines = s:CallJavap(a:name, a:args)
  let l:prefix =<< trim eval END
  // bss#java#javap#Browse for
  //   {a:name}
  // with args: {string(a:args)}
  END
  let l:help =<< trim eval END
  //
  // Keymappings:
  //  d : Toggle -c (disassemble the code)
  //  c : Toggle -constants
  //  v : Toggle -verbose
  //  # : Toggle -protected
  //  p : Toggle -public
  //  P : Toggle -private
  //  s : Toggle -s (internal type signatures)
  //  S : Toggle -sysinfo
  //  ? : Toggle this key mapping.
  END
  call s:view.Extend({'bufnr': bufnr(), 'winid': win_getid()})
  call s:view.Open()
        \.Exec('setlocal modifiable ft=java foldlevel=1')
        \.SetLines(l:prefix + (get(b:, 'view_help', v:false) ? l:help : []) + l:lines)
        \.Call({ -> extend(b:, {
        \   'view'         : s:view,
        \   'view_name'    : a:name,
        \   'view_options' : get(b:, 'view_options', []),
        \   'ViewToggle'   : {opt -> s:ToggleOption(opt, 'view_options')},
        \ }) })
        \.Exec('nnoremap <buffer> v :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-v"))<CR>')
        \.Exec('nnoremap <buffer> d :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-c"))<CR>')
        \.Exec('nnoremap <buffer> c :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-constants"))<CR>')
        \.Exec('nnoremap <buffer> s :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-s"))<CR>')
        \.Exec('nnoremap <buffer> S :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-sysinfo"))<CR>')
        \.Exec('nnoremap <buffer> P :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-private"))<CR>')
        \.Exec('nnoremap <buffer> # :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-protected"))<CR>')
        \.Exec('nnoremap <buffer> p :call bss#java#javap#Browse(b:view_name, b:ViewToggle("-public"))<CR>')
        \.Exec('nnoremap <buffer> ? :eval [extend(b:, {"view_help": !get(b:, "view_help", v:false)}), bss#java#javap#Browse(b:view_name, b:view_options)][-1]<CR>')
        \.Exec('setlocal nomodifiable')
endfunction

function! s:CallJavap(fname, args) abort
  let l:fname = a:fname
        \->substitute('zipfile:', 'jar:file:', '')
        \->substitute('::', '!/', '')
        \->substitute('\$', '\\$', 'g')
  let l:cmd = $"{g:bss_java_javap_command} {join(a:args, ' ')} {l:fname}"
  let l:lines = systemlist(l:cmd)
  if v:shell_error
    echo join(l:lines, "\n")
    throw $"ERROR(Failure) javap command failed!"
  endif
  return l:lines
endfunction


function! s:ToggleOption(arg, name) abort

  eval s:Add(b:[a:name], a:arg) || s:Remove(b:[a:name], a:arg)

  let visibilities = ['-private', '-protected', '-public']
  if s:Remove(visibilities, a:arg)
    for visibility in visibilities
      call s:Remove(b:[a:name], visibility)
    endfor
  endif

  return b:[a:name]
endfunction

function! s:Add(list, value) abort
  if index(a:list, a:value) != -1
"   echom $"Didn't add {a:value} to {a:list}"
    return v:false
  else
    call add(a:list, a:value)
"   echom $"Added {a:value} to {a:list}"
    return v:true
  endif
endfunction

function! s:Remove(list, value) abort
  let idx = index(a:list, a:value)
  if idx == -1
"   echom $"Didn't remove {a:value} from {a:list}"
    return v:false
  else
    call remove(a:list, idx)
"   echom $"Removed {a:value} from {a:list}"
    return v:true
  endif
endfunction

if g:bss_java_javap_test

  let tmpdir      = tempname()
  let A_java      = $'{tmpdir}/A.java'
  let A_java_cont = ['class A { int f(int y) { return 2 + y + 4; } }']
  let s:A_class   = $'{tmpdir}/A.class'

  call mkdir(tmpdir)
  call writefile(A_java_cont, A_java)
  call system($'javac {A_java}')

  let b = bufadd(s:A_class)
  call bufload(b)
  "call bss#Try({ -> bss#java#javap#Browse(s:A_class) })
endif
