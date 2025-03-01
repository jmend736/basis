mess clear

if !exists('g:next_id') || !exists('g:resps')
  let g:next_id = 1
endif

let g:resps = {}

if !exists('g:job') || job_status(g:job) != 'run'
  let g:job = job_start('python3 example_server.py --loop=True', {'mode': 'nl'})
end

function! SetResp(id, resp) abort
  let g:resps[a:id] = a:resp
endfunction

function! Call(method, params) abort
  let id = g:next_id
  let g:next_id += 1
  let g:resps[id] = v:none
  call ch_sendraw(g:job, json_encode({
        \   'jsonrpc' : '2.0',
        \   'id'      : id,
        \   'method'  : a:method,
        \   'params'  : a:params,
        \ }) .. "\n", {
        \   'callback': { ch, msg -> SetResp(id, json_decode(msg)) }
        \ })
endfunction

echom 'job' g:job
call Call('f', [1])
call Call('f', [2])
call Call('f', [3])
call Call('f', [])

"call job_stop(job, "kill")
