
let s:Jshell = {
      \   'buf'            : v:t_number,
      \   'handler_queue'  : [v:t_func],
      \   'job'            : v:t_job,
      \   'in_flight'      : {v:t_number: #{
      \     request        : v:t_func,
      \     parse_response : v:t_func
      \   }},
      \ }

let s:Packet = {}

function! s:Packet.parse(bytes) abort
  let b        = a:bytes
  let v        = {}
  let v.length = b.U4()
  let v.id     = b.U4()
  let v.flags  = b.U1()
  if v.flags == 0x80
    let v.error_code  = b.U1()
    let v.data        = b.Read(v.length)
  else
    let v.command_set = b.U1()
    let v.command     = b.U1()
    let v.data        = b.Read(v.length)
  endif
endfunction

let s:Commands = {}

let s:Commands.Packet = {}
let s:Commands.Packet.Header = {}

function! s:Commands.Packet.Header.request() abort
  
endfunction

function! s:Commands.Packet.Header.parse_response() abort
  
endfunction

let s:Commands.VirtualMachine = {}
let s:Commands.VirtualMachine.IDSizes = {}

function! s:Commands.VirtualMachine.IDSizes.request() abort
  return {}
endfunction

function! s:Commands.VirtualMachine.IDSizes.parse_response(bytes) abort
  let b                     = a:bytes
  let v                     = {}
  let v.fieldIDSize         = b.I4()
  let v.methodIDSize        = b.I4()
  let v.objectIDSize        = b.I4()
  let v.referenceTypeIDSize = b.I4()
  let v.frameIDSize         = b.I4()
  return v
endfunction

function! bss#java#jshell#Create(bufnr=-1) abort
  let l:jsh = copy(s:Jshell)

  let l:jsh.in_flight = {}

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
  if g:debug == 'run'
    if exists('g:jshell')
      call g:jshell.kill()
    endif
    let g:jshell_buf = bufadd('jshell_buf')
    let g:jshell = bss#java#jshell#Create(g:jshell_buf)
    call bss#PP(g:jshell, 1)
    StopAllJobs
  elseif g:debug == 'idsizes'
    let g:I = s:IDSizes
    call bss#PP(s:IDSizes, v:true)
  endif
endif
