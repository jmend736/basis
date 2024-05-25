
let s:Jshell = {
      \   'buf'            : v:t_number,
      \   'handler_queue'  : [v:t_func],
      \   'job'            : v:t_job,
      \   'in_flight'      : {v:t_number: #{
      \     request        : v:t_func,
      \     parse_response : v:t_func
      \   }},
      \ }

let s:Commands = {}
let s:Commands.Packet = {}

let s:Commands.Packet.Id = {}

let s:Commands.Packet.Header = {}
let s:Commands.Packet.Command = {}
let s:Commands.Packet.Reply = {}

let s:Commands.VirtualMachine = {}
let s:Commands.VirtualMachine.IDSizes = {}

""
" @param data       : blob | list
" @param command    : number
" @param is_command : boolean
"
let s:Commands.Packet.Id.next_id = 1
function! s:Commands.Packet.Id.build(bb) abort dict
  let id = self.next_id
  let self.next_id += 1
  return bb.U4(id)
endfunction

function! s:Commands.Packet.Id.parse(b) abort
  return b.U4()
endfunction

""
" @param data       : blob | list
" @param command    : number
" @param is_command : boolean
"
function! s:Commands.Packet.Header.build(data, is_command) abort dict
  return bss#java#bytesbuilder#Create()
        \ .U4(len(a:data) + 11)
        \ .U4(s:Commands.Packet.Id.build())
        \ .U1(a:is_command ? 0x00 : 0x80)
endfunction

function! s:Commands.Packet.Header.parse(b) abort
  return #{
        \   length   : b.U4(),
        \   id       : s:Commands.Packet.Id.parse(b),
        \   is_reply : b.U1() == 0x80,
        \ }
endfunction

echom s:Commands.Packet.Header.build(0zDEADBEEF, 1)

""
" @param id          : number
" @param command     : number
" @param command_set : number
" @param data        : blob | list
"
function! s:Commands.Packet.Command.build(id, command, command_set, data) abort dict
  return s:Commands.Packet.Header.build(a:data, a:id, v:false)
        \ .U1(a:command)
        \ .U1(a:command_set)
        \ .Add(a:data)
endfunction

function! s:Commands.Packet.Command.parse(b) abort dict
  let l:packet = s:Commands.Packet.Header.parse(b)
  let l:packet.command = b.U1()
  let l:packet.command_set = b.U1()
  let l:packet.data = b.Read(l:packet.length - 11)
  return l:packet
endfunction

""
" @param id         : number
" @param error_code : number
" @param data       : blob | list
"
function! s:Commands.Packet.Command.build(id, error_code, data) abort dict
  return s:Commands.Packet.Header.build(a:data, a:id, v:false)
        \ .U2(a:error_code)
        \ .Add(a:data)
endfunction

function! s:Commands.Packet.Reply.parse(b) abort dict
  let p            = s:Commands.Packet.Header.parse(b)
  let p.error_code = b.U2()
  let p.data       = b.Read(p.length - 11)
  return p
endfunction


function! s:Commands.VirtualMachine.IDSizes.build(id) abort
  return s:Commands.Packet.Command.build(id)
endfunction

function! s:Commands.VirtualMachine.IDSizes.parse(bytes) abort
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
