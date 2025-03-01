mess clear

let s:next_id = 1
function! s:get_next_id() abort
  let id = s:next_id
  let s:next_id += 1
  return id
endfunction

" nl / pipe job
let s:job = job_start('python3 example_server.py --loop=True')

""
" Like `call()` but performs a synchronous RPC according to the JSON-RPC 2.0
" spec.
"
" Args:
"   method: string
"     The method name to call
"   params: list | dict
"     The parameters to pass to the method
"
function! Call(method, params) abort
  let resp = ch_evalraw(s:job, json_encode({
        \   'jsonrpc' : '2.0',
        \   'id'      : s:get_next_id(),
        \   'method'  : a:method,
        \   'params'  : a:params,
        \ }) .. "\n")
  return json_decode(resp)
endfunction

echom Call('f', [1])
echom Call('f', [2])
echom Call('f', [3])
echom Call('f', [])
echom Call('f', {'x': 10})
echom Call('f', {'y': 10})

call job_stop(s:job, "kill")
