function! bss#hg#Hg() abort
  if !exists('g:bss_hg')
    let g:bss_hg = bss#view#ScratchView()
    let g:bss_hg.show_summary = v:false
    let g:bss_hg.show_help = v:false
  endif
  eval g:bss_hg.Open()

  let l:prefix = []

  if g:bss_hg.show_help
    let l:cmds =<< trim eval END
      # bss#hg#Hg: commit (C) | refresh (r) | operate (<cr>)
    END
    call extend(l:prefix, l:cmds)
  else
    let l:cmds =<< trim eval END
      # bss#hg#Hg
    END
    call extend(l:prefix, l:cmds)
  endif

  if g:bss_hg.show_summary
    let l:summary = systemlist('hg summary')
          \->map({_, v -> '# ' .. v})
    call extend(l:prefix, l:summary)
  endif

  if !empty(l:prefix)
    call add(l:prefix, '')
  endif

  call g:bss_hg
        \.Open()
        \.SetLines(l:prefix)
        \.RunInsert('hg status')
        \.Exec('nnoremap <buffer> <cr> :call bss#hg#HgViewEnter()<cr>')
        \.Exec('nnoremap <buffer> ? :call bss#hg#HgViewToggleHelp()<cr>')
        \.Exec('nnoremap <buffer> s :call bss#hg#HgViewToggleSummary()<cr>')
        \.Exec('nnoremap <buffer> C :call bss#hg#HgViewRequestCommitMessage()<cr>')
        \.Exec('nnoremap <buffer> r :call bss#hg#HgViewRerunHg()<cr>')
endfunction

function! bss#hg#HgViewRerunHg() abort
  let l:cur = bss#cursor#Save()
  call bss#hg#Hg()
  call l:cur.Restore()
endfunction

function! bss#hg#HgViewToggleHelp() abort
  let g:bss_hg.show_help = !g:bss_hg.show_help
  call bss#hg#HgViewRerunHg()
endfunction

function! bss#hg#HgViewToggleSummary() abort
  let g:bss_hg.show_summary = !g:bss_hg.show_summary
  call bss#hg#HgViewRerunHg()
endfunction

""
" Create a maktaba.Selector window with potential commands to run on the
" selected file
"
function! bss#hg#HgViewEnterCommands(commands) abort
  call maktaba#ui#selector#Create(a:commands)
        \.WithMappings({
        \   '<CR>': [{cmd, data -> [data.fn(), bss#hg#HgViewRerunHg()]}, 'Close', 'Run the selected command'],
        \ })
        \.Show()
endfunction

function! s:Command(Fn, cmd) abort
  return [a:cmd, {'fn': function(a:Fn, [a:cmd])}]
endfunction

function! s:SystemCommand(cmd) abort
  return s:Command(function('system'), a:cmd)
endfunction

function! s:WindowCommand(cmd) abort
  return s:Command(function('bss#view#RunView'), a:cmd)
endfunction

function! s:PromptCommand(cmd) abort
  let l:arg = matchstr(a:cmd, '\v\<\zs.*\ze\>')
  return s:Command({ -> bss#view#PromptView(l:arg, { value -> bss#view#RunView(substitute(a:cmd, $'<{l:arg}>', value, '')) })}, a:cmd)
endfunction

function! bss#hg#HgViewEnter() abort
  let l:lnum = line('.')
  let l:line = getline(l:lnum)
  let l:match = matchlist(l:line, '\v^([MARC!?I]) (.*)')
  if !empty(l:match)
    let [l:unused, l:mode, l:fname; l:rest] = l:match
    if l:mode ==# 'M'
      " Modified
      call bss#hg#HgViewEnterCommands([
            \   s:PromptCommand($'hg commit -m "<msg>" {l:fname}'),
            \   s:WindowCommand($'hg diff {l:fname}'),
            \   s:WindowCommand($'hg log {l:fname}'),
            \   s:WindowCommand($'hg annotate {l:fname}'),
            \   s:WindowCommand($'hg absorb'),
            \   s:WindowCommand($'hg amend --include {l:fname}'),
            \   s:SystemCommand($'hg shelve'),
            \   s:SystemCommand($'hg forget {l:fname}'),
            \   s:SystemCommand($'hg revert --no-backup {l:fname}'),
            \   s:SystemCommand($'hg revert {l:fname}'),
            \   s:SystemCommand($'hg rm {l:fname}'),
            \ ])
    elseif l:mode ==# 'A'
      " Added
      call bss#hg#HgViewEnterCommands([
            \   s:PromptCommand($'hg commit -m "<msg>" {l:fname}'),
            \   s:SystemCommand($'hg diff {l:fname}'),
            \   s:SystemCommand($'hg forget {l:fname}'),
            \   s:SystemCommand($'hg revert {l:fname}'),
            \ ])

    elseif l:mode ==# 'R'
      " Removed
      call bss#hg#HgViewEnterCommands([
            \   s:PromptCommand($'hg commit -m "<msg>" {l:fname}'),
            \   s:WindowCommand($'hg add {l:fname}'),
            \   s:WindowCommand($'hg revert {l:fname}'),
            \ ])
    elseif l:mode ==# 'C'
      " Clean
    elseif l:mode ==# '!'
      " Missing
      call bss#hg#HgViewEnterCommands([
            \   s:SystemCommand($'hg addremove {l:fname}'),
            \   s:SystemCommand($'hg remove {l:fname}'),
            \   s:SystemCommand($'hg forget {l:fname}'),
            \   s:SystemCommand($'hg revert {l:fname}'),
            \ ])
    elseif l:mode ==# '?'
      " Untracked
      " TODO: add `append to .hgignore` command
      call bss#hg#HgViewEnterCommands([
            \   s:SystemCommand($'hg add {l:fname}'),
            \   s:SystemCommand($'hg addremove'),
            \   s:SystemCommand($'rm {l:fname}'),
            \ ])
    endif
  endif
endfunction

function! bss#hg#HgViewRequestCommitMessage() abort
  call bss#view#PromptView('Commit Message', function('bss#hg#HgViewCommit'))
endfunction

function! bss#hg#HgViewCommit(commit_message) abort
  call system($'hg commit --message "{a:commit_message}"')
  call bss#hg#HgViewRerunHg()
endfunction
