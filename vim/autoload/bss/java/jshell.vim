
let s:Jshell = {
      \   'buf'   : v:t_number,
      \   'handler_queue' : [v:t_func],
      \   'job'   : v:t_job
      \ }

function! bss#java#jshell#Create(bufnr=-1) abort
  let l:jsh = copy(s:Jshell)

  let l:jsh.handler_queue = []

  let l:jsh.buf = (a:bufnr > -1) ? a:bufnr : bufadd('jshell_output')

  let l:jsh.job =
        \ job_start(["jshell"], {
        \   'out_cb': function(l:jsh.on_message, ['out']),
        \   'err_cb': function(l:jsh.on_message, ['err']),
        \   'close_cb': { -> 0 },
        \   'timeout': 0,
        \ })

  return l:jsh
endfunction

function! s:Jshell.kill() abort
  call self.echo("Killing %s", self.job)
  call job_stop(self.job)
endfunction

function! s:Jshell.on_message(type, ch, msg) abort

  call self.echo("[%s] %s", a:type == 'err' ? 'E' : 'O', a:msg)

  let l:is_out = a:type == 'out'
  let l:msg = a:msg

  if self.mode == 'init'
    if !l:is_out && empty(a:msg)
      let self.mode = 'ready'
    endif
  endif

  call self.echo("[mode: %s]", self.mode)
endfunction

function! s:Jshell.echo(fmt, ...) abort
  call appendbufline(self.buf, '$', call('printf', [">>> " .. a:fmt] + a:000))
endfunction

if exists('g:debug')
  if exists('g:jshell')
    call g:jshell.kill()
  endif
  let g:jshell_buf = bufadd('jshell_buf')
  let g:jshell = bss#java#jshell#Create(g:jshell_buf)
endif
