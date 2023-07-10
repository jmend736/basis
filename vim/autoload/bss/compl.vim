
function! bss#compl#CompleteFn(Fn, Match = {... -> v:true}) abort
  return {arg, ... -> filter(a:Fn(arg), 'stridx(v:val, arg) && a:Match(v:val, arg)')}
endfunction

function! bss#compl#CompleteList(values, Match = {... -> v:true}) abort
  return bss#compl#CompleteFn({ arg -> values })
endfunction
