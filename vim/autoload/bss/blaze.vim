" Bazel/Blaze helper functions
"
"   bss#blaze#BlazeTargets({fname})
"     Return the targets that depend on {fname} directly
"
"   bss#blaze#BlazeTarget()
"     Returns the first target for the current file or '???'
"
"   bss#blaze#TargetClasspath()
"     Returns the classpath for BlazeTarget()
"
"   bss#blaze#CompleteTargets({arg_lead}, {cmd_line}, {cursor_pos})
"     A -complete=customlist compatible function that simply filters the
"     commandline against all targets
"

if !exists('g:bss_blaze_command')
  let g:bss_blaze_cmd = 'blaze'
endif

function! bss#blaze#BlazeTargets() abort
  let l:query = printf(
        \   'same_pkg_direct_rdeps(%s)',
        \   fnamemodify(a:fname, ":p:."),
        \ )

  let l:command = printf(
        \   "%s query '%s'",
        \   g:bss_blaze_cmd,
        \   l:query,
        \ )
  return filter(systemlist(l:command), 'v:val =~# "^//"')
endfunction

function! bss#blaze#BlazeTarget() abort
  return get(bss#blaze#BlazeTargets(expand('%:p')), 0, "???")
endfunction

function! bss#blaze#BlazeGuessCommand(show = v:false) abort
  let l:fname = expand('%:p')

  let l:target = bss#blaze#BlazeTarget()
  if l:target ==# "???"
    echom "Can't find blaze target!"
    return "false"
  endif

  let l:action = 'build'
  if l:fname =~# '\v(_test.cc|Test.java)$' || l:target =~# '\v(_test|Test)$'
    let l:action = 'test'
  elseif l:fname =~# '\v(main.cc|_bin.cc|Bin.java)$' || l:target =~# '\v(_bin|Bin|main|Main)$'
    let l:action = 'run'
  elseif l:fname =~# '\v(_bench.cc)$' || l:target =~# '\v(_bench)$'
    let l:action = 'run -c opt'
  endif

  let l:command = printf(
        \   "%s %s %s",
        \   g:bss_blaze_command,
        \   l:action,
        \   l:target,
        \ )
  if a:show
    echom 'Using:' l:command
  endif
  return l:command
endfunction

function! bss#blaze#TargetClasspath() abort
  let l:target = bss#blaze#BlazeTarget()
  if l:target ==# "???"
    echom "Can't find blaze target!"
    return ""
  endif

  let l:lines = systemlist(printf('blaze print_action "%s"', l:target))
  let l:jars = filter(l:lines, {_, v -> v =~# '^\s\+\(outputjar\|classpath\): "[^"]*"'})
        \->map({_, v -> matchlist(v, '"\([^"]*\)"')[1]})
  return join(l:jars, ':')
endfunction

function! bss#blaze#CompleteTargets(arg_lead, cmd_line, cursor_pos) abort
  if a:arg_lead =~ '^//.*'
    return systemlist(printf('%s query ... 2>&1', g:bss_blaze_command))
          \->filter('v:val =~# "' .. a:arg_lead .. '"')
  endif
endfunction
