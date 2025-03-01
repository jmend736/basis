mess clear

let g:next_id = 1

let g:job = job_start('python3 example_server.py --loop=True', {'mode': 'nl'})

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
  let resp = ch_evalraw(g:job, json_encode({
        \   'jsonrpc' : '2.0',
        \   'id'      : g:next_id,
        \   'method'  : a:method,
        \   'params'  : a:params,
        \ }) .. "\n")
  let g:next_id += 1
  return json_decode(resp)
endfunction

echom Call('f', [1])
echom Call('f', [2])
echom Call('f', [3])
echom Call('f', [])

call job_stop(job, "kill")
