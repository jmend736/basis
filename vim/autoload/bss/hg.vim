function! bss#hg#Hg() abort
  if !exists('g:bss_hg')
    let g:bss_hg = bss#view#ScratchView()
  endif
  let l:cmds =<< trim eval END
    # bss#hg#Hg:
    #   commit (C) | refresh (r) | operate (<cr>)
    #
  END
  let l:prefix = systemlist('hg summary')
        \->map({_, v -> '# ' .. v})
  call g:bss_hg
        \.Open()
        \.SetLines(l:cmds + l:prefix + [''])
        \.RunAppend('hg status')
        \.Exec('nnoremap <buffer> <cr> :call bss#hg#HgViewEnter()<cr>')
        \.Exec('nnoremap <buffer> C :call bss#hg#HgViewRequestCommitMessage()<cr>')
        \.Exec('nnoremap <buffer> r :call bss#hg#HgViewRerunHg()<cr>')
endfunction

function! bss#hg#HgViewRerunHg() abort
  let l:cur = bss#cursor#Save()
  call bss#hg#Hg()
  call l:cur.Restore()
endfunction

""
" Create a maktaba.Selector window with potential commands to run on the
" selected file
"
function! bss#hg#HgViewEnterCommands(commands) abort
  call maktaba#ui#selector#Create(a:commands)
        \.WithMappings({
        \   '<CR>': [{line -> [system(line), bss#hg#HgViewRerunHg()]}, 'Close', 'Run the selected command'],
        \ })
        \.Show()
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
            \   $'hg revert --no-backup {l:fname}',
            \   $'hg revert {l:fname}',
            \   $'hg rm {l:fname}',
            \ ])
    elseif l:mode ==# 'A'
      " Added
      call system($'hg forget {l:fname}')
      call bss#hg#HgViewRerunHg()
    elseif l:mode ==# 'R'
      " Removed
    elseif l:mode ==# 'C'
      " Clean
    elseif l:mode ==# '!'
      " Missing
      call bss#hg#HgViewEnterCommands([
            \   $'hg addremove {l:fname}',
            \   $'hg revert {l:fname}',
            \ ])
    elseif l:mode ==# '?'
      " Untracked
      call bss#hg#HgViewEnterCommands([
            \   $'hg add {l:fname}',
            \   $'rm {l:fname}',
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
